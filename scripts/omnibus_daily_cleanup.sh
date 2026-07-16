#!/usr/bin/env bash
set -euo pipefail

VAULT="/VALEX_VAULT"
DATE=$(date +"%Y%m%d")
TARGET="$VAULT/ingest/$DATE"

mkdir -p "$TARGET"

IGNORE=(
  bin boot dev etc home lib lib64 lost+found media mnt opt proc root run
  sbin srv sys tmp usr var init VALEX_VAULT
)

should_ignore() {
  local item="$1"
  for ignore in "${IGNORE[@]}"; do
    [[ "$item" == "$ignore" ]] && return 0
  done
  return 1
}

LOG="$VAULT/reports/cleanup_$DATE.log"
mkdir -p "$VAULT/reports"

echo "VALEX DAILY CLEANUP — $DATE" | tee "$LOG"

for item in /*; do
  base=$(basename "$item")

  if should_ignore "$base"; then
    echo "[SKIP] /$base" | tee -a "$LOG"
    continue
  fi

  echo "[MOVE] /$base → $TARGET/" | tee -a "$LOG"
  mv "$item" "$TARGET/"
done

echo "Cleanup complete." | tee -a "$LOG"
/*
EOF-METADATA-BEGIN
HASH: 0725dbde7423490e016182bdb6aa3abb2e8552e96a86207bbb7357a4d432ffeb6e80a514b8884960609110d04d354aa165e31e5d40412099d5e7abec7b6e5559
SIGNATURE: MEUCIQCrNRqSfpIQbpYMWFp2xs+JzUyag6TtopK24H4+w4WeMAIgAwBrYOpkmNXzV+ff8eaIOkqZwIHRIiKvUaF1AxjG6TA=
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: omnibus_daily_cleanup.sh
EOF-METADATA-END
*/
