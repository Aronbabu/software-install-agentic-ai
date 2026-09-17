from __future__ import annotations

from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class ReviewResolutionType(str, Enum):
    REUSE_PLAN = "REUSE_PLAN"
    USE_SOP = "USE_SOP"
    APPROVE_AI_PLAN = "APPROVE_AI_PLAN"
    DEFER_TO_MANUAL = "DEFER_TO_MANUAL"


class ReviewResolutionRequest(BaseModel):
    resolution_type: ReviewResolutionType = Field(
        ...,
        description="How the operator resolved the manual review",
    )
    selected_plan_id: Optional[str] = Field(
        default=None,
        description="Existing approved execution plan to reuse",
    )
    selected_sop_id: Optional[str] = Field(
        default=None,
        description="Approved SOP reference to use",
    )
    operator_notes: Optional[str] = Field(
        default=None,
        description="Human review notes or rationale",
    )
    auto_queue_execution: bool = Field(
        default=True,
        description="Whether orchestration should be re-queued after resolution",
    )


class ReviewResolutionResponse(BaseModel):
    job_id: str
    status: str
    resolution_type: ReviewResolutionType
    execution_plan_id: Optional[str] = None
    selected_plan_id: Optional[str] = None
    selected_sop_id: Optional[str] = None
    message: str