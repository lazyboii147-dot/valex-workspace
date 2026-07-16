#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[32m[+] [Butterfly] $1\e[0m"; }
STAGE="development"
USAGE="Usage: butterfly -s [development|staging|production]"
PARSED_OPTIONS=$(getopt -n "$0" -o s: --long stage: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -s|--stage) STAGE="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
log_info "Initiating runtime state metamorphosis targeting level: $STAGE"
CONFIG_TARGET="$HOME/.pantheon_runtime.conf"
echo "TARGET_ENV=$STAGE" > "$CONFIG_TARGET"
echo "METAMORPHOSIS_TIME=$(date +%s)" >> "$CONFIG_TARGET"
log_info "Configuration structure transformed successfully at $CONFIG_TARGET"
