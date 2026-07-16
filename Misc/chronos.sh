#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[37m[+] [Chronos] $1\e[0m"; }
log_error() { echo -e "\e[31m[-] [Chronos] ERROR: $1\e[0m" >&2; }
TIMEOUT_LIMIT=5
if [[ "$#" -lt 1 ]]; then
    log_error "Usage: chronos <timeout_in_seconds> <command_payload_arguments...>"
    exit 1
fi
TIMEOUT_LIMIT="$1"
shift
log_info "Enforcing execution timeframe bounding matrix: ${TIMEOUT_LIMIT}s limit"
if timeout "$TIMEOUT_LIMIT" "$@"; then
    log_info "Command execution finished cleanly inside the designated time frame window."
else
    log_error "Command breached absolute boundary threshold runtime limits. Terminated by force."
    exit 124
fi
