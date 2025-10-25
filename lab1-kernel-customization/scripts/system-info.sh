#!/bin/bash
# System Information Display

echo "========================================="
echo "       Lab 1: System Information        "
echo "========================================="
echo ""
echo "Hostname: $(hostname)"
echo "Kernel: $(uname -r)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Uptime: $(uptime -p)"
echo ""
echo "=== CPU ==="
lscpu | grep -E "Model name|CPU\(s\)|Thread|Core"
echo ""
echo "=== Memory ==="
free -h
echo ""
echo "=== Disk Usage ==="
df -h / /home | grep -v tmpfs
echo ""
echo "=== Network ==="
ip -br addr show | grep UP
echo ""
echo "=== Load Average ==="
uptime | awk -F'load average:' '{print $2}'
echo ""
echo "========================================="
