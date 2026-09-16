# Knowledge: Git Troubleshooting on Windows

## Purpose
Provide troubleshooting guidance when Git installation or verification fails on Windows targets.

## Scope
- Platform: Windows
- Software: Git
- Knowledge Type: troubleshooting

## Common Issues

### 1. Staged installer file is missing
Possible causes:
- file copy to target staging path did not complete
- incorrect staging path
- source file not available

Recommended checks:
```powershell
Test-Path "C:\Temp\installers\git_installer.exe"
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
Test-Path "C:\Temp\installers\git_installer.exe"
```

Suggested actions:
- verify approved execution rights
- validate silent install argument compatibility
- replace the installer with a known good approved copy

### 3. `git` command not found after install
Possible causes:
- installation failed silently
- PATH not refreshed for the current session
- Git installed to unexpected location

Recommended checks:
```powershell
git --version
where.exe git
Get-ChildItem "C:\Program Files\Git" -ErrorAction SilentlyContinue
```

Suggested actions:
- open a new session and retest
- validate Git installation directory
- confirm installer completed successfully

## Escalation Guidance
Escalate for manual review if:
- the installer repeatedly fails with approved arguments
- the staged installer is correct but the install does not complete
- Git is installed but not resolvable through expected verification steps

## Source Notes
- MVP troubleshooting reference
- Windows staged-installer oriented
- Safe for retrieval grounding