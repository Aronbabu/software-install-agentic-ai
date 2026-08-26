import logging
import uuid
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import Job, JobStep,JobStatus
from app.schemas import JobCreate, JobResponse,JobListResponse,JobStatusUpdate,ExecuteResponse,JobProgressResponse
from datetime import datetime
from app.services.job_lifecycle import update_job_status
from app.services.execution_service import execute_job
from app.queue.job_queue import enqueue_job


logger = logging.getLogger("app.routes.jobs")
router = APIRouter(prefix="/api/v1/jobs", tags=["jobs"])


@router.post("", response_model=JobResponse, status_code=status.HTTP_201_CREATED)
def create_job(payload: JobCreate, request: Request, db: Session = Depends(get_db)):
    trace_id = getattr(request.state, "trace_id", str(uuid.uuid4()))
    job = Job(
        id=str(uuid.uuid4()), 
        ticket_id=payload.ticket_id,
        module="sw-install",
        status=JobStatus.PENDING,
        target_host=payload.target_host,
        os_type=payload.os_type.lower(),
        software_name=payload.software_name,
        software_version=payload.software_version,
        requested_by=payload.requested_by,
        justification=payload.justification,
        #trace_id=getattr(request.state, "trace_id", str(uuid.uuid4())),
        trace_id=trace_id,
        #below optional
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
        retry_count=0,
        max_retries=payload.max_retries or 3,
        timeout_seconds=payload.timeout_seconds or 300,
        execution_mode=payload.execution_mode or "immediate",
        scheduled_time=payload.scheduled_time,

    )

    db.add(job)
    db.flush()

    initial_step = JobStep(
        job_id=job.id,
        step_name="job_received",
        status="SUCCESS",
        message="Job request accepted and stored",
        exit_code=0,
        #below optional
        created_at=datetime.utcnow(),
    )
    db.add(initial_step)

    db.commit()
    db.refresh(job)
    logger.info("job_created job_id=%s ticket_id=%s trace_id=%s", job.id, job.ticket_id, trace_id)
    return job

@router.get("", response_model=JobListResponse)
def list_jobs(db: Session = Depends(get_db)):
    jobs = db.query(Job).order_by(Job.created_at.desc()).all()
    return JobListResponse(items=jobs, total=len(jobs))

@router.get("/{job_id}", response_model=JobResponse)
def get_job(job_id: str, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    return job

@router.patch("/{job_id}/status", response_model=JobResponse)
def patch_job_status(job_id: str, payload: JobStatusUpdate, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    try:
        job = update_job_status(db=db, job=job, new_status=payload.status, message=payload.message)
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    logger.info("job_status_updated job_id=%s new_status=%s", job.id, job.status.value)
    return job

@router.post("/{job_id}/simulate-run", response_model=JobResponse)
def simulate_job_run(job_id: str, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    try:
        if job.status == JobStatus.PENDING:
            job = update_job_status(db=db, job=job, new_status=JobStatus.VALIDATING, message="Validation started")
        if job.status == JobStatus.VALIDATING:
            job = update_job_status(db=db, job=job, new_status=JobStatus.RUNNING, message="Execution started")
        if job.status == JobStatus.RUNNING:
            job = update_job_status(db=db, job=job, new_status=JobStatus.VERIFYING, message="Verification started")
        if job.status == JobStatus.VERIFYING:
            job = update_job_status(db=db, job=job, new_status=JobStatus.SUCCESS, message="Job completed successfully")
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc))

    return job


@router.post("/{job_id}/execute", response_model=ExecuteResponse)
def execute(job_id: str, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    if job.execution_mode == "scheduled" and job.scheduled_time:
        if job.scheduled_time > datetime.utcnow():
            raise HTTPException(status_code=400, detail="Job is scheduled for later execution")
    if job.status in [JobStatus.SUCCESS, JobStatus.FAILED, JobStatus.FAILED_FINAL]:
        raise HTTPException(status_code=400, detail="Job already completed")

    enqueue_job(job.id)
    return ExecuteResponse(job_id=job.id, message="Job queued for execution")


@router.get("/{job_id}/progress",response_model=JobProgressResponse)
def get_job_progress(job_id: str, db: Session = Depends(get_db)):
    job = db.query(Job).filter(Job.id == job_id).first()

    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    steps = db.query(JobStep).filter(JobStep.job_id == job_id).order_by(JobStep.created_at).all()

    return {
        "job_id": job.id,
        "status": job.status,
        "trace_id": job.trace_id,
        "last_error": job.last_error,         
        "retry_count": job.retry_count,       
        "max_retries": job.max_retries,

        "steps": [
            {
                "id": s.id,
                "step_name": s.step_name,
                "status": s.status,
                "message": s.message,
                "exit_code": s.exit_code,
                "created_at": s.created_at,
            }
            for s in steps
        ]
    }
