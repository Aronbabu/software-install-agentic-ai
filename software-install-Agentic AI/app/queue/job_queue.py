#will retire this in favor of a more robust queue system like Celery or RQ in the future. For now, this is a simple in-memory queue for demonstration purposes.

def enqueue_job(job_id: str):
    raise NotImplementedError(
        "Legacy queue disabled. Use Celery."
    )
def get_queue_status():
    return {
        "queue_size": 0,
        "worker_count": 0,
        "active_jobs_count": 0,
        "active_job_ids": []
    }
def start_workers(*args, **kwargs):
    pass

def stop_workers():
    pass
