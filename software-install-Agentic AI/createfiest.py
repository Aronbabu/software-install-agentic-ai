import os
from pathlib import Path

# Define the root directory
ROOT_DIR = "portal"

# Define the files to be created relative to the root directory
FILES_TO_CREATE = [
    "package.json",
    "vite.config.ts",
    "src/main.tsx",
    "src/App.tsx",
    # API layer
    "src/api/client.ts",
    "src/api/jobsApi.ts",
    "src/api/monitorApi.ts",
    "src/api/auditApi.ts",
    "src/api/catalogApi.ts",
    "src/api/authApi.ts",
    # Components
    "src/components/layout/AdminLayout.tsx",
    "src/components/layout/Sidebar.tsx",
    "src/components/layout/Topbar.tsx",
    "src/components/cards/MetricCard.tsx",
    "src/components/tables/DataTable.tsx",
    "src/components/status/StatusBadge.tsx",
    # Pages
    "src/pages/Dashboard.tsx",
    "src/pages/Jobs.tsx",
    "src/pages/JobDetails.tsx",
    "src/pages/QueueWorkers.tsx",
    "src/pages/Audit.tsx",
    "src/pages/DecisionLedger.tsx",
    "src/pages/SoftwareCatalog.tsx",
    "src/pages/Authorization.tsx",
    "src/pages/Settings.tsx",
    # Routes, Types, and Styles
    "src/routes/routes.tsx",
    "src/types/job.ts",
    "src/types/audit.ts",
    "src/types/queue.ts",
    "src/types/catalog.ts",
    "src/styles/theme.css",
]

def generate_structure():
    print(f"Creating directory structure under: {os.path.abspath(ROOT_DIR)}")
    
    for file_path_str in FILES_TO_CREATE:
        # Combine root directory with the target file path
        full_path = Path(ROOT_DIR) / file_path_str
        
        # Automatically create any missing parent directories
        full_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Create the file if it doesn't exist
        full_path.touch(exist_ok=True)
        print(f" Created: {full_path}")

    print("\nProject scaffolded successfully!")

if __name__ == "__main__":
    generate_structure()