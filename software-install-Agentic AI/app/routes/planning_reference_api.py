from __future__ import annotations

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.db import get_db
from app.models.execution_plan import ExecutionPlan
from app.models.sop_repository import SOPRepository
from app.schemas.execution_plan import (
    ExecutionPlanSummaryResponse,
    ExecutionPlanListResponse,
)
from app.schemas.sop_repository import (
    SOPRepositorySummaryResponse,
    SOPRepositoryListResponse,
)

router = APIRouter(prefix="/api/v1", tags=["planning-reference"])


@router.get("/execution-plans", response_model=ExecutionPlanListResponse)
def list_execution_plans(
    db: Session = Depends(get_db),
    status: str | None = Query(default=None),
    platform: str | None = Query(default=None),
    approved_only: bool = Query(default=False),
):
    query = db.query(ExecutionPlan)

    if status:
        query = query.filter(ExecutionPlan.review_status == status)

    if platform:
        query = query.filter(ExecutionPlan.target_platform == platform)

    if approved_only:
        query = query.filter(ExecutionPlan.review_status == "APPROVED")
        query = query.filter(ExecutionPlan.approved_for_execution.is_(True))

    items = query.order_by(ExecutionPlan.created_at.desc()).all()

    return ExecutionPlanListResponse(
        items=[ExecutionPlanSummaryResponse.model_validate(item) for item in items],
        total=len(items),
    )


@router.get("/sops", response_model=SOPRepositoryListResponse)
def list_sops(
    db: Session = Depends(get_db),
    status: str | None = Query(default=None),
    platform: str | None = Query(default=None),
    software_name: str | None = Query(default=None),
):
    query = db.query(SOPRepository)

    if status:
        query = query.filter(SOPRepository.status == status)

    if platform:
        query = query.filter(SOPRepository.platform == platform)

    if software_name:
        query = query.filter(SOPRepository.software_name == software_name)

    items = query.order_by(SOPRepository.created_at.desc()).all()

    return SOPRepositoryListResponse(
        items=[SOPRepositorySummaryResponse.model_validate(item) for item in items],
        total=len(items),
    )