from celery import Celery
from kombu import Queue
from app.config import settings


celery_app = Celery(
    "software_install",
    broker=settings.CELERY_BROKER_URL,
    backend=settings.CELERY_RESULT_BACKEND,
    include=[
        "app.tasks.orchestration_tasks",
        "app.tasks.planning_tasks",
        "app.tasks.execution_tasks",
    ],
)

celery_app.conf.update(
    task_track_started=True,
    result_expires=3600,
    worker_send_task_events=True,
    task_send_sent_event=True,
    task_default_queue=settings.CELERY_QUEUE_EXECUTION,
    task_queues=(
        Queue(settings.CELERY_QUEUE_ORCHESTRATION),
        Queue(settings.CELERY_QUEUE_PLANNING),
        Queue(settings.CELERY_QUEUE_EXECUTION),
        Queue(settings.CELERY_QUEUE_VERIFICATION),
        Queue(settings.CELERY_QUEUE_RECOVERY),
    ),
    task_routes={
        "app.tasks.orchestration_tasks.orchestrate_job_task": {
            "queue": settings.CELERY_QUEUE_ORCHESTRATION,
        },
        "app.tasks.planning_tasks.generate_plan_task": {
            "queue": settings.CELERY_QUEUE_PLANNING,
        },
        "app.tasks.execution_tasks.process_job_task": {
            "queue": settings.CELERY_QUEUE_EXECUTION,
        },
    },
)

celery_app.autodiscover_tasks(["app.tasks"])