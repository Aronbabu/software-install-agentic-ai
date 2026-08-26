# app/celery_app.py
from celery import Celery

celery_app = Celery(
    "software_install",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/1"
)


celery_app.conf.task_track_started = True
celery_app.autodiscover_tasks(["app.tasks"])

