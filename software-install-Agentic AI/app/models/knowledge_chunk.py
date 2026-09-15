from datetime import datetime

from pgvector.sqlalchemy import Vector
from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text

from app.config import settings
from app.db.base import Base


class KnowledgeChunk(Base):
    __tablename__ = "knowledge_chunks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    document_kind = Column(String, nullable=False)  # SOP | KNOWLEDGE
    sop_id = Column(String, ForeignKey("sop_repository.id"), nullable=True)
    knowledge_article_id = Column(
        String,
        ForeignKey("knowledge_articles.id"),
        nullable=True,
    )

    chunk_index = Column(Integer, nullable=False)
    chunk_text = Column(Text, nullable=False)
    embedding = Column(Vector(settings.AI_EMBEDDING_DIMENSION), nullable=True)

    software_name = Column(String, nullable=True, index=True)
    platform = Column(String, nullable=True, index=True)
    status = Column(String, nullable=False, default="ACTIVE")
    source_reference = Column(String, nullable=True)

    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)