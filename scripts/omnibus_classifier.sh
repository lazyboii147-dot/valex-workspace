#!/usr/bin/env bash
set -euo pipefail

VAULT="/VALEX_VAULT"
DATE=$(date +"%Y%m%d")
SRC="$VAULT/ingest/$DATE"

mkdir -p "$VAULT/audits" "$VAULT/manifests" "$VAULT/logs" "$VAULT/scripts" "$VAULT/archives"

for item in "$SRC"/*; do
  base=$(basename "$item")

  case "$base" in
    omnibus_audit_*) mv "$item" "$VAULT/audits/" ;;
    manifest*|*.json) mv "$item" "$VAULT/manifests/" ;;
    *log*|telemetry*) mv "$item" "$VAULT/logs/" ;;
    *.sh|scripts*) mv "$item" "$VAULT/scripts/" ;;
    *.zip|*.tar|*.gz|archives*) mv "$item" "$VAULT/archives/" ;;
  esac
done
/*
EOF-METADATA-BEGIN
HASH: f7fc7ca1c41c9f4ea6b0582bc0787a1946f02f7fadacf3017f5edfb122c40b13b630895665638d3e957101e98567518c934d3ad6efac90af351f6c8ed867de72
SIGNATURE: MEUCIFNNo/CSGput8aHu7qQx3olSGOA4XNUe4gXUQyUYZUzSAiEA3j+PVXG6heIerTyp5VQpto3gIA8ZCdyYhoISRS3TCqc=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: omnibus_classifier.sh
EOF-METADATA-END
*/
