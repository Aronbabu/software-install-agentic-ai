# Project Structure

Generated: 2026-08-17 14:14:53.179458

```text
AGENTIC AI SOFTWARE INSTALLATION PLATFORM
├── alembic
│   ├── versions
│   │   ├── 0001_create_jobs_and_job_steps.py
│   │   ├── 0002_extend_job_status_lifecycle.py
│   │   ├── 003_add_execution_fields.py
│   │   ├── 004_add_workflow_ready_fields.py
│   │   └── 005_add_final_failed_final_statu.py
│   ├── env.py
│   ├── env1.py
│   ├── README
│   └── script.py.mako
├── app
│   ├── executors
│   │   ├── __init__.py
│   │   ├── linux_executor.py
│   │   ├── result_models.py
│   │   └── windows_executor.py
│   ├── queue
│   │   ├── __init__.py
│   │   ├── job_queue.py
│   │   └── job_queue1.py
│   ├── routes
│   │   ├── __init__.py
│   │   ├── jobs.py
│   │   └── monitor_api.py
│   ├── services
│   │   ├── __init__.py
│   │   ├── credential_provider.py
│   │   ├── execution_policy.py
│   │   ├── execution_service.py
│   │   └── job_lifecycle.py
│   ├── tasks
│   │   ├── __init__.py
│   │   └── execution_tasks.py
│   ├── workers
│   │   └── celery_worker.py
│   ├── __init__.py
│   ├── celery_app.py
│   ├── config.py
│   ├── db.py
│   ├── logging_config.py
│   ├── main.py
│   ├── middleware.py
│   ├── models.py
│   └── schemas.py
├── migrations
├── .env
├── .env.example
├── alembic.ini
├── deliverables
├── docker-compose copy 2.yml
├── docker-compose copy 3.yml
├── docker-compose copy.yml
├── docker-compose.yml
├── docker-compose_redis.yml
├── docker-compose_updated.yml
├── Dockerfile
├── fs2.txt
├── README.md
├── redistest.py
└── requirements.txt
```