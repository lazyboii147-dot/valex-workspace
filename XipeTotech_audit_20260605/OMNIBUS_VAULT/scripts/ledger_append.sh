#!/usr/bin/env bash

LEDGER="$HOME/OMNIBUS_VAULT/MASTER_LEDGER.log"
ENTRY_FILE="$1"

if [ -z "$ENTRY_FILE" ]; then
  echo "[CLEARBOXX] ERROR: No entry file provided."
  exit 1
fi

if [ ! -f "$ENTRY_FILE" ]; then
  echo "[CLEARBOXX] ERROR: Entry file not found: $ENTRY_FILE"
  exit 1
fi

echo "[CLEARBOXX] Appending entry from: $ENTRY_FILE"

cat >> "$LEDGER" << LEDGER_EOF
================================================================================
MASTER LEDGER ENTRY
Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
$(cat "$ENTRY_FILE")
ACATL REED SEAL: VALID
================================================================================
LEDGER_EOF

echo "[CLEARBOXX] Ledger updated: $LEDGER"
