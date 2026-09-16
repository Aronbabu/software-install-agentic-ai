from app.ai.azure_openai_client import create_embedding


def embed_text(text: str) -> list[float]:
    if not text or not text.strip():
        raise ValueError("Text for embedding cannot be empty")
    return create_embedding(text.strip())