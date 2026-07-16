#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[32m[+] [Xipe Totec] $1\e[0m"; }
log_error() { echo -e "\e[31m[-] [Xipe Totec] ERROR: $1\e[0m" >&2; }
TARGET_PID=""
FORCE_SHED=0
USAGE="Usage: xipetotec -p <pid> [-f]"
PARSED_OPTIONS=$(getopt -n "$0" -o p:f --long pid:,force -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -p|--pid) TARGET_PID="$2"; shift 2 ;;
        -f|--force) FORCE_SHED=1; shift ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
if [[ -z "$TARGET_PID" ]]; then
    log_error "A target Process ID (-p|--pid) must be declared for structural renewal."
    exit 1
fi
if ! kill -0 "$TARGET_PID" 2>/dev/null; then
    log_error "Target PID $TARGET_PID does not exist or is inaccessible."
    exit 1
fi
log_info "Initiating process skin-shedding protocol for PID: $TARGET_PID"
ENV_EXPORT_PATH="/tmp/xipe_snapshot_${TARGET_PID}.env"
if [[ -f "/proc/$TARGET_PID/environ" ]]; then
    tr '\0' '\n' < "/proc/$TARGET_PID/environ" > "$ENV_EXPORT_PATH" || true
    log_info "State snapshots preserved at $ENV_EXPORT_PATH"
fi
SIGNAL=$([[ $FORCE_SHED -eq 1 ]] && echo "SIGKILL" || echo "SIGTERM")
log_info "Sending $SIGNAL to drop old execution footprint..."
kill -"$SIGNAL" "$TARGET_PID"
log_info "Process structural renewal cycle finalized."
