from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    APP_NAME: str = "software-install-mvp"
    APP_ENV: str = "local"
    APP_HOST: str = "0.0.0.0"
    APP_PORT: int = 8000
    LOG_LEVEL: str = "INFO"

    POSTGRES_HOST: str = "postgres"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "software_install"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"

    CELERY_BROKER_URL: str = "redis://redis:6379/0"
    CELERY_RESULT_BACKEND: str = "redis://redis:6379/0"

    CELERY_QUEUE_ORCHESTRATION: str = "job_orchestration"
    CELERY_QUEUE_PLANNING: str = "ai_planning"
    CELERY_QUEUE_EXECUTION: str = "execution"
    CELERY_QUEUE_VERIFICATION: str = "verification"
    CELERY_QUEUE_RECOVERY: str = "ai_recovery"

    AZURE_OPENAI_ENDPOINT: str = "https://458027-3271-resource.openai.azure.com/"
    AZURE_OPENAI_KEY: str = "Aus7vMhAK5AJB2srcsqIbRNblMcPvUv1Ph0eIKUWV51aMpcj95FGJQQJ99BFACHYHv6XJ3w3AAAAACOGKl0afz"
    AZURE_OPENAI_API_VERSION: str = "2024-02-01"
    AZURE_OPENAI_GPT_DEPLOYMENT: str = "gpt-4o"
    AZURE_OPENAI_EMBED_DEPLOYMENT: str = "text-embedding-3-small"

    AI_TOP_K: int = 3
    AI_MAX_CHUNK_SIZE: int = 1200
    AI_CHUNK_OVERLAP: int = 150
    AI_PROMPT_VERSION: str = "phase4-v1"
    AI_ENABLE_RECOVERY_LITE: bool = True
    AI_REVIEW_REQUIRED_ON_NO_GROUNDING: bool = True
    AI_EMBEDDING_DIMENSION: int = 1536

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def get_database_url(self) -> str:
        return (
            f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )


settings = Settings()