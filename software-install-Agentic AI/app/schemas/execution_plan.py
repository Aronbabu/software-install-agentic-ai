from __future__ import annotations

from datetime import datetime
from typing import Optional, List

from pydantic import BaseModel, Field


class ExecutionPlanSummaryResponse(BaseModel):
    id: str
    job_id: str
    ai_request_id: Optional[str] = None
    ai_response_id: Optional[str] = None
    summary: Optional[str] = None
    target_platform: Optional[str] = None
    selected_sop_reference: Optional[str] = None
    review_status: Optional[str] = None
    approved_for_execution: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class ExecutionPlanListResponse(BaseModel):
    items: List[ExecutionPlanSummaryResponse] = Field(default_factory=list)
    total: int