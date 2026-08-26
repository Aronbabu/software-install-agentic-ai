from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from sqlalchemy import text
from contextlib import asynccontextmanager

from app.config import settings
from app.db import engine
from app.middleware import RequestContextMiddleware
from app.logging_config import configure_logging
from app.routes.jobs import router as jobs_router
from app.routes.monitor_api import router1 as monitoring_router
from app.routes.dashboard import router as dashboard_router
from fastapi.middleware.cors import CORSMiddleware




configure_logging()


# ✅ lifespan (startup + shutdown)
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 FastAPI Started")
    yield
    print("🛑 FastAPI Stopped")


# ✅ ONLY ONE app instance
app = FastAPI(
    title=settings.APP_NAME,
    version="0.1.0",
    description="Agentic AI Software Install Platform - Redis Celery Mode",
    lifespan=lifespan
)

# ✅ Middleware
app.add_middleware(RequestContextMiddleware)

# ✅ Routers (IMPORTANT)
app.include_router(jobs_router)
app.include_router(monitoring_router)
app.include_router(dashboard_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Root
@app.get("/", tags=["root"])
def root():
    return {
        "message": "Software Install API is running",
        "mode": "redis-celery",
        "docs": "/docs"
    }


# ✅ Health
@app.get("/api/v1/health", tags=["health"])
def health():
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
        db_status = "up"
    except Exception:
        db_status = "down"

    
    return {
            "api": "up",
            "database": db_status,
            "mode": "redis-celery",
        }



# ✅ Global Exception Handler
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "trace_id": getattr(request.state, "trace_id", None),
            "error": str(exc),
        },
    )