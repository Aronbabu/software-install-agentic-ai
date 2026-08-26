import logging
import queue
import threading
from typing import Callable

logger = logging.getLogger("app.queue")

_job_queue = queue.Queue()
_workers = []
_started = False

# NEW: track active jobs
_active_jobs = set()
_active_lock = threading.Lock()


def start_workers(worker_count: int, worker_handler: Callable[[str], None]):
    global _started
    if _started:
        return

    def worker():
        while True:
            job_id = _job_queue.get()

            if job_id is None:
                break

            thread_name = threading.current_thread().name

            print(f"🔥 Worker picked job: {job_id}")
            print(f"🧵 Thread [{thread_name}] handling job: {job_id}")

            # mark active
            with _active_lock:
                _active_jobs.add(job_id)

            try:
                worker_handler(job_id)
            except Exception as exc:
                logger.exception("Worker failed for job_id=%s error=%s", job_id, exc)
            finally:
                # remove from active
                with _active_lock:
                    _active_jobs.discard(job_id)

                _job_queue.task_done()

    for _ in range(worker_count):
        t = threading.Thread(target=worker, daemon=True)
        t.start()
        _workers.append(t)

    _started = True
    logger.info("Started %s workers", worker_count)


def enqueue_job(job_id: str):
    _job_queue.put(job_id)

    print(f"📥 Job queued: {job_id}")
    print(f"📊 Queue size: {_job_queue.qsize()}")


def get_queue_status():
    with _active_lock:
        return {
            "queue_size": _job_queue.qsize(),          # waiting
            "worker_count": len(_workers),            # total workers
            "active_jobs_count": len(_active_jobs),   # running now
            "active_job_ids": list(_active_jobs),     # optional visibility
        }


def stop_workers():
    for _ in _workers:
        _job_queue.put(None)