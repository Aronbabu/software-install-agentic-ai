import logging
import time

from app.db import SessionLocal
from app.models import Job, JobStatus
from app.executors import windows_executor, linux_executor
from app.services.job_lifecycle import update_job_status, append_job_step
from app.queue.job_queue import enqueue_job

logger = logging.getLogger("app.services.execution")


def execute_job(job):
    os_type = (job.os_type or "").strip().lower()

    print(f"🧠 Deciding executor for OS: {os_type}")
    
    if job.os_type not in ["linux", "windows"]:
        raise ValueError(f"Unsupported OS type: {job.os_type}")

    if os_type == "windows":
        return windows_executor.run_windows(job)
    elif os_type == "linux":
        return linux_executor.run_linux(job)
    else:
        raise ValueError(f"Unsupported os_type: {job.os_type}")


def process_job(job_id: str):
    print(f"✅ process_job started for: {job_id}")

    db = SessionLocal()

    try:
        job = db.query(Job).filter(Job.id == job_id).first()

        if not job:
            print("❌ Job not found")
            return

        print(f"📌 Current status: {job.status}")

        # ✅ Step 1 — VALIDATING
        if job.status == JobStatus.PENDING:
            print("➡ Moving to VALIDATING")
            job = update_job_status(db, job, JobStatus.VALIDATING, "Validation started")
            db.refresh(job)
            time.sleep(10)

        # ✅ Step 2 — RUNNING
        if job.status == JobStatus.VALIDATING:
            print("➡ Moving to RUNNING")
            job = update_job_status(db, job, JobStatus.RUNNING, "Execution started")
            db.refresh(job)
            time.sleep(15)

        # ✅ Step 3 — EXECUTION + TIMING
        print("⚡ Executing...")

        start_time = time.time()
        result = execute_job(job)   # ✅ NOW returns ExecutionResult object
        execution_time = round(time.time() - start_time, 2)

        print(f"✅ Execution result: {result}")
        print(f"⏱ Execution took {execution_time} seconds")

        # ✅ ✅ NEW: Structured execution result storage
   
        append_job_step(
            db=db,
            job_id=job.id,
            step_name="execution_result",
            status="SUCCESS" if result.success else "FAILED",
            message=(
                f"transport={result.transport}; "
                f"exit_code={result.exit_code}; "
                f"duration={result.duration_seconds}s; "
                f"stdout={result.stdout[:300] if result.stdout else ''}; "
                f"stderr={result.stderr[:300] if hasattr(result, 'stderr') and result.stderr else ''}"
            ),
            exit_code=result.exit_code,
        )
        db.commit()


        # ✅ ✅ NEW: verification result step
        append_job_step(
            db=db,
            job_id=job.id,
            step_name="verification_result",
            status="SUCCESS" if result.success else "FAILED",
            message=f"Verification output: {result.stdout}",
            exit_code=result.exit_code,
        )
        db.commit()

        # ✅ Keep your original execution_time step
        append_job_step(
            db=db,
            job_id=job.id,
            step_name="execution_time",
            status="SUCCESS",
            message=f"Execution took {execution_time} seconds",
            exit_code=0,
        )

        db.commit()

        time.sleep(10)

        # ✅ Step 4 — VERIFYING
        if job.status == JobStatus.RUNNING:
            print("➡ Moving to VERIFYING")
            job = update_job_status(db, job, JobStatus.VERIFYING, "Verification started")
            db.refresh(job)
            time.sleep(10)

        # ✅ ✅ FIXED: Correct success evaluation
        if result.success:
            print("✅ Moving to SUCCESS")
            
            job = update_job_status(db, job, JobStatus.SUCCESS, "Execution completed successfully")

        else:
            print("❌ Execution failed")

            # ✅ ✅ NEW: Retry tracking
            job.retry_count += 1
            job.last_error = result.stderr or "Execution failed"

            db.add(job)
            db.commit()
            db.refresh(job)

            append_job_step(
                db=db,
                job_id=job.id,
                step_name="retry_attempt",
                status="FAILED",
                message=f"Attempt {job.retry_count} failed",
                exit_code=result.exit_code,
            )

            db.commit()

            # ✅ ✅ NEW: Final failure handling
            if job.retry_count >= job.max_retries:
                print(f"🔁 Retrying ({job.retry_count}/{job.max_retries})")
                print("🔥 Moving to FAILED_FINAL")
                job = update_job_status(
                    db,
                    job,
                    JobStatus.FAILED_FINAL,
                    f"Execution failed after {job.max_retries} attempts"
                )
            else:
                print(f"🔁 Retrying ({job.retry_count}/{job.max_retries})")
                job.status = JobStatus.PENDING
                db.add(job)
                db.commit()
                db.refresh(job)
      
                enqueue_job(job.id)  # ✅ requeue job
                return


    except Exception as e:
        print(f"🔥 ERROR: {str(e)}")
        logger.exception("Execution service unexpected error")

        try:
            job = db.query(Job).filter(Job.id == job_id).first()
            if job:
                job.last_error = str(e)
                db.add(job)
                db.commit()
                db.refresh(job)

                if job.status not in [JobStatus.SUCCESS, JobStatus.FAILED, JobStatus.FAILED_FINAL]:
                    update_job_status(
                        db,
                        job,
                        JobStatus.FAILED,
                        f"Execution exception: {str(e)}"
                    )
        except Exception:
            logger.exception("Secondary failure while marking job failed")

    finally:
        db.close()