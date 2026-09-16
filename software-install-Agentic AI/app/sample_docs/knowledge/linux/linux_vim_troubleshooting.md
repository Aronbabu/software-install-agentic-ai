# Knowledge: vim Troubleshooting on Linux

## Purpose
Provide troubleshooting guidance when `vim` installation or verification fails on Linux targets.

## Scope
- Platform: Linux
- Software: vim
- Knowledge Type: troubleshooting

## Common Issues

### 1. `apt-get update` fails
Possible causes:
- repository mirror unreachable
- DNS or network issue
- proxy restriction

Recommended checks:
```bash
ping -c 1 archive.ubuntu.com
cat /etc/resolv.conf
apt-get update
```

Suggested actions:
- verify DNS resolution
- verify repository connectivity
- validate proxy or firewall policy if used

### 2. Package install fails
Possible causes:
- package manager lock
- interrupted package database state
- repository issue

Recommended checks:
```bash
ps -ef | grep apt
ps -ef | grep dpkg
dpkg --configure -a
```

Suggested actions:
- allow active package operation to finish
- recover package configuration state if required
- retry installation after the issue is resolved

### 3. `vim` command not found after install
Possible causes:
- package installation incomplete
- shell path issue
- unexpected package state

Recommended checks:
```bash
which vim
dpkg -l | grep vim
vim --version
```

Suggested actions:
- verify package installation
- confirm executable path
- rerun installation if package state is incomplete

## Escalation Guidance
Escalate for manual review if:
- package state remains inconsistent
- repository access cannot be restored
- command remains unavailable after successful installation output

## Source Notes
- MVP troubleshooting reference
- Linux package-manager oriented
- Safe for retrieval grounding