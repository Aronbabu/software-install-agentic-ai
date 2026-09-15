import uuid
from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, String, Text

from app.db.base import Base


class ExecutionPlan(Base):
    __tablename__ = "execution_plans"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    job_id = Column(String, nullable=False, index=True)
    ai_request_id = Column(String, nullable=True)
    ai_response_id = Column(String, nullable=True)

    summary = Column(Text, nullable=True)
    target_platform = Column(String, nullable=True)

    preconditions_json = Column(Text, nullable=True)
    install_steps_json = Column(Text, nullable=True)
    verify_steps_json = Column(Text, nullable=True)
    rollback_steps_json = Column(Text, nullable=True)
    risks_json = Column(Text, nullable=True)

    selected_sop_reference = Column(String, nullable=True)
    retrieved_references_json = Column(Text, nullable=True)

    review_status = Column(String, nullable=True)
    approved_for_execution = Column(Boolean, nullable=False, default=False)

    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )