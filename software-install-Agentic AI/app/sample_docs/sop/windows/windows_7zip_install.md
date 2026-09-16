# SOP: Install 7-Zip on Windows

## Purpose
Install 7-Zip on an approved Windows target and verify that the application is available for use.

## Scope
- Platform: Windows
- Software: 7-Zip
- Installation source: approved source location with target staging before execution
- Intended target: approved Windows hosts with OpenSSH connectivity for MVP testing

## Source Metadata
- Installer Source Type: LOCAL_DEV_PATH
- Approved Source Reference: C:\Users\458027\OneDrive - Cognizant\D Drive\Learn\AIOps_HCS\installers\7zip_installer.exe
- Target Staging Path: C:\Temp\installers\7zip_installer.exe

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
Test-Path "C:\Temp\installers\7zip_installer.exe"
Start-Process -FilePath "C:\Temp\installers\7zip_installer.exe" -ArgumentList "/S" -Wait
```

## Verification Steps
1. Verify that the 7-Zip executable or application path is present.
2. Confirm installation by checking the executable location or command resolution.

## Example Verification Commands
```powershell
where.exe 7z
Get-Command 7z -ErrorAction SilentlyContinue
```

## Expected Verification Result
- `where.exe 7z` returns a valid path if present in PATH
- or `Get-Command 7z` resolves successfully

## Rollback Guidance
If rollback is required and approved, use the approved uninstall method for the installed 7-Zip package or product entry.

## Example Rollback Inspection Command
```powershell
Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*7-Zip*" }
```

## Failure / Troubleshooting Notes
- If the staged installer file does not exist, verify copy completed successfully or manually place the installer for dev testing
- If installation fails due to permission issues, verify elevated execution rights
- If verification fails, check whether the executable path requires a new session or explicit path lookup

## Source / Control Notes
- MVP-approved SOP sample
- Real target flow is copy-to-target-then-execute
- Dev testing may use manual pre-copy to the staging path
- Do not store secrets or unrestricted command sequences in the SOP