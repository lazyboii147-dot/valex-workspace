#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[36m[+] [Nebula] $1\e[0m"; }
log_info "Querying runtime environment container infrastructure matrices..."
if command -v docker &>/dev/null; then
    log_info "Discovered Docker daemon context layer. Running inspection..."
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    log_info "No Docker framework abstraction layer detected inside this shell namespace environment."
fi
if command -v kubectl &>/dev/null; then
    log_info "Discovered Kubernetes orchestration hook. Listing default node properties..."
    kubectl get pods -o wide || true
fi
