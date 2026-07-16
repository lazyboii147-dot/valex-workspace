#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[37m[+] [Entropy] $1\e[0m"; }
LENGTH=16
USAGE="Usage: entropy -l <byte_length>"
PARSED_OPTIONS=$(getopt -n "$0" -o l: --long length: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -l|--length) LENGTH="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
log_info "Extracting $LENGTH cryptographically random bytes via kernel entropy structures..."
RANDOM_STRING=$(head -c "$LENGTH" /dev/urandom | base64 | tr -d '/+' | cut -c1-"$LENGTH")
echo "Generated Value Matrix: $RANDOM_STRING"
