# Project Structure

Generated: 2026-07-01 18:32:28.722576

```text
software-install-Agentic AI
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
│   │   └── job_queue.py
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
│   ├── __init__.py
│   ├── config.py
│   ├── db.py
│   ├── logging_config.py
│   ├── main.py
│   ├── middleware.py
│   ├── models.py
│   └── schemas.py
├── migrations
├── project_reference
├── python tools
│   └── generate_project_structure.py
├── .env
├── .env.example
├── alembic.ini
├── docker-compose.yml
├── README.md
└── requirements.txt
```