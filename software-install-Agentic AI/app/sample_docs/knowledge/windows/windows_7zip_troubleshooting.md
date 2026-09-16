# Knowledge: 7-Zip Troubleshooting on Windows

## Purpose
Provide troubleshooting guidance when 7-Zip installation or verification fails on Windows targets.

## Scope
- Platform: Windows
- Software: 7-Zip
- Knowledge Type: troubleshooting

## Common Issues

### 1. Staged installer file is missing
Possible causes:
- file copy to target staging path failed
- incorrect staging location
- source file unavailable

Recommended checks:
```powershell
Test-Path "C:\Temp\installers\7zip_installer.exe"
Get-ChildItem "C:\Temp\installers" -ErrorAction SilentlyContinue
```

Suggested actions:
- verify the installer was copied to the target staging path
- confirm the approved source file exists
- manually place the installer for dev testing if needed

### 2. Installer does not complete successfully
Possible causes:
- insufficient privileges
- unsupported silent argument
- invalid installer file

Recommended checks:
```powershell
Test-Path "C:\Temp\installers\7zip_installer.exe"
```

Suggested actions:
- verify execution rights
- validate silent argument usage
- replace the installer with an approved known-good copy

### 3. `7z` command is unavailable after install
Possible causes:
- install did not complete
- PATH not updated
- executable not in expected location

Recommended checks:
```powershell
where.exe 7z
Get-Command 7z -ErrorAction SilentlyContinue
Get-ChildItem "C:\Program Files\7-Zip" -ErrorAction SilentlyContinue
```

Suggested actions:
- confirm installation directory exists
- retry verification in a new session
- validate installer success before reattempting installation

## Escalation Guidance
Escalate for manual review if:
- installer repeatedly fails with approved arguments
- installation appears successful but executable resolution still fails
- staged file and permissions are correct but package state remains uncertain

## Source Notes
- MVP troubleshooting reference
- Windows staged-installer oriented
- Safe for retrieval grounding