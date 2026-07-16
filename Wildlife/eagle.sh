#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[32m[+] [Eagle] $1\e[0m"; }
log_info "--- Solar Horizon Diagnostic Report ---"
echo "Timestamp: $(date -u)"
echo "Host Kernel Core: $(uname -r)"
echo "---------------------------------------"
echo "[*] Top 3 CPU Consuming Threads:"
ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 4
echo -e "\n[*] Disk Volume Allocation Matrix:"
df -h / | awk 'NR==2 {print "Total: " $2 " | Used: " $3 " | Available: " $4 " (" $5 ")"}'
echo -e "\n[*] Total Open File Descriptors across System Context: $(cat /proc/sys/fs/file-nr | awk '{print $1}')"
log_info "Diagnostics gathering finalized."
