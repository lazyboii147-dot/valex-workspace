#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[32m[+] [Rabbits] $1\e[0m"; }
THREAD_COUNT=4
USAGE="Usage: rabbits -c <thread_count>"
PARSED_OPTIONS=$(getopt -n "$0" -o c: --long count: -- "$@") || { echo "$USAGE" >&2; exit 1; }
eval set -- "$PARSED_OPTIONS"
while true; do
    case "$1" in
        -c|--count) THREAD_COUNT="$2"; shift 2 ;;
        --) shift; break ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
log_info "Spawning $THREAD_COUNT verification routines in parallel processing blocks..."
for ((i=1; i<=THREAD_COUNT; i++)); do
    (
        sleep_duration=$(( (RANDOM % 3) + 1 ))
        sleep "$sleep_duration"
        log_info "Thread instance #$i closed state cleanly after $sleep_duration seconds."
    ) &
done
wait
log_info "All spawned thread instances synchronized and re-merged successfully."
