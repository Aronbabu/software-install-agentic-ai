import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, String, Text

from app.db.base import Base


class SOPRepository(Base):
    __tablename__ = "sop_repository"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    name = Column(String, nullable=False)
    software_name = Column(String, nullable=False, index=True)
    software_version = Column(String, nullable=True)
    platform = Column(String, nullable=False, index=True)
    document_type = Column(String, nullable=False, default="markdown")
    source_path = Column(String, nullable=True)
    owner = Column(String, nullable=True)
    status = Column(String, nullable=False, default="ACTIVE")
    version = Column(String, nullable=True)
    content_raw = Column(Text, nullable=True)
    last_updated_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)