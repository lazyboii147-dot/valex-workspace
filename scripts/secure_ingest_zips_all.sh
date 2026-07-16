#!/usr/bin/env bash
set -euo pipefail

# secure_ingest_zips_all.sh
# Finds all .zip under /mnt/c, copies into /VALEX_VAULT/zips/YYYYMMDD/<sanitized-source>/,
# verifies sha256, removes original only after verification, records manifest, sets secure perms.
#
# Usage:
#   sudo /VALEX_VAULT/scripts/secure_ingest_zips_all.sh
#   sudo /VALEX_VAULT/scripts/secure_ingest_zips_all.sh --dry-run
#   sudo /VALEX_VAULT/scripts/secure_ingest_zips_all.sh --undo

ROOT_SEARCH="/mnt/c"
VAULT_ROOT="/VALEX_VAULT"
VAULT_SUBDIR="zips"
MANIFEST_DIR="${VAULT_ROOT}/.manifests"
DRY_RUN=false
UNDO=false
TIMESTAMP(){ date -u +"%Y%m%dT%H%M%SZ"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=true; shift ;;
    --undo) UNDO=true; shift ;;
    -h|--help) sed -n '1,240p' "$0"; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

mkdir -p "$MANIFEST_DIR"
MANIFEST_FILE="$MANIFEST_DIR/manifest_$(TIMESTAMP).csv"

# Undo last run
if [ "$UNDO" = true ]; then
  last_manifest=$(ls -1t "$MANIFEST_DIR"/manifest_*.csv 2>/dev/null | head -n1 || true)
  if [ -z "$last_manifest" ]; then
    echo "No manifest found to undo." >&2
    exit 1
  fi
  echo "Restoring files from manifest: $last_manifest"
  tail -n +2 "$last_manifest" | while IFS=, read -r src dst sha ts action; do
    [ -z "$src" ] && continue
    [ "$src" = "src" ] && continue
    src=$(echo "$src" | tr -d '"')
    dst=$(echo "$dst" | tr -d '"')
    if [ -f "$dst" ]; then
      echo "Restoring: $dst -> $src"
      if [ "$DRY_RUN" = false ]; then
        mkdir -p "$(dirname "$src")"
        mv -n -- "$dst" "$src"
        chmod 600 "$src" || true
        chown root:root "$src" 2>/dev/null || true
      fi
    else
      echo "Vault file missing, cannot restore: $dst" >&2
    fi
  done
  exit 0
fi

# Find zip files (case-insensitive)
mapfile -t ZIPFILES < <(find "$ROOT_SEARCH" -type f -iname '*.zip' -print 2>/dev/null || true)

if [ ${#ZIPFILES[@]} -eq 0 ]; then
  echo "No .zip files found under $ROOT_SEARCH"
  exit 0
fi

echo "Found ${#ZIPFILES[@]} zip files under $ROOT_SEARCH"
echo "src,dst,sha256,timestamp,action" > "$MANIFEST_FILE"

for src in "${ZIPFILES[@]}"; do
  date_dir="$(date -u +%Y%m%d)"
  rel="${src#${ROOT_SEARCH}/}"
  safe_rel=$(printf '%s' "$rel" | sed 's#/#__#g' | sed 's#[^A-Za-z0-9._-]#_#g')
  dst_dir="${VAULT_ROOT}/${VAULT_SUBDIR}/${date_dir}/${safe_rel%__*}"
  if [ "$dst_dir" = "${VAULT_ROOT}/${VAULT_SUBDIR}/${date_dir}/" ]; then
    dst_dir="${VAULT_ROOT}/${VAULT_SUBDIR}/${date_dir}/root"
  fi
  dst_dir=$(echo "$dst_dir" | sed 's#//+#/#g')
  dst="$dst_dir/$(basename "$src")"

  if [ "$DRY_RUN" = true ]; then
    echo "\"$src\",\"$dst\",,\"$(TIMESTAMP)\",DRY-RUN" >> "$MANIFEST_FILE"
    echo "DRY-RUN: $src -> $dst"
    continue
  fi

  mkdir -p "$dst_dir"
  chmod 700 "$dst_dir"
  chown root:root "$dst_dir" 2>/dev/null || true

  src_sha=$(sha256sum "$src" | awk '{print $1}')

  # copy file
  rsync -a --ignore-existing -- "$src" "$dst_dir/" || { echo "rsync failed for $src"; echo "\"$src\",\"$dst\",\"RSYNC-FAILED\",\"$(TIMESTAMP)\",FAILED" >> "$MANIFEST_FILE"; continue; }
  dst="$dst_dir/$(basename "$src")"
  dst_sha=$(sha256sum "$dst" | awk '{print $1}')

  if [ "$src_sha" != "$dst_sha" ]; then
    echo "Hash mismatch for $src -> $dst; src:$src_sha dst:$dst_sha" >&2
    rm -f -- "$dst"
    echo "\"$src\",\"$dst\",\"HASH-MISMATCH\",\"$(TIMESTAMP)\",FAILED" >> "$MANIFEST_FILE"
    continue
  fi

  chmod 600 "$dst"
  chown root:root "$dst" 2>/dev/null || true

  echo "\"$src\",\"$dst\",\"$dst_sha\",\"$(TIMESTAMP)\",COPIED" >> "$MANIFEST_FILE"

  # remove original after successful verification
  rm -f -- "$src"
  echo "\"$src\",\"$dst\",\"$dst_sha\",\"$(TIMESTAMP)\",REMOVED-ORIGINAL" >> "$MANIFEST_FILE"
done

sha256sum "$MANIFEST_FILE" > "${MANIFEST_FILE}.sha256"
chmod 600 "$MANIFEST_FILE" "${MANIFEST_FILE}.sha256" || true
chown root:root "$MANIFEST_FILE" "${MANIFEST_FILE}.sha256" 2>/dev/null || true

echo "Manifest written to $MANIFEST_FILE"
echo "Manifest SHA256 in ${MANIFEST_FILE}.sha256"
echo "Done."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: c253ec4d88cf0f6c0a1e3c970035dec77ffb29ea04ba0bb07b1175ed5a6a9d03ea908149d0e362f492cdfd3920ad7ef5044e9d50ef80c43d680f53c3b85880de
SIGNATURE: MEQCIClDyqWJnsyYPqNQdr7cYbwkwVJdsqg3C9miOQBYLwPqAiBrcqYHmZRwGJR4Dq2YE7tkK57+7ndKth1miKx60YL8lA==
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: secure_ingest_zips_all.sh
EOF-METADATA-END
*/
