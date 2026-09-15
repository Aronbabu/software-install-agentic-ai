import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, String, Text

from app.db.base import Base


class AIRequest(Base):
    __tablename__ = "ai_requests"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    job_id = Column(String, nullable=False, index=True)
    request_type = Column(String, nullable=False)  # PLANNING | RECOVERY
    prompt_version = Column(String, nullable=False)
    model_name = Column(String, nullable=True)
    deployment_name = Column(String, nullable=True)
    input_context_json = Column(Text, nullable=True)
    retrieved_chunk_ids_json = Column(Text, nullable=True)
    trace_id = Column(String, nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)