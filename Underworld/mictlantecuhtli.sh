#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[34m[+] [Mictlantecuhtli] $1\e[0m"; }
log_warn() { echo -e "\e[33m[*] [Mictlantecuhtli] WARNING: $1\e[0m"; }
TARGET_PATTERN=""
USAGE="Usage: mictlantecuhtli -g <search_pattern_string>"
PARSED_OPTIONS=$(getopt -n "$0" -o g: --long pattern: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -g|--pattern) TARGET_PATTERN="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
if [[ -z "$TARGET_PATTERN" ]]; then
    log_warn "No identification pattern declared. Terminating nothing."
    exit 0
fi
log_info "Searching for threads matching execution signature: '$TARGET_PATTERN'"
MATCHING_PIDS=$(pgrep -f "$TARGET_PATTERN" | grep -v "$$" || true)
if [[ -z "$MATCHING_PIDS" ]]; then
    log_info "No stray threads matching signature pattern discovered."
    exit 0
fi
echo "$MATCHING_PIDS" | while read -r pid; do
    log_warn "Enforcing absolute termination loop on PID: $pid ($(ps -p "$pid" -o cmd=))"
    kill -9 "$pid" 2>/dev/null || true
done
log_info "Runtime environment process tree stabilization complete."
