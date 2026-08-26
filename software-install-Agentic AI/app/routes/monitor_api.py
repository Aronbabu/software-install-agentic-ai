from fastapi import APIRouter
from app.celery_app import celery_app

router1 = APIRouter(
    prefix="/api/v1/monitor",
    tags=["monitor"]
)


@router1.get("/celery/health")
def celery_health():
    inspector = celery_app.control.inspect()
    ping_result = inspector.ping()

    if not ping_result:
        return {
            "status": "down",
            "message": "No Celery workers responded",
            "workers": []
        }

    return {
        "status": "up",
        "message": "Celery workers are responding",
        "workers": list(ping_result.keys()),
        "details": ping_result
    }


@router1.get("/celery/workers")
def celery_workers():
    inspector = celery_app.control.inspect()

    stats = inspector.stats()
    active = inspector.active()
    registered = inspector.registered()
    scheduled = inspector.scheduled()
    reserved = inspector.reserved()

    return {
        "stats": stats or {},
        "active": active or {},
        "registered": registered or {},
        "scheduled": scheduled or {},
        "reserved": reserved or {}
    }


@router1.get("/celery/tasks/active")
def active_tasks():
    inspector = celery_app.control.inspect()
    active = inspector.active()

    return {
        "active_tasks": active or {}
    }


@router1.get("/celery/tasks/scheduled")
def scheduled_tasks():
    inspector = celery_app.control.inspect()
    scheduled = inspector.scheduled()

    return {
        "scheduled_tasks": scheduled or {}
    }


@router1.get("/celery/tasks/reserved")
def reserved_tasks():
    inspector = celery_app.control.inspect()
    reserved = inspector.reserved()

    return {
        "reserved_tasks": reserved or {}
    }


@router1.get("/celery/tasks/registered")
def registered_tasks():
    inspector = celery_app.control.inspect()
    registered = inspector.registered()

    return {
        "registered_tasks": registered or {}
    }