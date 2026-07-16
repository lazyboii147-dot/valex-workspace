#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[36m[+] [Stratoshook] $1\e[0m"; }
TEST_HOST="1.1.1.1"
log_info "Validating raw IP socket routing layer outside default network interfaces..."
if ping -c 2 -W 3 "$TEST_HOST" &>/dev/null; then
    log_info "Direct external routing pipeline operates nominally."
else
    log_info "Direct pipeline failed response verification checks. Review local route parameters or gateway mappings."
fi
