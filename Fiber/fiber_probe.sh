#!/usr/bin/env bash
set -euo pipefail
log_info() { echo -e "\e[35m[+] [Fiber Probe] $1\e[0m"; }
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n 1)
if [[ -z "$INTERFACE" ]]; then
    INTERFACE="eth0"
fi
log_info "Attaching telemetry metric probe to interface line: $INTERFACE"
if [[ ! -d "/sys/class/net/$INTERFACE" ]]; then
    echo "Error: Network interface tracking path for $INTERFACE not found." >&2
    exit 1
fi
RX_START=$(cat "/sys/class/net/$INTERFACE/statistics/rx_bytes")
TX_START=$(cat "/sys/class/net/$INTERFACE/statistics/tx_bytes")
sleep 2
RX_END=$(cat "/sys/class/net/$INTERFACE/statistics/rx_bytes")
TX_END=$(cat "/sys/class/net/$INTERFACE/statistics/tx_bytes")
RX_RATE=$(( (RX_END - RX_START) / 2 ))
TX_RATE=$(( (TX_END - TX_START) / 2 ))
echo "--- Interface Speed Telemetry ($INTERFACE) ---"
echo "Receive Volume Delta: $((RX_RATE / 1024)) KB/s"
echo "Transmit Volume Delta: $((TX_RATE / 1024)) KB/s"
