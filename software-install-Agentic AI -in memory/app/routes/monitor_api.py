from fastapi import APIRouter
from app.queue.job_queue import get_queue_status

from app.models import Job
from app.db import SessionLocal


router1= APIRouter(prefix="/api/v1/monitor", tags=["monitoring"])


@router1.get("/queue")
def get_queue():
    return get_queue_status()


@router1.get("/active-jobs")
def get_active_jobs():
    db = SessionLocal()

    jobs = db.query(Job).filter(
        Job.status.in_(["VALIDATING", "RUNNING", "VERIFYING"])
    ).all()

    return [
        {
            "job_id": j.id,
            "status": j.status
        }
        for j in jobs
    ]