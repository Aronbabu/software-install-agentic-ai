import logging
import uuid
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.job import Job, JobStep,JobStatus
from app.schemas import JobCreate, JobResponse,JobListResponse,JobStatusUpdate,ExecuteResponse,JobProgressResponse
from datetime import datetime
from app.services.job_lifecycle import update_job_status
from app.services.execution_service import execute_job
from app.tasks.execution_tasks import process_job_task
from app.services.authorization_service import AuthorizationService
from app.services.audit_service import AuditService
from app.models.security import AppUser
from datetime import datetime 
from app.services.job_lifecycle import update_job_status
from app.services.job_lifecycle import update_job_status, append_job_step

logger = logging.getLogger("app.routes.jobs")
router = APIRouter(prefix="/api/v1/jobs", tags=["jobs"])



def resolve_request_user(
    db: Session,
    requested_by: str,
    ) -> AppUser:
    user = (
        db.query(AppUser)
        .filter(
            AppUser.username == requested_by,
            AppUser.active.is_(True)
        )
        .first()
    )
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=(
                f"Active application user '{requested_by}' "
                "was not found"
            ),
        )

    return user

@router.post("", response_model=JobResponse, status_code=status.HTTP_201_CREATED)
def create_job(payload: JobCreate, request: Request, db: Session = Depends(get_db)):
    """
    Create a software installation job.
    
    Handles two paths:
    1. ServiceNow requests: Auto-queued, uses servicenow_svc service account
    2. Admin Portal requests: Manual execution, uses operator user
    
    Args:
        payload: JobCreate schema with job details
        request: FastAPI request object
        db: Database session
        
    Returns:
        JobResponse with created job details
        
    Raises:
        HTTPException 403: User not found or inactive
        HTTPException 403: Execution not authorized
    """
    
    trace_id = getattr(request.state, "trace_id", str(uuid.uuid4()))
    
    # =====================================================
    # STEP 1: Resolve the actor (who is creating this job)
    # =====================================================
    
    if payload.request_source == "SERVICENOW":
        # ✅ ServiceNow requests: Use service account
        actor_username = "servicenow_svc"
    else:
        # ✅ Portal requests: Use provided username
        actor_username = payload.requested_by
    
    try:
        user = resolve_request_user(db=db, requested_by=actor_username)
    except HTTPException:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Actor '{actor_username}' not found or inactive"
        )
    
    # =====================================================
    # STEP 2: Create the job record
    # =====================================================
    
    job = Job(
        id=str(uuid.uuid4()),
        ticket_id=payload.ticket_id,
        module="sw-install",
        status=JobStatus.PENDING,
        target_host=payload.target_host,
        os_type=payload.os_type.lower(),
        software_name=payload.software_name,
        software_version=payload.software_version,
        requested_by=actor_username,  # ✅ Store who is making the request
        justification=payload.justification,
        trace_id=trace_id,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
        retry_count=0,
        max_retries=payload.max_retries or 3,
        timeout_seconds=payload.timeout_seconds or 300,
        execution_mode=payload.execution_mode or "immediate",
        scheduled_time=payload.scheduled_time,
        target_port=payload.target_port,
        connection_method=payload.connection_method,
        request_source=payload.request_source,
        request_reference=payload.request_reference,
    )
    
    db.add(job)
    db.flush()
    
    # =====================================================
    # STEP 3: AUTHORIZATION CHECK
    # =====================================================
    
    allowed = AuthorizationService.authorize_execution(
        db=db,
        user_id=user.id,
        job_id=job.id,
        request_source=job.request_source,
        request_reference=job.request_reference,
        action="EXECUTE",
        target_host=job.target_host,
        connection_method=job.connection_method,
    )
    
    if not allowed:
        # ✅ Denied - record audit event
        AuditService.record_event(
            db=db,
            event_type="AUTHORIZATION_DENIED",
            request_source=job.request_source,
            request_reference=job.request_reference,
            job_id=job.id,
            actor_id=user.id,
            target_host=job.target_host,
            connection_method=job.connection_method,
            result="DENY",
            message=f"User '{actor_username}' is not authorized to create/execute this job"
        )
        db.commit()
        
        logger.warning(
            "job_creation_denied user=%s request_source=%s reason=insufficient_role",
            actor_username,
            job.request_source
        )
        
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Job creation/execution not authorized"
        )
    
    # ✅ Allowed - record audit event
    AuditService.record_event(
        db=db,
        event_type="AUTHORIZATION_ALLOWED",
        request_source=job.request_source,
        request_reference=job.request_reference,
        job_id=job.id,
        actor_id=user.id,
        target_host=job.target_host,
        connection_method=job.connection_method,
        result="ALLOW",
        message=f"User '{actor_username}' authorized to create/execute this job"
    )
    
    # =====================================================
    # STEP 4: Record JOB_CREATED audit event
    # =====================================================
    
    AuditService.record_event(
        db=db,
        event_type="JOB_CREATED",
        request_source=job.request_source,
        request_reference=job.request_reference,
        job_id=job.id,
        actor_id=user.id,
        target_host=job.target_host,
        connection_method=job.connection_method,
        result="SUCCESS",
        message=f"Job created from {job.request_source}"
    )
    
    db.commit()
    db.refresh(job)
    
    # =====================================================
    # STEP 5: Create initial job step
    # =====================================================
    
    initial_step = JobStep(
        job_id=job.id,
        step_name="job_received",
        status="SUCCESS",
        message="Job request accepted and stored",
        exit_code=0,
        created_at=datetime.utcnow(),
    )
    db.add(initial_step)
    db.commit()
    
    # =====================================================
    # STEP 6: AUTO-QUEUE FOR SERVICENOW REQUESTS
    # =====================================================
    
    if job.request_source == "SERVICENOW":
        # ✅ ServiceNow requests auto-execute
        try:
            task = process_job_task.delay(job.id)
            
            append_job_step(
                db=db,
                job_id=job.id,
                step_name="job_auto_queued",
                status="SUCCESS",
                message=f"ServiceNow request auto-queued. celery_task_id={task.id}",
                exit_code=0,
            )
            
            AuditService.record_event(
                db=db,
                event_type="JOB_AUTO_QUEUED",
                request_source=job.request_source,
                request_reference=job.request_reference,
                job_id=job.id,
                actor_id=user.id,
                target_host=job.target_host,
                connection_method=job.connection_method,
                result="QUEUED",
                message="ServiceNow request auto-queued for execution"
            )
            
            db.commit()
            
            logger.info(
                "job_auto_queued job_id=%s request_reference=%s trace_id=%s",
                job.id,
                job.request_reference,
                trace_id
            )
            
        except Exception as e:
            logger.error(
                "job_auto_queue_failed job_id=%s error=%s",
                job.id,
                str(e)
            )
            # Log but don't fail - job is created, just queuing failed
    
    else:
        # ✅ Portal requests remain PENDING for manual /execute call
        logger.info(
            "job_created_portal job_id=%s ticket_id=%s trace_id=%s",
            job.id,
            job.ticket_id,
            trace_id
        )
    
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
def execute(
    job_id: str, 
    db: Session = Depends(get_db)
):
    """
    Execute a job with authorization using the STORED requested_by.
    
    No need to pass requested_by - it's already stored in the job!
    
    Args:
        job_id: The job ID to execute
        db: Database session
        
    Returns:
        ExecuteResponse with job_id and message
        
    Raises:
        HTTPException 404: Job not found
        HTTPException 400: Job already completed or scheduled time not reached
        HTTPException 403: User not authorized to execute
    """
    
    # ✅ STEP 1: Get the job
    job = db.query(Job).filter(Job.id == job_id).first()
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    
    # ✅ STEP 2: Get the STORED actor (from when job was created)
    actor_username = job.requested_by
    
    # Resolve to AppUser object
    try:
        user = resolve_request_user(db=db, requested_by=actor_username)
    except HTTPException:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"User '{actor_username}' not found or inactive"
        )
    
    # ✅ STEP 3: Check execution eligibility (status, scheduled time)
    if job.execution_mode == "scheduled" and job.scheduled_time:
        if job.scheduled_time > datetime.utcnow():
            raise HTTPException(
                status_code=400, 
                detail="Job is scheduled for later execution"
            )
    
    if job.status in [JobStatus.SUCCESS, JobStatus.FAILED, JobStatus.FAILED_FINAL]:
        raise HTTPException(
            status_code=400, 
            detail="Job already completed"
        )
    
    # ✅ STEP 4: AUTHORIZATION CHECK using stored actor
    allowed = AuthorizationService.authorize_execution(
        db=db,
        user_id=user.id,
        job_id=job.id,
        request_source=job.request_source or "PORTAL",
        request_reference=job.request_reference,
        action="EXECUTE",
        target_host=job.target_host,
        connection_method=job.connection_method,
    )
    
    # ✅ STEP 5: If NOT authorized, record audit event and reject
    if not allowed:
        AuditService.record_event(
            db=db,
            event_type="EXECUTION_DENIED",
            request_source=job.request_source or "PORTAL",
            request_reference=job.request_reference,
            job_id=job.id,
            actor_id=user.id,
            target_host=job.target_host,
            connection_method=job.connection_method,
            result="DENY",
            message=f"User '{actor_username}' is not authorized to execute this job"
        )
        db.commit()
        
        logger.warning(
            "execution_denied user=%s job_id=%s target=%s reason=insufficient_role",
            actor_username,
            job.id,
            job.target_host
        )
        
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Execution not authorized"
        )
    
    # ✅ STEP 6: If authorized, record successful authorization audit event
    AuditService.record_event(
        db=db,
        event_type="EXECUTION_AUTHORIZED",
        request_source=job.request_source or "PORTAL",
        request_reference=job.request_reference,
        job_id=job.id,
        actor_id=user.id,
        target_host=job.target_host,
        connection_method=job.connection_method,
        result="ALLOW",
        message=f"User '{actor_username}' authorized to execute job"
    )
    
    db.commit()
    
    # ✅ STEP 7: Queue the job for execution
    if (
        job.execution_mode == "scheduled"
        and job.scheduled_time
    ):
        # Schedule for later
        process_job_task.apply_async(
            args=[job.id],
            eta=job.scheduled_time
        )
        
        message = f"Job scheduled for {job.scheduled_time}"
        
    else:
        # Execute immediately
        task = process_job_task.delay(job.id)
        
        append_job_step(
            db=db,
            job_id=job.id,
            step_name="job_queued",
            status="SUCCESS",
            message=f"Job queued to Celery. celery_task_id={task.id}",
            exit_code=0,
        )
        db.commit()
        
        message = "Job queued for execution"
    
    # ✅ STEP 8: Log and return success response
    logger.info(
        "job_execution_queued job_id=%s user=%s target=%s mode=%s",
        job.id,
        actor_username,
        job.target_host,
        job.execution_mode
    )
    
    return ExecuteResponse(
        job_id=job.id,
        message=message
    )

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
