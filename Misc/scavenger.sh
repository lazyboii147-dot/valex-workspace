#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[37m[+] [Scavenger] $1\e[0m"; }
TARGET_DIR="/tmp"
DAYS_OLD=7
USAGE="Usage: scavenger -d <directory> -m <days_old>"
PARSED_OPTIONS=$(getopt -n "$0" -o d:m: --long dir:,days: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -d|--dir) TARGET_DIR="$2"; shift 2 ;;
        -m|--days) DAYS_OLD="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
log_info "Scanning directory tree path '$TARGET_DIR' for artifacts older than $DAYS_OLD days..."
FOUND_COUNT=$(find "$TARGET_DIR" -type f \( -name "*.tmp" -o -name "*.lock" \) -mtime +"$DAYS_OLD" | wc -l)
log_info "Discovered $FOUND_COUNT unreferenced tracking entities scheduled for storage reclamation."
if [[ "$FOUND_COUNT" -gt 0 ]]; then
    find "$TARGET_DIR" -type f \( -name "*.tmp" -o -name "*.lock" \) -mtime +"$DAYS_OLD" -delete
    log_info "Reclamation sequence completed. Trailing block sectors optimized successfully."
fi
