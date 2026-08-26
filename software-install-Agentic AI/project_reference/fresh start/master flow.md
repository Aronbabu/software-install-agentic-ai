CLIENT
  │
  ▼
FastAPI Gateway
  │
Request Normalizer
  │
Platform Control Plane
  │
Create Job
  │
Redis Planning Queue
  │
Celery Planning Worker
  │
Request Agent
  │
Knowledge Agent
  │
Planner Agent
  │
Policy Agent
  │
Execution Plan Artifact
  │
WAITING_APPROVAL (optional)
  │
APPROVAL_RECEIVED
  │
Redis Execution Queue
  │
Celery Execution Worker
  │
Execution Agent
  │
MCP Gateway
  │
 ├── Windows MCP
 │      │
 │      └── OpenSSH / WinRM
 │
 ├── Linux MCP
 │      │
 │      └── SSH / Bash
 │
 ├── ServiceNow MCP
 │
 └── Future MCPs
  │
Target Systems
  │
Verification Agent
  │
Audit Agent
  │
Reporting Agent
  │
ServiceNow Update
Portal Update
Knowledge Update

----------------------

ServiceNow
Admin Portal
Future APIs
       │
       ▼

FastAPI Gateway
       │
       ▼

Request Normalizer
       │
       ├── Validate Request
       ├── Request Classification
       ├── Correlation ID
       ├── Common Request Model
       └── Metadata Enrichment
       │
       ▼

Platform Control Plane
       │
       ├── Request Manager
       ├── Job Lifecycle Manager
       ├── Module Router
       ├── Policy Coordinator
       ├── Audit Manager
       └── Notification Manager
       │
       ▼

Create Job
Store Job Metadata
(PostgreSQL)

       │
       ▼

Redis Planning Queue