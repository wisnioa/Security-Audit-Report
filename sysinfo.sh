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