from datetime import datetime
from typing import Optional, List, Literal

from pydantic import BaseModel, Field

from app.models.job import JobStatus


class JobCreate(BaseModel):
    # =====================================================
    # SOURCE OF TRUTH
    # =====================================================
    catalogue_id: Optional[str] = Field(
        default=None,
        description="Selected catalogue item ID",
    )

    # =====================================================
    # CORE JOB FIELDS
    # =====================================================
    ticket_id: str = Field(..., description="Ticket or RITM number")
    target_host: str
    target_port: int = Field(default=22, description="SSH port")
    connection_method: str = Field(default="openssh", description="openssh or winrm")
    os_type: str = Field(..., description="linux or windows")
    software_name: Optional[str] = None
    software_version: Optional[str] = None

    # =====================================================
    # REQUEST METADATA
    # =====================================================
    request_source: Literal[
        "ADMIN_PORTAL",
        "SERVICENOW",
        "AI_ASSIST",
        "API",
    ] = "ADMIN_PORTAL"

    request_reference: Optional[str] = Field(
        default=None,
        description="ServiceNow RITM/request number or external reference",
    )

    requested_by: Optional[str] = Field(
        default=None,
        description="Username requesting the job (portal) or service account (servicenow)",
    )

    justification: Optional[str] = None
    notes: Optional[str] = None

    # =====================================================
    # EXECUTION OPTIONS
    # =====================================================
    max_retries: Optional[int] = 3
    timeout_seconds: Optional[int] = 300
    execution_mode: Optional[str] = "immediate"
    scheduled_time: Optional[datetime] = None


class JobStatusUpdate(BaseModel):
    status: JobStatus
    message: Optional[str] = None


class JobStepResponse(BaseModel):
    id: int
    step_name: str
    status: str
    message: Optional[str] = None
    exit_code: Optional[int] = None
    created_at: datetime

    model_config = {"from_attributes": True}


class JobResponse(BaseModel):
    id: str
    ticket_id: str
    module: str
    status: JobStatus
    target_host: str
    target_port: int
    connection_method: str
    os_type: str
    software_name: str
    software_version: Optional[str] = None
    requested_by: Optional[str] = None
    justification: Optional[str] = None
    notes: Optional[str] = None
    trace_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    steps: List[JobStepResponse] = Field(default_factory=list)
    request_source: str
    request_reference: Optional[str] = None
    execution_mode: Optional[str] = None

    model_config = {"from_attributes": True}


class JobListResponse(BaseModel):
    items: List[JobResponse]
    total: int


class HealthResponse(BaseModel):
    status: str
    app: str
    environment: str
    database: str


class ExecuteResponse(BaseModel):
    job_id: str
    message: str


class JobProgressResponse(BaseModel):
    job_id: str
    status: JobStatus
    trace_id: Optional[str] = None
    steps: List[JobStepResponse] = Field(default_factory=list)