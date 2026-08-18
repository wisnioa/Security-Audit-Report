#!/bin/bash

audit_status="PASS"
findings=()

echo "========================================"
echo " Linux Security Audit Report"
echo "========================================"

echo ""
echo "SYSTEM INFORMATION"
echo "----------------------------------------"

if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "OS: $PRETTY_NAME"
else
    echo "OS: Unable to determine"
fi

echo "Kernel: $(uname -r)"
echo "Hostname: $(hostname)"


echo ""
echo "FIREWALL STATUS"
echo "----------------------------------------"

if ! command -v ufw &> /dev/null; then
    echo "Status: WARN"
    echo "UFW: Not installed"
    findings+=("[INFO] UFW is not installed")
else
    firewall_status=$(sudo ufw status)

    if [[ "$firewall_status" == *"inactive"* ]]; then
        echo "Status: FAIL"
        echo "UFW: Installed but inactive"
        audit_status="WARN"
        findings+=("[WARN] Firewall is installed but inactive")

    elif [[ "$firewall_status" == *"Status: active"* ]]; then
        echo "Status: PASS"
        echo "UFW: Installed and active"
        findings+=("[PASS] Firewall is installed and active")
    fi
fi


echo ""
echo "OPEN PORTS"
echo "----------------------------------------"

echo "Protocol   State      Port     Address                  Process"

open_ports=$(sudo ss -tulnpH | awk '{
    port=$5
    sub(/^.*:/, "", port)

    address=$5
    sub(/:[^:]*$/, "", address)

    printf "%-10s %-10s %-8s %-25s %s\n", $1, $2, port, address, $7
}')

echo "$open_ports"


echo ""
echo "SSH CONFIGURATION"
echo "----------------------------------------"

if ! command -v sshd &> /dev/null; then
    echo "Status: PASS"
    echo "SSH Server: Not installed"
    findings+=("[PASS] SSH server is not installed")
else
    ssh_status=$(sudo systemctl is-active ssh)

    if [[ "$ssh_status" == "active" ]]; then
        echo "Status: WARN"
        echo "SSH Server: Installed and active"
        findings+=("[INFO] SSH server is installed and active")

    elif [[ "$ssh_status" == "inactive" ]]; then
        echo "Status: PASS"
        echo "SSH Server: Installed but inactive"
        findings+=("[PASS] SSH server is installed but inactive")
    fi
fi


echo ""
echo "USER & PRIVILEGE AUDIT"
echo "----------------------------------------"

echo "UID 0 ACCOUNTS"

uid_zero_users=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)

echo "$uid_zero_users"

if [[ "$uid_zero_users" == "root" ]]; then
    findings+=("[PASS] Only root account has UID 0")
else
    audit_status="WARN"
    findings+=("[WARN] Multiple UID 0 accounts detected")
fi

echo ""

echo "INTERACTIVE SHELLS"
awk -F: '$7 !~ /(nologin|false)$/ {print $1, $7}' /etc/passwd

echo ""

echo "SUDO GROUP MEMBERS"

sudo_users=$(getent group sudo | cut -d: -f4)

if [ -n "$sudo_users" ]; then
    echo "$sudo_users"
    findings+=("[INFO] Sudo privileges assigned to: $sudo_users")
else
    echo "None"
fi


echo ""
echo "AUTHENTICATION ACTIVITY"
echo "----------------------------------------"

if [ -f /var/log/auth.log ]; then
    failed_ssh=$(sudo grep -Ec "sshd\[[0-9]+\]: Failed password" /var/log/auth.log)
    successful_ssh=$(sudo grep -Ec "sshd\[[0-9]+\]: Accepted" /var/log/auth.log)

    echo "Failed SSH Attempts:    $failed_ssh"
    echo "Successful SSH Logins:  $successful_ssh"

    if [ "$failed_ssh" -gt 0 ]; then
        audit_status="WARN"
        findings+=("[WARN] Failed SSH authentication attempts detected")
    else
        findings+=("[PASS] No failed SSH authentication attempts detected")
    fi

else
    echo "Status: WARN"
    echo "Authentication log unavailable"
    audit_status="WARN"
    findings+=("[WARN] Authentication log unavailable")
fi


echo ""
echo "AUDIT SUMMARY"
echo "----------------------------------------"

echo "Overall Status: $audit_status"

echo ""
echo "FINDINGS"

for finding in "${findings[@]}"; do
    echo "$finding"
done