# Software Install MVP - Phase 1A

## What this phase includes
- FastAPI application
- PostgreSQL database
- jobs table
- job_steps table
- POST /api/v1/jobs
- GET /api/v1/jobs/{job_id}
- GET /api/v1/health

## Run locally

### 1. Start PostgreSQL
```bash
docker compose up -d

just run in gui the generate_project_structure.py

use host.docker.internal to acces other containers instead of actualname like postgres, ubuntu..et with port that is working

ex to connect postgre frm pgadmin container, both are container, used host.docker.internal 5432 worked with password