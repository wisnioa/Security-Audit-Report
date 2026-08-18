# Linux Security Audit Report

A Bash-based Linux security auditing tool that performs basic system and security checks and generates a readable terminal report.

## Features

The audit evaluates:

System Information — OS, kernel version, and hostname
Firewall Security — UFW installation and active/inactive status
Network Exposure — Listening TCP/UDP ports, addresses, and associated processes
SSH Security — SSH server installation and service status
User & Privilege Security
Accounts with UID 0
Accounts with interactive shells
Members of the sudo group
Authentication Activity
Failed SSH authentication attempts
Successful SSH logins
Security Summary


## Requirements

The script was developed and tested using Ubuntu 24.04 under WSL2.

## Usage

Clone the repository and run:

```bash
bash linuxsysaudit.sh
```

Some checks require `sudo` privileges, so you may be prompted for your password.

## Example

The script generates a report similar to:

```text
========================================
 Linux Security Audit Report
========================================

SYSTEM INFORMATION
----------------------------------------
OS: Ubuntu 24.04.3 LTS
Kernel: 6.6.87.2-microsoft-standard-WSL2
Hostname: Amanda

FIREWALL STATUS
----------------------------------------
Status: FAIL
UFW: Installed but inactive

...

AUDIT SUMMARY
----------------------------------------
Overall Status: WARN

FINDINGS
[WARN] Firewall is installed but inactive
[PASS] SSH server is not installed
[PASS] Only root account has UID 0
[INFO] Sudo privileges assigned to: amanda
[PASS] No failed SSH authentication attempts detected
```

