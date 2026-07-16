#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[35m[+] [Optics] $1\e[0m"; }
log_info "Analyzing host name-resolution configuration layer..."
RESOLV_CONF="/etc/resolv.conf"
if [[ -f "$RESOLV_CONF" ]]; then
    echo "--- Resolved Nameservers in Context ---"
    grep -E "^nameserver" "$RESOLV_CONF" || echo "No explicit static name servers specified."
    echo "---------------------------------------"
else
    echo "Warning: Standard name-resolution configuration tracking file unreachable." >&2
fi
