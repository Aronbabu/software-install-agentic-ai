from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field
from app.models import JobStatus

class JobCreate(BaseModel):
    ticket_id: str = Field(..., description="Ticket or RITM number")
    target_host: str
    os_type: str
    software_name: str
    software_version: Optional[str] = None
    requested_by: Optional[str] = None
    justification: Optional[str] = None
    max_retries: Optional[int] = 3
    timeout_seconds: Optional[int] = 300
    
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

    class Config:
        from_attributes = True


class JobResponse(BaseModel):
    id: str
    ticket_id: str
    module: str
    status: JobStatus
    target_host: str
    os_type: str
    software_name: str
    software_version: Optional[str] = None
    requested_by: Optional[str] = None
    justification: Optional[str] = None
    trace_id: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    steps: List[JobStepResponse] = []

    class Config:
        from_attributes = True

class JobListResponse(BaseModel):
    items: List[JobResponse]
    total: int

#optional health check response model
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
    steps: list
