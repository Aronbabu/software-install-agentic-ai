from app.config import settings


def chunk_text(
    text: str,
    chunk_size: int | None = None,
    overlap: int | None = None,
) -> list[str]:
    if not text or not text.strip():
        return []

    chunk_size = chunk_size or settings.AI_MAX_CHUNK_SIZE
    overlap = overlap or settings.AI_CHUNK_OVERLAP

    if chunk_size <= 0:
        raise ValueError("chunk_size must be greater than 0")
    if overlap < 0:
        raise ValueError("overlap cannot be negative")
    if overlap >= chunk_size:
        raise ValueError("overlap must be smaller than chunk_size")

    normalized = " ".join(text.split())
    if len(normalized) <= chunk_size:
        return [normalized]

    chunks: list[str] = []
    start = 0

    while start < len(normalized):
        end = start + chunk_size
        chunk = normalized[start:end].strip()

        if chunk:
            chunks.append(chunk)

        if end >= len(normalized):
            break

        start = end - overlap

    return chunks