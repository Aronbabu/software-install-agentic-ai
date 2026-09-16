# SOP: Install vim on Linux

## Purpose
Install `vim` on an approved Linux target and verify that the editor is available for operational use.

## Scope
- Platform: Linux
- Software: vim
- Package source: operating system package manager
- Intended target: approved Debian/Ubuntu-based hosts for MVP testing

## Source Metadata
- Installer Source Type: APT_PACKAGE
- Approved Source Reference: vim

## Preconditions
- SSH/OpenSSH connectivity to the target host is working
- User account has privilege to install packages
- `apt-get` is available on the target host
- Network access to configured package repositories is available
- Target host is an approved installation target

## Installation Steps
1. Refresh package metadata.
2. Install the `vim` package using the system package manager.
3. Confirm installation completed without terminal error.

## Example Commands
```bash
apt-get update
apt-get install -y vim
```

## Verification Steps
1. Verify that the `vim` executable is available in the system path.
2. Optionally confirm version output.

## Example Verification Commands
```bash
which vim
vim --version
```

## Expected Verification Result
- `which vim` returns a valid executable path such as `/usr/bin/vim`
- `vim --version` returns installed version information

## Rollback Guidance
If rollback is required and approved:
```bash
apt-get remove -y vim
```

## Failure / Troubleshooting Notes
- If package metadata refresh fails, check repository connectivity
- If install fails, confirm no other package operation is holding the apt lock
- If verification fails, confirm the package was installed and available in path

## Source / Control Notes
- MVP-approved SOP sample
- Keep commands controlled and package-manager based
- Do not include secrets or unrestricted shell actions