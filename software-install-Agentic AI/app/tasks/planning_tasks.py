from app.celery_app import celery_app
from app.db import SessionLocal
from app.models.execution_plan import ExecutionPlan
from app.models.job import Job, JobStatus
from app.services.job_lifecycle import append_job_step, attach_plan_to_job, update_job_status
from app.config import settings


@celery_app.task(
    bind=True,
    name="app.tasks.planning_tasks.generate_plan_task",
    track_started=True,
)
def generate_plan_task(self, job_id: str):
    db = SessionLocal()
    try:
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

        # Slice 1 placeholder plan.
        plan = ExecutionPlan(
            job_id=job.id,
            summary=f"Placeholder Phase 4 plan for {job.software_name} on {job.os_type}",
            target_platform=job.os_type,
            review_status="PENDING_REVIEW",
            approved_for_execution=False,
            selected_sop_reference=None,
        )
        db.add(plan)
        db.commit()
        db.refresh(plan)

        attach_plan_to_job(db=db, job=job, execution_plan_id=plan.id)

        job = db.query(Job).filter(Job.id == job_id).first()
        update_job_status(
            db=db,
            job=job,
            new_status=JobStatus.PLAN_READY,
            message="Placeholder execution plan created.",
        )

        append_job_step(
            db=db,
            job_id=job.id,
            step_name="planning_completed",
            status="SUCCESS",
            message=f"Planning completed. execution_plan_id={plan.id}",
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
            "execution_plan_id": plan.id,
            "celery_task_id": self.request.id,
        }

    except Exception as exc:
        db.rollback()
        raise exc
    finally:
        db.close()