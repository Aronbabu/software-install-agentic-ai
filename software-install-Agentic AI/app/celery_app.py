import os
from celery import Celery


CELERY_BROKER_URL = os.getenv(
    "CELERY_BROKER_URL",
    "redis://redis:6379/0"
)

CELERY_RESULT_BACKEND = os.getenv(
    "CELERY_RESULT_BACKEND",
    "redis://redis:6379/0"
)

celery_app = Celery(
    "software_install",
    broker=CELERY_BROKER_URL,
    backend=CELERY_RESULT_BACKEND,
    include=[
        "app.tasks.execution_tasks"
    ],
)
celery_app.conf.update(
    task_track_started=True,
    result_expires=3600,
    worker_send_task_events=True,
    task_send_sent_event=True,
)
celery_app.conf.task_track_started = True
celery_app.conf.result_expires = 3600

celery_app.autodiscover_tasks(["app.tasks"])
