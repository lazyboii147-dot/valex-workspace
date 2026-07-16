#!/bin/bash
# ==============================================================================
# TITLE:        VALEX AUTOMATION ORCHESTRATOR
# AUTHOR:       Enrique B. Gonzalez III (CajaCl34r / CL34RBoXx)
# DATE:         2026-06-01
# DESCRIPTION:  Automates environment verification, triggers processing cycles,
#               and exports timestamped logs and snapshots of vault activity.
# ==============================================================================

set -euo pipefail

# --- CONFIGURATION ---
VAULT_ROOT="./VALEX_VAULT"
LOG_DIR="${VAULT_ROOT}/LOGS"
TIMESTAMP=$(date +'%Y%m%dT%H%M%S')
EXPORT_LOG="${LOG_DIR}/automation_run_${TIMESTAMP}.log"

# --- TELEMETRY COLOR CODES ---
NC='\033[0m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'

log_runtime() {
    local message="[*] [${TIMESTAMP}] - ${1}"
    echo -e "${CYAN}${message}${NC}"
    echo "$message" >> "$EXPORT_LOG"
}

log_done() {
    local message="[+] [${TIMESTAMP}] - ${1}"
    echo -e "${GREEN}${message}${NC}"
    echo "$message" >> "$EXPORT_LOG"
}

log_failure() {
    local message="[-] FATAL: ${1}"
    echo -e "${RED}${message}${NC}" >&2
    exit 1
}

# --- AUTOMATION PIPELINE ---

# 1. Enforce/Verify Environment Scaffolding
if [ -f "./clear_box_audio.sh" ]; then
    log_runtime "Executing structural initialization..."
    ./clear_box_audio.sh >> "$EXPORT_LOG" 2>&1
else
    log_failure "Initialization script 'clear_box_audio.sh' not found in current directory."
fi

# 2. Execute Ingest and Processing Cycle
if [ -f "./process_audio.sh" ]; then
    log_runtime "Initiating audio target processing loop..."
    
    # Run processor and duplicate output directly into the timestamped automation log
    ./process_audio.sh 2>&1 | tee -a "$EXPORT_LOG"
    
    log_done "Processing cycle successfully handled."
else
    log_failure "Processor script 'process_audio.sh' not found in current directory."
fi

# 3. Create a Timestamped Vault State Snapshot
SNAPSHOT_FILE="${LOG_DIR}/vault_snapshot_${TIMESTAMP}.txt"
log_runtime "Generating permanent timestamped vault state snapshot..."

{
    echo "=========================================================="
    echo "VALEX VAULT SNAPSHOT: ${TIMESTAMP}"
    echo "=========================================================="
    echo "DIRECTORY TREE:"
    find "$VAULT_ROOT" -maxdepth 3
    echo -e "\nMANIFEST INTEGRITY:"
    cat "${VAULT_ROOT}/audio_manifest.json" 2>/dev/null || echo "Manifest unreadable."
    echo "=========================================================="
} > "$SNAPSHOT_FILE"

log_done "Snapshot exported to: ${SNAPSHOT_FILE}"
log_done "Automation pass complete. Consolidated run log: ${EXPORT_LOG}"
/*
*/
/*
EOF-METADATA-BEGIN
HASH: d9716b43372eaa78de298594dfe07ee619fa1e7945590bdc4177ffab82b67390eedb94b6ae8dc1ad27da2b0ddd6567f37a3bd4aa4a6f614ae1f1a0777e81cd34
SIGNATURE: MEQCIQDepHprgA3eDyMewoxnoYeVshl7ZlHxWua5fg/7mMz/QQIfCnC0AP1rku897yZEHU8cjtqxD991mbBqSRwAE7is9w==
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: Automate_omnibus.sh
EOF-METADATA-END
*/
