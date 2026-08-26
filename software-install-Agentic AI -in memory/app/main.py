from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from sqlalchemy import text
from contextlib import asynccontextmanager

from app.config import settings
from app.db import engine
from app.middleware import RequestContextMiddleware
from app.logging_config import configure_logging
from app.queue.job_queue import start_workers, stop_workers
from app.services.execution_service import process_job

from app.routes.jobs import router as jobs_router
from app.routes.monitor_api import router1 as monitoring_router

configure_logging()


# ✅ lifespan (startup + shutdown)
@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Starting workers...")
    start_workers(worker_count=3, worker_handler=process_job)

    yield

    print("🛑 Stopping workers...")
    stop_workers()


# ✅ ONLY ONE app instance
app = FastAPI(
    title=settings.APP_NAME,
    version="0.1.0",
    description="Minimal Agentic AI Software Install MVP - Phase 2",
    lifespan=lifespan
)

# ✅ Middleware
app.add_middleware(RequestContextMiddleware)

# ✅ Routers (IMPORTANT)
app.include_router(jobs_router)
app.include_router(monitoring_router)


# ✅ Root
@app.get("/", tags=["root"])
def root():
    return {
        "message": "Software Install MVP API is running",
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
        "status": "ok" if db_status == "up" else "degraded"
    }


# ✅ Global Exception Handler
@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "trace_id": getattr(request.state, "trace_id", None)
        }
    )