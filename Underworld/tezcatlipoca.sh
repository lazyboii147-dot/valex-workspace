#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[34m[+] [Tezcatlipoca] $1\e[0m"; }
log_error() { echo -e "\e[31m[-] [Tezcatlipoca] ERROR: $1\e[0m" >&2; }
TARGET_DIR=""
USAGE="Usage: tezcatlipoca -d <directory_to_hash>"
PARSED_OPTIONS=$(getopt -n "$0" -o d: --long dir: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -d|--dir) TARGET_DIR="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]]; then
    log_error "Valid targeting directory path (-d|--dir) must be specified for mirror mapping."
    exit 1
fi
log_info "Generating complete SHA-256 cryptographic image layout for path: $TARGET_DIR"
MANIFEST_OUTPUT="/tmp/tezcatlipoca_manifest_$(date +%s).sha256"
find "$TARGET_DIR" -type f -not -name "*.sha256" -print0 | xargs -0 sha256sum > "$MANIFEST_OUTPUT"
log_info "Cryptographic mirror layout completed. Manifest locked at: $MANIFEST_OUTPUT"
