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