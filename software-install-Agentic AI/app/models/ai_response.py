import uuid
from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, String, Text

from app.db.base import Base


class AIResponse(Base):
    __tablename__ = "ai_responses"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    ai_request_id = Column(String, nullable=False, index=True)
    job_id = Column(String, nullable=False, index=True)
    response_type = Column(String, nullable=False)
    response_json = Column(Text, nullable=True)
    review_status = Column(String, nullable=True)
    grounded = Column(Boolean, nullable=False, default=False)
    operator_review_required = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)