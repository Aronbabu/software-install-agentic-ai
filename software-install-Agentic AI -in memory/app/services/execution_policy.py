APPROVED_PACKAGES = {
   
    "windows": {
        "7zip": {
            "install": "Write-Output \"Installing 7zip\"",
            "verify": "Get-Command 7z"
        },
        # ✅ BASIC FILE CREATION TEST
        "create_file": {
            "install": "New-Item -Path C:\\temp\\testfile.txt -ItemType File -Force",
            "verify": "Test-Path C:\\temp\\testfile.txt"
        },

        # ✅ DIRECTORY CREATION
        "create_folder": {
            "install": "New-Item -Path C:\\temp\\testfolder -ItemType Directory -Force",
            "verify": "Test-Path C:\\temp\\testfolder"
        },

        # ✅ SYSTEM INFO VALIDATION
        "check_hostname": {
            "install": "hostname",
            "verify": "hostname"
        },

        # ✅ SERVICE LIST CHECK
        "list_services": {
            "install": "Get-Service | Select-Object -First 5",
            "verify": "Get-Service | Select-Object -First 1"
        },

        # ✅ PROCESS CHECK
        "check_process": {
            "install": "Get-Process | Select-Object -First 5",
            "verify": "Get-Process | Select-Object -First 1"
        }

    },

    "linux": {
        "curl": {
            "install": "apt-get update && apt-get install -y curl",
            "verify": "which curl"
        },
        "vim": {
            "install": "apt-get install -y vim",
            "verify": "vim --version"
        }
    }
}

# "command": 'echo "Installing curl"'

def get_execution_command(os_type: str, software_name: str, software_version: str | None = None):
    os_type = (os_type or "").strip().lower()
    software_name = (software_name or "").strip().lower()

    try:
        return APPROVED_PACKAGES[os_type][software_name]
    except KeyError:
        raise ValueError(f"Software '{software_name}' not approved for os_type '{os_type}'")
