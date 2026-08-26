from sqlalchemy.orm import Session
from app.models.job import Job, JobStatus, JobStep



ALLOWED_TRANSITIONS = {
    JobStatus.PENDING: [JobStatus.VALIDATING, JobStatus.FAILED, JobStatus.FAILED_FINAL],
    JobStatus.VALIDATING: [JobStatus.RUNNING, JobStatus.FAILED, JobStatus.FAILED_FINAL],
    JobStatus.RUNNING: [JobStatus.VERIFYING, JobStatus.FAILED, JobStatus.FAILED_FINAL],
    JobStatus.VERIFYING: [JobStatus.SUCCESS, JobStatus.FAILED, JobStatus.FAILED_FINAL],
    JobStatus.SUCCESS: [],
    JobStatus.FAILED: [JobStatus.FAILED_FINAL],
    JobStatus.FAILED_FINAL: [],
}



def validate_status_transition(current_status: JobStatus, new_status: JobStatus):
    allowed = ALLOWED_TRANSITIONS.get(current_status, [])
    if new_status not in allowed:
        raise ValueError(
            f"Invalid status transition: {current_status.value} -> {new_status.value}"
        )


def append_job_step(db: Session, job_id: str, step_name: str, status: str, message: str | None = None, exit_code: int | None = 0):
    step = JobStep(
        job_id=job_id,
        step_name=step_name,
        status=status,
        message=message,
        exit_code=exit_code,
    )
    db.add(step)
    return step


def update_job_status(db: Session, job: Job, new_status: JobStatus, message: str | None = None):
    validate_status_transition(job.status, new_status)

    job.status = new_status
    db.add(job)

    append_job_step(
        db=db,
        job_id=job.id,
        step_name=f"status_{new_status.value.lower()}",
        status=new_status.value,
        message=message,
        exit_code=0,
    )

    db.commit()
    db.refresh(job)
    return job
