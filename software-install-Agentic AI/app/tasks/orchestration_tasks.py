from app.celery_app import celery_app
from app.config import settings
from app.db import SessionLocal
from app.models.job import Job, JobStatus
from app.services.job_lifecycle import append_job_step, update_job_status


@celery_app.task(
    bind=True,
    name="app.tasks.orchestration_tasks.orchestrate_job_task",
    track_started=True,
)
def orchestrate_job_task(self, job_id: str):
    db = SessionLocal()
    try:
        job = db.query(Job).filter(Job.id == job_id).first()
        
        if not job:
            return {
                "job_id": job_id,
                "status": "not_found",
                "celery_task_id": self.request.id,
            }
        if job.status == JobStatus.REVIEW_REQUIRED:
            append_job_step(
                db=db,
                job_id=job.id,
                step_name="manual_review_pending",
                status="SUCCESS",
                message=(
                    "Planning completed with REVIEW_REQUIRED. "
                    "Execution will not be queued until manual review."
                ),
                exit_code=0,
            )
            db.commit()

            return {
                "job_id": job_id,
                "status": "review_required",
                "celery_task_id": self.request.id,
            }
        append_job_step(
            db=db,
            job_id=job.id,
            step_name="orchestrator_received",
            status="SUCCESS",
            message=f"Orchestrator received job. celery_task_id={self.request.id}",
            exit_code=0,
        )
        db.commit()

        if job.status == JobStatus.PENDING:
            update_job_status(
                db=db,
                job=job,
                new_status=JobStatus.VALIDATING,
                message="Job moved to validation before planning.",
            )
            job = db.query(Job).filter(Job.id == job_id).first()

        if job.status == JobStatus.VALIDATING:
            update_job_status(
                db=db,
                job=job,
                new_status=JobStatus.PLANNING,
                message="Dispatching job to planning queue.",
            )
            generate_plan_task = celery_app.signature(
                "app.tasks.planning_tasks.generate_plan_task",
                args=[job_id],
                queue=settings.CELERY_QUEUE_PLANNING,
            )
            generate_plan_task.apply_async()
            return {
                "job_id": job_id,
                "status": "planning_dispatched",
                "celery_task_id": self.request.id,
            }

        if job.status == JobStatus.PLAN_READY:
            process_job_task = celery_app.signature(
                "app.tasks.execution_tasks.process_job_task",
                args=[job_id],
                queue=settings.CELERY_QUEUE_EXECUTION,
            )
            process_job_task.apply_async()
            return {
                "job_id": job_id,
                "status": "execution_dispatched",
                "celery_task_id": self.request.id,
            }

        if job.status == JobStatus.REVIEW_REQUIRED:
            append_job_step(
                db=db,
                job_id=job.id,
                step_name="review_required_detected",
                status="SUCCESS",
                message=(
                    "Planning completed with REVIEW_REQUIRED. "
                    "Execution will not be queued until manual review."
                ),
                exit_code=0,
            )
            db.commit()

            return {
                "job_id": job_id,
                "status": "review_required",
                "celery_task_id": self.request.id,
            }

        return {
            "job_id": job_id,
            "status": job.status.value,
            "celery_task_id": self.request.id,
        }

    except Exception as exc:
        db.rollback()
        raise exc
    finally:
        db.close()