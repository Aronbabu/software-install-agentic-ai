from sqlalchemy import text
from sqlalchemy.orm import Session

from app.ai.embeddings_service import embed_text
from app.config import settings


def retrieve_relevant_chunks(
    db: Session,
    query_text: str,
    software_name: str | None = None,
    platform: str | None = None,
    k: int | None = None,
) -> list[dict]:
    if not query_text or not query_text.strip():
        raise ValueError("query_text cannot be empty")

    k = k or settings.AI_TOP_K
    if k <= 0:
        raise ValueError("k must be greater than 0")

    normalized_software = software_name.strip() if software_name else None
    normalized_platform = platform.strip().lower() if platform else None

    query_embedding = embed_text(query_text.strip())

    sql = text(
        """
        SELECT
            id,
            document_kind,
            chunk_text,
            software_name,
            platform,
            source_reference,
            embedding <-> CAST(:embedding AS vector) AS distance
        FROM knowledge_chunks
        WHERE status = 'ACTIVE'
          AND (:software_name IS NULL OR software_name = :software_name)
          AND (:platform IS NULL OR platform = :platform)
        ORDER BY embedding <-> CAST(:embedding AS vector)
        LIMIT :k
        """
    )

    result = db.execute(
        sql,
        {
            "embedding": str(query_embedding),
            "software_name": normalized_software,
            "platform": normalized_platform,
            "k": k,
        },
    )

    return [dict(row) for row in result.mappings().all()]