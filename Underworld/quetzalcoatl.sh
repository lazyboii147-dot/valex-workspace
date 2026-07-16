#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[34m[+] [Quetzalcoatl] $1\e[0m"; }
log_error() { echo -e "\e[31m[-] [Quetzalcoatl] ERROR: $1\e[0m" >&2; }
ENDPOINT="https://api.github.com"
USAGE="Usage: quetzalcoatl -e <endpoint_url>"
PARSED_OPTIONS=$(getopt -n "$0" -o e: --long endpoint: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -e|--endpoint) ENDPOINT="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
log_info "Analyzing transport route paths toward: $ENDPOINT"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$ENDPOINT" || echo "000")
if [[ "$HTTP_CODE" -ge 200 && "$HTTP_CODE" -lt 400 ]]; then
    log_info "Route path verified. Ingress transport node replied with code: $HTTP_CODE"
else
    log_error "Transport layer anomaly reported. Host unreachable or dropped with code: $HTTP_CODE"
    exit 1
fi
