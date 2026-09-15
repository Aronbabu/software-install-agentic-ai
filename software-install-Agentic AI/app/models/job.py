import enum
import uuid
from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy import Enum as SqlEnum
from sqlalchemy.orm import relationship

from app.db.base import Base


class JobStatus(str, enum.Enum):
    PENDING = "PENDING"
    VALIDATING = "VALIDATING"
    PLANNING = "PLANNING"
    PLAN_READY = "PLAN_READY"
    RUNNING = "RUNNING"
    VERIFYING = "VERIFYING"
    SUCCESS = "SUCCESS"
    FAILED = "FAILED"
    REVIEW_REQUIRED = "REVIEW_REQUIRED"
    FAILED_FINAL = "FAILED_FINAL"


class Job(Base):
    __tablename__ = "jobs"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    ticket_id = Column(String, nullable=False, index=True)
    module = Column(String, nullable=False, default="sw-install")
    status = Column(
        SqlEnum(
            JobStatus,
            name="job_status",
            create_constraint=False,
            validate_strings=True,
        ),
        nullable=False,
        default=JobStatus.PENDING,
    )

    target_host = Column(String, nullable=False)
    target_port = Column(Integer, nullable=False, default=22)
    connection_method = Column(String(20), nullable=False, default="openssh")

    request_source = Column(String(50), nullable=False, default="ADMIN_PORTAL")
    request_reference = Column(String(255), nullable=True)

    os_type = Column(String, nullable=False)
    software_name = Column(String, nullable=False)
    software_version = Column(String, nullable=True)

    requested_by = Column(String, nullable=True)
    justification = Column(Text, nullable=True)
    trace_id = Column(String, nullable=True)

    retry_count = Column(Integer, nullable=False, default=0)
    max_retries = Column(Integer, nullable=False, default=3)
    timeout_seconds = Column(Integer, nullable=False, default=300)
    last_error = Column(Text, nullable=True)

    execution_mode = Column(String, default="immediate")
    scheduled_time = Column(DateTime, nullable=True)

    notes = Column(Text, nullable=True)

    current_plan_id = Column(String, nullable=True)
    operator_review_required = Column(Boolean, nullable=False, default=False)
    review_reason = Column(Text, nullable=True)

    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

    steps = relationship("JobStep", back_populates="job", cascade="all, delete-orphan")


class JobStep(Base):
    __tablename__ = "job_steps"

    id = Column(Integer, primary_key=True, autoincrement=True)
    job_id = Column(
        String,
        ForeignKey("jobs.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    step_name = Column(String, nullable=False)
    status = Column(String, nullable=False, default="PENDING")
    message = Column(Text, nullable=True)
    exit_code = Column(Integer, nullable=True)

    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    job = relationship("Job", back_populates="steps")