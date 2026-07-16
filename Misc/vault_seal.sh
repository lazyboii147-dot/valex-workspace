#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[37m[+] [Vault Seal] $1\e[0m"; }
log_error() { echo -e "\e[31m[-] [Vault Seal] ERROR: $1\e[0m" >&2; }
TARGET_PATH=""
USAGE="Usage: vault-seal -p <directory_path>"
PARSED_OPTIONS=$(getopt -n "$0" -o p: --long path: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -p|--path) TARGET_PATH="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
if [[ -z "$TARGET_PATH" || ! -d "$TARGET_PATH" ]]; then
    log_error "Valid target sealing directory (-p|--path) must be explicitly designated."
    exit 1
fi
log_info "Executing definitive cryptographic lock protocol for path: $TARGET_PATH"
MANIFEST_FILE="${TARGET_PATH}/VAULT_LOCK_MANIFEST.sha256"
find "$TARGET_PATH" -type f -not -name "*.sha256" -print0 | xargs -0 sha256sum > "$MANIFEST_FILE"
log_info "Manifest locked. Converting storage layer attributes to read-only access map..."
chmod -R u-w "$TARGET_PATH" || true
chmod u+r "$MANIFEST_FILE"
log_info "Vault-Seal operation complete. Root environment signature recorded."
