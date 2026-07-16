#!/bin/bash
set -euo pipefail

VAULT_DIR="/VALEX_VAULT"
MANIFEST_FILE="$VAULT_DIR/manifest.json"
TEMP_CURRENT="/tmp/current_vault.hash"

if [ ! -f "$MANIFEST_FILE" ]; then
  echo "[CRITICAL] Baseline manifest missing at $MANIFEST_FILE"
  exit 1
fi

echo "[*] Initializing Incremental Integrity Diff at $(date -Iseconds)..."

find "$VAULT_DIR" -type f ! -name "manifest.json" -exec sha256sum {} + > "$TEMP_CURRENT"

MODIFIED_COUNT=0
NEW_COUNT=0
MISSING_COUNT=0

echo "=== INTEGRITY EXCEPTION REPORT ==="

while read -r baseline_hash baseline_file; do
  if [ ! -f "$baseline_file" ]; then
    echo "[DELETED] File missing: $baseline_file"
    ((MISSING_COUNT++))
  else
    current_hash=$(sha256sum "$baseline_file" | awk '{print $1}')
    if [ "$baseline_hash" != "$current_hash" ]; then
      echo "[MODIFIED] Integrity breach: $baseline_file"
      echo "  Expected: $baseline_hash"
      echo "  Found:    $current_hash"
      ((MODIFIED_COUNT++))
    fi
  fi
done < <(jq -r '.files[] | "\(.hash) \(.path)"' "$MANIFEST_FILE")

while read -r current_hash current_file; do
  exists=$(jq --arg path "$current_file" '.files[] | select(.path == $path)' "$MANIFEST_FILE")
  if [ -z "$exists" ]; then
    echo "[UNTRACKED] Unauthorized file added: $current_file (Hash: $current_hash)"
    ((NEW_COUNT++))
  fi
done < "$TEMP_CURRENT"

rm -f "$TEMP_CURRENT"

echo "----------------------------------"
echo "Audit Summary: $MODIFIED_COUNT Modified | $NEW_COUNT Untracked | $MISSING_COUNT Missing"

if [ $((MODIFIED_COUNT + NEW_COUNT + MISSING_COUNT)) -gt 0 ]; then
  exit 2
fi
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 0202c115b46233b5b9d9891732143ba7dbee4a4d644597c8f88cc69f131a42f4542e2bd0b67c74b62ff6ff9318b4cb423a6cae355411da15b2072a9919a77a4f
SIGNATURE: MEUCIGnlnE4XvKm5AzeHdPAhJBaHG9D8UXsp7GCAn4usfRCrAiEA5FbSYmhjOQw+JdN7v2qm42/neWHCu33H/GgHU5LdOLY=
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: omnibus_diff.sh
EOF-METADATA-END
*/
