from openai import AzureOpenAI

from app.config import settings


def get_azure_openai_client() -> AzureOpenAI:
    if not settings.AZURE_OPENAI_ENDPOINT:
        raise ValueError("AZURE_OPENAI_ENDPOINT is not configured")
    if not settings.AZURE_OPENAI_KEY:
        raise ValueError("AZURE_OPENAI_KEY is not configured")
    if not settings.AZURE_OPENAI_API_VERSION:
        raise ValueError("AZURE_OPENAI_API_VERSION is not configured")

    return AzureOpenAI(
        api_key=settings.AZURE_OPENAI_KEY,
        api_version=settings.AZURE_OPENAI_API_VERSION,
        azure_endpoint=settings.AZURE_OPENAI_ENDPOINT,
    )


def create_embedding(text: str) -> list[float]:
    if not text or not text.strip():
        raise ValueError("Embedding input text cannot be empty")

    client = get_azure_openai_client()
    response = client.embeddings.create(
        model=settings.AZURE_OPENAI_EMBED_DEPLOYMENT,
        input=text.strip(),
    )

    if not response.data or not response.data[0].embedding:
        raise ValueError("Azure OpenAI returned an empty embedding response")

    return response.data[0].embedding