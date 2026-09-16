# Knowledge: Notepad++ Troubleshooting on Windows

## Purpose
Provide troubleshooting guidance when Notepad++ installation or verification fails on Windows targets.

## Scope
- Platform: Windows
- Software: Notepad++
- Knowledge Type: troubleshooting

## Common Issues

### 1. Staged installer file is missing
Possible causes:
- file copy to target staging path did not complete
- incorrect staging path
- source file not available

Recommended checks:
```powershell
Test-Path "C:\Temp\installers\notepadpp_installer.exe"
Get-ChildItem "C:\Temp\installers" -ErrorAction SilentlyContinue
```

Suggested actions:
- verify the installer was copied to the target staging path
- confirm the source file exists and is accessible
- manually place the installer for dev testing if automated copy is not yet enabled

### 2. Installer fails to launch or complete
Possible causes:
- insufficient privileges
- invalid silent install arguments
- corrupted installer

Recommended checks:
```powershell
Test-Path "C:\Temp\installers\notepadpp_installer.exe"
```

Suggested actions:
- verify approved execution rights
- validate silent install argument compatibility
- replace the installer with a known good approved copy

### 3. Notepad++ is not available after install
Possible causes:
- installation failed silently
- install directory not created
- executable path not available in the current session

Recommended checks:
```powershell
where.exe notepad++
Get-ChildItem "C:\Program Files\Notepad++" -ErrorAction SilentlyContinue
```

Suggested actions:
- validate the install directory exists
- confirm installer completed successfully
- open a new session and retry verification

## Escalation Guidance
Escalate for manual review if:
- the installer repeatedly fails with approved arguments
- the staged installer is correct but the install does not complete
- Notepad++ is installed but not discoverable through expected verification steps

## Source Notes
- MVP troubleshooting reference
- Windows staged-installer oriented
- Safe for retrieval grounding