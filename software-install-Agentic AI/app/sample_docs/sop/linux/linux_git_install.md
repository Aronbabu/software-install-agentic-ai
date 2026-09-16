# SOP: Install Git on Linux

## Purpose
Install `git` on an approved Linux target and verify that the binary is available for source control operations.

## Scope
- Platform: Linux
- Software: git
- Package source: operating system package manager
- Intended target: approved Debian/Ubuntu-based hosts for MVP testing

## Source Metadata
- Installer Source Type: APT_PACKAGE
- Approved Source Reference: git

## Preconditions
- SSH/OpenSSH connectivity to the target host is working
- User account has privilege to install packages
- `apt-get` is available on the target host
- Network access to configured package repositories is available
- Target host is an approved installation target

## Installation Steps
1. Refresh package metadata.
2. Install the `git` package using the system package manager.
3. Confirm installation completed without terminal error.

## Example Commands
```bash
apt-get update
apt-get install -y git
```

## Verification Steps
1. Verify that the `git` executable is available in the system path.
2. Confirm Git version output.

## Example Verification Commands
```bash
which git
git --version
```

## Expected Verification Result
- `which git` returns a valid executable path such as `/usr/bin/git`
- `git --version` returns installed version information

## Rollback Guidance
If rollback is required and approved:
```bash
apt-get remove -y git
```

## Failure / Troubleshooting Notes
- If install fails, verify package repository availability
- If verification fails, confirm package installation completed successfully
- If command path is missing, validate shell path and package state

## Source / Control Notes
- MVP-approved SOP sample
- Keep commands controlled and package-manager based
- Do not include secrets or unrestricted shell actions