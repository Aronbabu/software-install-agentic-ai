# Project Structure

Generated: 2026-08-27 12:46:11.545245

```text
software-install-Agentic AI
├── alembic
│   ├── versions
│   │   ├── 0001_create_jobs_and_job_steps.py
│   │   ├── 0002_extend_job_status_lifecycle.py
│   │   ├── 003_add_execution_fields.py
│   │   ├── 004_add_workflow_ready_fields.py
│   │   ├── 005_add_final_failed_final_statu.py
│   │   ├── 006_add_target_port_connection_method.py
│   │   └── 007_authorization_foundation_and_request_.py
│   ├── env.py
│   ├── env1.py
│   ├── README
│   └── script.py.mako
├── app
│   ├── db
│   │   ├── __init__.py
│   │   ├── base.py
│   │   ├── init_db.py
│   │   └── session.py
│   ├── executors
│   │   ├── __init__.py
│   │   ├── linux_executor.py
│   │   ├── result_models.py
│   │   └── windows_executor.py
│   ├── models
│   │   ├── __init__.py
│   │   ├── audit.py
│   │   ├── job.py
│   │   ├── ledger.py
│   │   └── security.py
│   ├── queue
│   │   ├── __init__.py
│   │   ├── job_queue.py
│   │   └── job_queue1.py
│   ├── routes
│   │   ├── __init__.py
│   │   ├── dashboard.py
│   │   ├── jobs.py
│   │   └── monitor_api.py
│   ├── services
│   │   ├── __init__.py
│   │   ├── audit_service.py
│   │   ├── authorization_service.py
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
│   └── schemas.py
├── entra-test
│   ├── .env
│   ├── app.py
│   └── requirements.txt
├── migrations
├── portal
│   ├── public
│   │   ├── favicon.svg
│   │   └── icons.svg
│   ├── src
│   │   ├── api
│   │   │   ├── client.ts
│   │   │   ├── dashboardApi.ts
│   │   │   ├── jobDetailsApi.ts
│   │   │   └── jobsApi.ts
│   │   ├── assets
│   │   │   ├── hero.png
│   │   │   ├── react.svg
│   │   │   └── vite.svg
│   │   ├── components
│   │   │   ├── layout
│   │   │   │   ├── AdminLayout.tsx
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   └── Topbar.tsx
│   │   │   └── status
│   │   │       └── StatusBadge.tsx
│   │   ├── pages
│   │   │   ├── Dashboard.tsx
│   │   │   ├── JobDetails.tsx
│   │   │   └── Jobs.tsx
│   │   ├── routes
│   │   │   └── routes.tsx
│   │   ├── types
│   │   │   ├── dashboard.ts
│   │   │   └── job.ts
│   │   ├── App.css
│   │   ├── App.tsx
│   │   ├── index.css
│   │   └── main.tsx
│   ├── .gitignore
│   ├── eslint.config.js
│   ├── index.html
│   ├── package-lock.json
│   ├── package.json
│   ├── README.md
│   ├── tsconfig.app.json
│   ├── tsconfig.json
│   ├── tsconfig.node.json
│   └── vite.config.ts
├── project_reference
│   ├── fresh start
│   │   ├── current_status.md
│   │   ├── master flow.md
│   │   └── new_hybrid_mvp_full.md
│   ├── Master_Context copy.md
│   ├── Master_Context.md
│   ├── Master_Context_ph2.md
│   ├── master_context_updated.txt
│   ├── Milestones.txt
│   ├── new_approach.md
│   ├── new_milestones.md
│   ├── new_plans.md
│   ├── new_project_scope.md
│   ├── new_scope_highlevel.md
│   ├── new_timeline.md
│   ├── Project_File_Inventory.csv
│   ├── project_metadata.yaml
│   ├── Project_Structure.md
│   ├── Project_Structure1.md
│   ├── Project_Structure2.md
│   ├── Project_Structure_work.md
│   └── ref.txt
├── python tools
│   ├── project_reference
│   │   ├── Project_File_Inventory.csv
│   │   └── Project_Structure.md
│   └── generate_project_structure.py
├── .dockerignore
├── .env
├── .env.example
├── alembic.ini
├── createfiest.py
├── deliverables
├── docker-compose copy 2.yml
├── docker-compose copy 3.yml
├── docker-compose copy.yml
├── docker-compose.yml
├── docker-compose_redis.yml
├── docker-compose_updated.yml
├── Dockerfile
├── fs2.txt
├── implementations.md
├── portal_implementations.md
├── README.md
├── redistest.py
├── ref
├── requirements.txt
├── test.py
└── test1.py
```