from datetime import datetime
from typing import Optional, List, Literal
from pydantic import BaseModel, Field
from app.models.job import JobStatus

class JobCreate(BaseModel):
    ticket_id: str = Field(..., description="Ticket or RITM number")
    target_host: str
    target_port: int = 22
    connection_method: str = "openssh"
    os_type: str
    software_name: str
    software_version: Optional[str] = None
    requested_by: Optional[str] = None
    justification: Optional[str] = None
    max_retries: Optional[int] = 3
    timeout_seconds: Optional[int] = 300
    request_source: Literal[
        "ADMIN_PORTAL",
        "SERVICENOW",
        "AI_ASSIST",
        "API",
    ] = "ADMIN_PORTAL"
    request_reference: Optional[str] = None

    # workflow-ready placeholders
    execution_mode: Optional[str] = "immediate"   # immediate / scheduled
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

    # pydantic v2: allow parsing from ORM/attribute objects
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
    trace_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    steps: List[JobStepResponse] = Field(default_factory=list)
    request_source: str
    request_reference: Optional[str] = None
    execution_mode: Optional[str] = None
    

    # pydantic v2: allow parsing from ORM/attribute objects
    model_config = {"from_attributes": True}

class JobListResponse(BaseModel):
    items: List[JobResponse]
    total: int

# optional health check response model
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