from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db import get_db
from app.models.job import Job

router = APIRouter(
    prefix="/api/v1/dashboard",
    tags=["Dashboard"]
)


@router.get("/summary")
def get_dashboard_summary(db: Session = Depends(get_db)):

    total_jobs = db.query(Job).count()

    running_jobs = (
        db.query(Job)
        .filter(Job.status == "RUNNING")
        .count()
    )

    success_jobs = (
        db.query(Job)
        .filter(Job.status == "SUCCESS")
        .count()
    )

    failed_jobs = (
        db.query(Job)
        .filter(
            Job.status.in_(
                ["FAILED", "FAILED_FINAL"]
            )
        )
        .count()
    )

    return {
        "total_jobs": total_jobs,
        "running_jobs": running_jobs,
        "success_jobs": success_jobs,
        "failed_jobs": failed_jobs,

        # placeholder for now
        "workers": 2
    }