from pathlib import Path

from sqlalchemy.orm import Session

from app.ai.embeddings_service import embed_text
from app.knowledge.chunking import chunk_text
from app.models.knowledge_article import KnowledgeArticle
from app.models.knowledge_chunk import KnowledgeChunk
from app.models.sop_repository import SOPRepository


def ingest_sop_document(
    db: Session,
    file_path: str,
    software_name: str,
    platform: str,
    software_version: str | None = None,
    owner: str | None = None,
    status: str = "ACTIVE",
) -> SOPRepository:
    path = Path(file_path)

    if not path.exists():
        raise FileNotFoundError(f"SOP file not found: {file_path}")

    content = path.read_text(encoding="utf-8").strip()
    if not content:
        raise ValueError(f"SOP file is empty: {file_path}")

    normalized_platform = platform.strip().lower()

    sop = SOPRepository(
        name=path.stem,
        software_name=software_name.strip(),
        software_version=software_version.strip() if software_version else None,
        platform=normalized_platform,
        document_type=path.suffix.replace(".", "") or "txt",
        source_path=str(path),
        owner=owner.strip() if owner else None,
        status=status,
        version=software_version.strip() if software_version else None,
        content_raw=content,
    )
    db.add(sop)
    db.commit()
    db.refresh(sop)

    chunks = chunk_text(content)

    for index, chunk in enumerate(chunks):
        embedding = embed_text(chunk)

        db.add(
            KnowledgeChunk(
                document_kind="SOP",
                sop_id=sop.id,
                chunk_index=index,
                chunk_text=chunk,
                embedding=embedding,
                software_name=software_name.strip(),
                platform=normalized_platform,
                status=status,
                source_reference=f"{path.name}#chunk-{index}",
            )
        )

    db.commit()
    return sop


def ingest_knowledge_article(
    db: Session,
    file_path: str,
    title: str,
    software_name: str | None = None,
    platform: str | None = None,
    status: str = "ACTIVE",
) -> KnowledgeArticle:
    path = Path(file_path)

    if not path.exists():
        raise FileNotFoundError(f"Knowledge file not found: {file_path}")

    content = path.read_text(encoding="utf-8").strip()
    if not content:
        raise ValueError(f"Knowledge file is empty: {file_path}")

    normalized_platform = platform.strip().lower() if platform else None

    article = KnowledgeArticle(
        title=title.strip(),
        software_name=software_name.strip() if software_name else None,
        platform=normalized_platform,
        source_path=str(path),
        article_type="troubleshooting",
        status=status,
        content_raw=content,
    )
    db.add(article)
    db.commit()
    db.refresh(article)

    chunks = chunk_text(content)

    for index, chunk in enumerate(chunks):
        embedding = embed_text(chunk)

        db.add(
            KnowledgeChunk(
                document_kind="KNOWLEDGE",
                knowledge_article_id=article.id,
                chunk_index=index,
                chunk_text=chunk,
                embedding=embedding,
                software_name=software_name.strip() if software_name else None,
                platform=normalized_platform,
                status=status,
                source_reference=f"{path.name}#chunk-{index}",
            )
        )

    db.commit()
    return article