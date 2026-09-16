# SOP: Install Git on Windows

## Purpose
Install Git on an approved Windows target and verify that Git is available for use.

## Scope
- Platform: Windows
- Software: Git
- Installation source: approved source location with target staging before execution
- Intended target: approved Windows hosts with OpenSSH connectivity for MVP testing

## Source Metadata
- Installer Source Type: LOCAL_DEV_PATH
- Approved Source Reference: C:\Users\458027\OneDrive - Cognizant\D Drive\Learn\AIOps_HCS\installers\git_installer.exe
- Target Staging Path: C:\Temp\installers\git_installer.exe

## Dev Testing Note
For current local development/testing, the installer may be manually copied to the target staging path before execution if automated copy from the approved source is not yet enabled in the environment.

## Preconditions
- OpenSSH connectivity to the Windows target host is working
- User account has permission to copy files and install approved software
- Approved source file is available for staging, or the staged file is already manually placed for dev testing
- PowerShell is available on the target host
- Target host is an approved installation target

## Installation Steps
1. Confirm the approved source reference and target staging path.
2. If automated copy is available, copy the installer from the approved source reference to the target staging path.
3. If automated copy is not available in local development, manually place the installer at the target staging path.
4. Verify the installer file exists at the target staging path.
5. Run the installer silently from the target staging path.
6. Confirm the installation process completes without terminal error.

## Example Commands
```powershell
Test-Path "C:\Temp\installers\git_installer.exe"
Start-Process -FilePath "C:\Temp\installers\git_installer.exe" -ArgumentList "/VERYSILENT" -Wait
```

## Verification Steps
1. Verify that the `git` executable is available.
2. Confirm Git returns version output.

## Example Verification Commands
```powershell
git --version
where.exe git
```

## Expected Verification Result
- `git --version` returns installed version information
- `where.exe git` returns the path to the Git executable

## Rollback Guidance
If rollback is required and approved, use the approved uninstall method for the installed Git package or product entry.

## Example Rollback Inspection Command
```powershell
Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*Git*" }
```

## Failure / Troubleshooting Notes
- If the staged installer file does not exist, verify copy completed successfully or manually place the installer for dev testing
- If installation fails due to privilege issues, verify elevated execution rights
- If verification fails, confirm environment path refresh or validate executable location directly

## Source / Control Notes
- MVP-approved SOP sample
- Real target flow is copy-to-target-then-execute
- Dev testing may use manual pre-copy to the staging path
- Do not store secrets, passwords, or unrestricted command sequences in the SOP