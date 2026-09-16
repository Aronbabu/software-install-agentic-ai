# SOP: Install curl on Linux

## Purpose
Install `curl` on an approved Linux target and verify that the binary is available for use.

## Scope
- Platform: Linux
- Software: curl
- Package source: operating system package manager
- Intended target: approved Debian/Ubuntu-based hosts for MVP testing

## Source Metadata
- Installer Source Type: APT_PACKAGE
- Approved Source Reference: curl

## Preconditions
- SSH/OpenSSH connectivity to the target host is working
- User account has privilege to install packages
- `apt-get` is available on the target host
- Network access to configured package repositories is available
- Target host is an approved installation target

## Installation Steps
1. Refresh package metadata.
2. Install the `curl` package using the system package manager.
3. Confirm installation command completed without terminal error.

## Example Commands
```bash
apt-get update
apt-get install -y curl
```

## Verification Steps
1. Verify that the `curl` executable is available in the system path.
2. Optionally confirm version output.

## Example Verification Commands
```bash
which curl
curl --version
```

## Expected Verification Result
- `which curl` returns a valid executable path such as `/usr/bin/curl`
- `curl --version` returns installed version information

## Rollback Guidance
If rollback is required and approved:
```bash
apt-get remove -y curl
```

## Failure / Troubleshooting Notes
- If package metadata refresh fails, check repository connectivity and DNS resolution
- If install fails due to lock or package manager state, verify no conflicting package operation is running
- If verification fails, confirm installation completed successfully and the executable path is available

## Source / Control Notes
- MVP-approved SOP sample
- Keep commands controlled and package-manager based
- Do not add credentials, tokens, or unrestricted shell actions