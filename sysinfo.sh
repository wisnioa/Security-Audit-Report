#!/bin/bash

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
else
    firewall_status=$(sudo ufw status)

    if [[ "$firewall_status" == *"inactive"* ]]; then
        echo "Status: FAIL"
        echo "UFW: Installed but inactive"
    
    elif [[ "$firewall_status" == *"Status: active"* ]]; then
        echo "Status: PASS"
        echo "UFW: Installed and active"

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
else
    ssh_status=$(sudo systemctl is-active ssh)

    if [[ "$ssh_status" == "active" ]]; then
        echo "Status: WARN"
        echo "SSH Server: Installed and active"

    elif [[ "$ssh_status" == "inactive" ]]; then
        echo "Status: PASS"
        echo "SSH Server: Installed but inactive"
    fi
fi




echo ""
echo "USER & PRIVILEGE AUDIT"
echo "----------------------------------------"

echo "UID 0 ACCOUNTS"
awk -F: '$3 == 0 {print $1}' /etc/passwd

echo ""

echo "INTERACTIVE SHELLS"
awk -F: '$7 !~ /(nologin|false)$/ {print $1, $7}' /etc/passwd

echo ""

echo "SUDO GROUP MEMBERS"
getent group sudo | cut -d: -f4

echo ""