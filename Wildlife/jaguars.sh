#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[32m[+] [Jaguars] $1\e[0m"; }
log_alert() { echo -e "\e[31m[!] [Jaguars] ALERT: $1\e[0m" >&2; }
LOG_FILE="/var/log/auth.log"
[[ ! -f "$LOG_FILE" ]] && LOG_FILE="/var/log/secure"
log_info "Jaguars shadow-sentry active. Real-time access event analysis engaged."
if [[ ! -r "$LOG_FILE" ]]; then
    log_alert "Insufficient privilege to monitor standard host authorization logs directly."
    exit 1
fi
tail -n 50 "$LOG_FILE" | grep -Ei "failed|accepted|sudo" | while read -r line; do
    if echo "$line" | grep -qi "failed"; then
        log_alert "Detected anomaly profile: $line"
    else
        log_info "Verified valid entry event: $line"
    fi
done
