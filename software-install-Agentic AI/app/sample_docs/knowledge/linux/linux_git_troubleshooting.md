# Knowledge: Git Troubleshooting on Linux

## Purpose
Provide troubleshooting guidance when `git` installation or verification fails on Linux targets.

## Scope
- Platform: Linux
- Software: git
- Knowledge Type: troubleshooting

## Common Issues

### 1. `apt-get update` fails
Possible causes:
- DNS resolution problem
- repository mirror unreachable
- outbound network restriction
- proxy misconfiguration

Recommended checks:
```bash
ping -c 1 archive.ubuntu.com
cat /etc/resolv.conf
apt-get update
```

Suggested actions:
- verify DNS resolution
- verify outbound connectivity to package repositories
- verify proxy or firewall policy if applicable

### 2. Package manager lock error
Possible causes:
- another apt or dpkg process is running
- previous package operation did not complete cleanly

Recommended checks:
```bash
ps -ef | grep apt
ps -ef | grep dpkg
```

Suggested actions:
- wait for the active package process to finish
- confirm no competing package manager operation is running
- retry installation after the lock condition is cleared

### 3. `git` command not found after install
Possible causes:
- installation failed silently
- package was not fully installed
- shell path/session issue

Recommended checks:
```bash
which git
dpkg -l | grep git
git --version
```

Suggested actions:
- confirm package installation status
- rerun installation if needed
- validate executable location in system path

## Escalation Guidance
Escalate for manual review if:
- repository connectivity remains unavailable
- package manager is in inconsistent state
- installation reports success but binary is still unavailable

## Source Notes
- MVP troubleshooting reference
- Linux package-manager oriented
- Safe for retrieval grounding