from app.celery_app import celery_app
from app.config import settings
from app.db import SessionLocal
from app.models.job import Job
from app.services.job_lifecycle import append_job_step


@celery_app.task(
    bind=True,
    name="app.tasks.planning_tasks.generate_plan_task",
    track_started=True,
)
def generate_plan_task(self, job_id: str):
    db = SessionLocal()
    try:
        from app.ai.planning_service import plan_job

        job = db.query(Job).filter(Job.id == job_id).first()
        if not job:
            return {
                "job_id": job_id,
                "status": "not_found",
                "celery_task_id": self.request.id,
            }

        append_job_step(
            db=db,
            job_id=job.id,
            step_name="planning_started",
            status="SUCCESS",
            message=f"Planning worker started. celery_task_id={self.request.id}",
            exit_code=0,
        )
        db.commit()

        result = plan_job(db=db, job=job)

        if result.outcome.value == "REVIEW_REQUIRED":
            append_job_step(
                db=db,
                job_id=job.id,
                step_name="planning_review_required",
                status="SUCCESS",
                message=result.review.failure_reason if result.review else "Review required.",
                exit_code=0,
            )
            db.commit()

            return {
                "job_id": job_id,
                "status": "review_required",
                "execution_plan_id": result.execution_plan_id,
                "ai_request_id": result.ai_request_id,
                "ai_response_id": result.ai_response_id,
                "celery_task_id": self.request.id,
            }

        append_job_step(
            db=db,
            job_id=job.id,
            step_name="planning_completed",
            status="SUCCESS",
            message=f"Planning completed. execution_plan_id={result.execution_plan_id}",
            exit_code=0,
        )
        db.commit()

        celery_app.signature(
            "app.tasks.orchestration_tasks.orchestrate_job_task",
            args=[job_id],
            queue=settings.CELERY_QUEUE_ORCHESTRATION,
        ).apply_async()

        return {
            "job_id": job_id,
            "status": "plan_ready",
            "execution_plan_id": result.execution_plan_id,
            "ai_request_id": result.ai_request_id,
            "ai_response_id": result.ai_response_id,
            "celery_task_id": self.request.id,
        }

    except Exception as exc:
        db.rollback()
        raise exc
    finally:
        db.close()