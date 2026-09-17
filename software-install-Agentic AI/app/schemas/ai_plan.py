from __future__ import annotations

from enum import Enum
from typing import Any, Optional

from pydantic import BaseModel, Field


class PlanSource(str, Enum):
    REUSED = "REUSED"
    SOP_DIRECT = "SOP_DIRECT"
    AI = "AI"
    REVIEW_REQUIRED = "REVIEW_REQUIRED"


class PlanReference(BaseModel):
    source_type: str = Field(..., description="SOP, KNOWLEDGE, REUSED_PLAN, etc.")
    reference_id: Optional[str] = Field(default=None)
    reference_title: Optional[str] = Field(default=None)
    source_path: Optional[str] = Field(default=None)
    chunk_id: Optional[str] = Field(default=None)
    chunk_index: Optional[int] = Field(default=None)
    relevance_score: Optional[float] = Field(default=None)
    excerpt: Optional[str] = Field(default=None)


class ExecutionPlanPayload(BaseModel):
    software_name: str
    platform: str
    version: Optional[str] = None
    request_type: Optional[str] = None

    plan_source: PlanSource
    reusable: bool = False

    summary: str
    prechecks: list[str] = Field(default_factory=list)
    install_steps: list[str] = Field(default_factory=list)
    verify_steps: list[str] = Field(default_factory=list)
    rollback_steps: list[str] = Field(default_factory=list)
    risks: list[str] = Field(default_factory=list)
    approved_parameters: list[str] = Field(default_factory=list)
    warnings: list[str] = Field(default_factory=list)
    assumptions: list[str] = Field(default_factory=list)
    references: list[PlanReference] = Field(default_factory=list)

    timeout_seconds: Optional[int] = None
    review_required: bool = False
    fingerprint: Optional[str] = None


class ReviewAdvisoryPayload(BaseModel):
    software_name: Optional[str] = None
    platform: Optional[str] = None
    version: Optional[str] = None
    request_type: Optional[str] = None

    review_required: bool = True
    failure_reason: str
    grounding_status: str = Field(
        default="INSUFFICIENT",
        description="INSUFFICIENT, PARTIAL, VALIDATION_FAILED, etc.",
    )
    advisory_recommendations: list[str] = Field(default_factory=list)
    suggested_operator_action: Optional[str] = None
    confidence_note: Optional[str] = None
    references: list[PlanReference] = Field(default_factory=list)
    raw_model_output: Optional[Any] = None


class PlanningResult(BaseModel):
    outcome: PlanSource
    plan: Optional[ExecutionPlanPayload] = None
    review: Optional[ReviewAdvisoryPayload] = None
    ai_request_id: Optional[str] = None
    ai_response_id: Optional[str] = None
    execution_plan_id: Optional[str] = None