# Project Structure

Generated: 2026-09-09 11:17:55.443112

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
│   │   ├── 007_authorization_foundation_and_request_.py
│   │   ├── 008_28c39c6ee0ba_audit_foundation.py
│   │   ├── 009_861e52f4c182_minimum_decision_ledger.py
│   │   ├── 010_4d02e3285388_add_service_account_credentials_table.py
│   │   ├── 011_a809fac38d62_update_audit_fields.py
│   │   ├── 012_9a91edbf6e39_create_software_catalogue.py
│   │   ├── 013_255cda0c3fd2_add_notes_to_jobs.py
│   │   └── 014_20260908_phase4_slice1_foundation.py
│   ├── env.py
│   ├── README
│   └── script.py.mako
├── app
│   ├── ai
│   │   └── __init__.py
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
│   ├── knowledge
│   │   └── __init__.py
│   ├── models
│   │   ├── __init__.py
│   │   ├── ai_request.py
│   │   ├── ai_response.py
│   │   ├── audit.py
│   │   ├── catalogue.py
│   │   ├── catalogue_constants.py
│   │   ├── execution_plan.py
│   │   ├── job.py
│   │   ├── knowledge_article.py
│   │   ├── knowledge_chunk.py
│   │   ├── ledger.py
│   │   ├── security.py
│   │   └── sop_repository.py
│   ├── queue
│   │   ├── __init__.py
│   │   └── job_queue.py
│   ├── routes
│   │   ├── __init__.py
│   │   ├── catalogue_api.py
│   │   ├── dashboard.py
│   │   ├── jobs.py
│   │   ├── ledger_api.py
│   │   └── monitor_api.py
│   ├── schemas
│   │   └── job_create.py
│   ├── services
│   │   ├── __init__.py
│   │   ├── audit_service.py
│   │   ├── authorization_service.py
│   │   ├── catalogue_rules.py
│   │   ├── catalogue_service.py
│   │   ├── credential_provider.py
│   │   ├── execution_policy.py
│   │   ├── execution_service.py
│   │   ├── job_lifecycle.py
│   │   ├── job_service.py
│   │   └── ledger_service.py
│   ├── tasks
│   │   ├── __init__.py
│   │   ├── execution_tasks.py
│   │   ├── orchestration_tasks.py
│   │   └── planning_tasks.py
│   ├── workers
│   │   └── celery_worker.py
│   ├── __init__.py
│   ├── celery_app.py
│   ├── config.py
│   ├── db_legacy.py
│   ├── logging_config.py
│   ├── main.py
│   ├── middleware.py
│   ├── schemas_test.py
│   └── seed_catalogue.py
├── backup
│   └── phase3
│       ├── .env
│       ├── docker-compose.yml
│       ├── Dockerfile
│       └── phase3_software_install_demo_backup.sql
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
│   │   │   ├── auditApi.ts
│   │   │   ├── client.ts
│   │   │   ├── dashboardApi.ts
│   │   │   ├── jobDetailsApi.ts
│   │   │   └── jobsApi.ts
│   │   ├── assets
│   │   │   ├── hero.png
│   │   │   ├── react.svg
│   │   │   └── vite.svg
│   │   ├── auth
│   │   │   └── auth.ts
│   │   ├── components
│   │   │   ├── layout
│   │   │   │   ├── AdminLayout.tsx
│   │   │   │   ├── Breadcrumbs.tsx
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   └── Topbar.tsx
│   │   │   └── status
│   │   │       └── StatusBadge.tsx
│   │   ├── pages
│   │   │   ├── AuditLog.tsx
│   │   │   ├── Catalogue.tsx
│   │   │   ├── Dashboard.tsx
│   │   │   ├── JobDetails.tsx
│   │   │   ├── Jobs.tsx
│   │   │   ├── Login.tsx
│   │   │   └── NewJobRequest.tsx
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
│   ├── project_reference
│   │   ├── Project_File_Inventory.csv
│   │   └── Project_Structure.md
│   ├── generate_project_structure.py
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
│   └── project_reference
│       ├── Project_File_Inventory.csv
│       └── Project_Structure.md
├── scripts
├── .dockerignore
├── .env
├── .env.example
├── .env.local
├── .envbackup
├── alembic.ini
├── codebase_structure.txt
├── createfiest.py
├── deliverables
├── docker-compose copy 2.yml
├── docker-compose copy 3.yml
├── docker-compose copy.yml
├── docker-compose.local-infra.yml
├── docker-compose.yml
├── docker-compose_phase4.yml
├── docker-compose_redis.yml
├── docker-compose_updated.yml
├── Dockerfile
├── fs2.txt
├── implementations.md
├── locaenv.txt
├── portal_implementations.md
├── README.md
├── redistest.py
├── ref
├── repo_structure1.txt
├── repo_structure1stsep.txt
├── requirements.txt
├── test.py
├── test1.py
└── utility.py
```