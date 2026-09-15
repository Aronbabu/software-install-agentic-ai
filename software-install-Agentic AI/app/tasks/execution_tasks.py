from app.celery_app import celery_app
from app.db import SessionLocal
from app.models.job import Job, JobStatus
from app.services.execution_service import process_job
from app.services.job_lifecycle import append_job_step, update_job_status


@celery_app.task(
    bind=True,
    name="app.tasks.execution_tasks.process_job_task",
    track_started=True,
)
def process_job_task(self, job_id: str):
    print(f"Celery task received for job_id={job_id}")

    db = SessionLocal()

    try:
        job = db.query(Job).filter(Job.id == job_id).first()

        if job:
            append_job_step(
                db=db,
                job_id=job.id,
                step_name="celery_task_received",
                status="SUCCESS",
                message=f"Celery worker received execution task. celery_task_id={self.request.id}",
                exit_code=0,
            )
            db.commit()

            if job.status == JobStatus.PLAN_READY:
                update_job_status(
                    db=db,
                    job=job,
                    new_status=JobStatus.RUNNING,
                    message="Execution started from plan-ready state.",
                )

        process_job(job_id)

        job = db.query(Job).filter(Job.id == job_id).first()

        if job:
            append_job_step(
                db=db,
                job_id=job.id,
                step_name="celery_task_completed",
                status="SUCCESS",
                message=f"Celery execution task completed. celery_task_id={self.request.id}",
                exit_code=0,
            )
            db.commit()

        return {
            "job_id": job_id,
            "status": "completed",
            "celery_task_id": self.request.id,
        }

    except Exception as exc:
        print(f"Celery task failed for job_id={job_id}: {str(exc)}")

        try:
            db.rollback()

            job = db.query(Job).filter(Job.id == job_id).first()

            if job:
                append_job_step(
                    db=db,
                    job_id=job.id,
                    step_name="celery_task_failed",
                    status="FAILED",
                    message=f"Celery execution task failed. error={str(exc)}",
                    exit_code=1,
                )

                if job.status not in [
                    JobStatus.SUCCESS,
                    JobStatus.FAILED,
                    JobStatus.FAILED_FINAL,
                    JobStatus.REVIEW_REQUIRED,
                ]:
                    update_job_status(
                        db=db,
                        job=job,
                        new_status=JobStatus.FAILED,
                        message=f"Celery execution task failed: {str(exc)}",
                    )

                db.commit()

        except Exception as db_exc:
            print(f"Failed to record Celery failure for job_id={job_id}: {str(db_exc)}")

        raise

    finally:
        db.close()