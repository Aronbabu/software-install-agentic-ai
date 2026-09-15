import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, String, Text

from app.db.base import Base


class KnowledgeArticle(Base):
    __tablename__ = "knowledge_articles"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    title = Column(String, nullable=False)
    software_name = Column(String, nullable=True, index=True)
    platform = Column(String, nullable=True, index=True)
    source_path = Column(String, nullable=True)
    article_type = Column(String, nullable=False, default="troubleshooting")
    status = Column(String, nullable=False, default="ACTIVE")
    content_raw = Column(Text, nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(
        DateTime,
        nullable=False,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )