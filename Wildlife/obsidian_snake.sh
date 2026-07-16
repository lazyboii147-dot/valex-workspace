#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[32m[+] [Obsidian Snake] $1\e[0m"; }
log_warn() { echo -e "\e[33m[*] [Obsidian Snake] WARNING: $1\e[0m"; }
TARGET_HOST=""
PORT_RANGE="1-1024"
USAGE="Usage: snake -t <target_host> [-r <port_range>]"
PARSED_OPTIONS=$(getopt -n "$0" -o t:r: --long target:,range: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -t|--target) TARGET_HOST="$2"; shift 2 ;;
        -r|--range) PORT_RANGE="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
if [[ -z "$TARGET_HOST" ]]; then
    echo "$USAGE" >&2; exit 1
fi
log_info "Beginning shadow-stealth boundary scan on target: $TARGET_HOST"
START_PORT=$(echo "$PORT_RANGE" | cut -d'-' -f1)
END_PORT=$(echo "$PORT_RANGE" | cut -d'-' -f2)
for ((port=START_PORT; port<=END_PORT; port++)); do
    if (timeout 1 bash -c "cat < /dev/null > /dev/tcp/$TARGET_HOST/$port") 2>/dev/null; then
        log_info "Discovered open communication path on port: $port"
    fi
done
log_info "Stealth path inspection operations finalized."
