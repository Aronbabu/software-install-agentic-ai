# SOP: Install Notepad++ on Windows

## Purpose
Install Notepad++ on an approved Windows target and verify that the application is available for use.

## Scope
- Platform: Windows
- Software: Notepad++
- Installation source: approved source location with target staging before execution
- Intended target: approved Windows hosts with OpenSSH connectivity for MVP testing

## Source Metadata
- Installer Source Type: LOCAL_DEV_PATH
- Approved Source Reference: C:\Users\458027\OneDrive - Cognizant\D Drive\Learn\AIOps_HCS\installers\notepadpp_installer.exe
- Target Staging Path: C:\Temp\installers\notepadpp_installer.exe

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
Test-Path "C:\Temp\installers\notepadpp_installer.exe"
Start-Process -FilePath "C:\Temp\installers\notepadpp_installer.exe" -ArgumentList "/S" -Wait
```

## Verification Steps
1. Verify the Notepad++ executable location.
2. Confirm that the executable is available through a command lookup or expected install path.

## Example Verification Commands
```powershell
where.exe notepad++
Get-ChildItem "C:\Program Files\Notepad++" -ErrorAction SilentlyContinue
```

## Expected Verification Result
- `where.exe notepad++` returns a path if available in PATH
- or the installation directory exists under `C:\Program Files\Notepad++`

## Rollback Guidance
If rollback is required and approved, use the approved uninstall method for the installed Notepad++ package or product entry.

## Example Rollback Inspection Command
```powershell
Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*Notepad++*" }
```

## Failure / Troubleshooting Notes
- If the staged installer file does not exist, verify copy completed successfully or manually place the installer for dev testing
- If installation appears successful but verification fails, validate install directory and path propagation
- If privilege issues occur, confirm the execution context is approved for software installation

## Source / Control Notes
- MVP-approved SOP sample
- Real target flow is copy-to-target-then-execute
- Dev testing may use manual pre-copy to the staging path
- Do not store secrets or unrestricted command sequences in the SOP