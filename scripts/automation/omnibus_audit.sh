#!/bin/bash
set -euo pipefail

VAULT_DIR="/VALEX_VAULT"
LOG_DIR="/var/log"
PATTERN="TIRCE_VEC"

echo "[*] Omnibus Audit: starting log scan at $(date -Iseconds)"

if [ ! -d "$LOG_DIR" ]; then
  echo "[WARN] Log directory not found: $LOG_DIR"
  exit 0
fi

MATCH_COUNT=0

grep -RIn "$PATTERN" "$LOG_DIR" || true | while read -r line; do
  echo "[MATCH] $line"
  ((MATCH_COUNT++)) || true
done

echo "[*] Omnibus Audit: completed log scan at $(date -Iseconds)"
echo "[*] Matches found: ${MATCH_COUNT:-0}"

if [ "${MATCH_COUNT:-0}" -gt 0 ]; then
  exit 2
fi
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 3de68bb239061fa41e2e0b14b36971a8bb0501fe97c99e295479ded8f699e4a01199c7bac8a1b82bb63a17b6089570af39f9d28e38f0dbd2a297ebac4694935d
SIGNATURE: MEUCIE3TyPGV5yRbCZpXSZ8FZahQSstOELGj+9O1gc8fWLidAiEA89Q8OQXRj9sua8earNB3Ni7DHFvzhUpXzH+XlhA3aXw=
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: omnibus_audit.sh
EOF-METADATA-END
*/
