y#!/usr/bin/env bash
set -euo pipefail

OUTDIR="${OUTDIR:-./local_triage_$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$OUTDIR"
log(){ echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"; }

# small helper to run commands with timeout and capture stdout+stderr
run() {
  local name="$1"; shift
  local cmd=( "$@" )
  local out="$OUTDIR/${name}.txt"
  local err="$OUTDIR/${name}.err"
  log "Running: ${cmd[*]}"
  # 20s default timeout; adjust per command if needed
  timeout 20 "${cmd[@]}" >"$out" 2>"$err" || true
  # if both files empty, write a note
  if [ ! -s "$out" ] && [ ! -s "$err" ]; then
    echo "No output (command may not be available or returned nothing)" > "$out"
  fi
}

log "Starting local triage; outputs -> $OUTDIR"

# 1. Show saved NetworkManager connections (exact names)
run nmcli_connections nmcli connection show

# 2. wpa_supplicant config (if present)
if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]; then
  run wpa_supplicant_config sudo cat /etc/wpa_supplicant/wpa_supplicant.conf
else
  echo "No /etc/wpa_supplicant/wpa_supplicant.conf present" > "$OUTDIR/wpa_supplicant_config.txt"
fi

# 3. running supplicant / network processes
run processes sh -c "ps aux | egrep 'wpa_supplicant|NetworkManager|wpa_cli' || true"

# 4. CIFS/SMB mounts and credentials
run mounts sh -c "mount | egrep -i 'cifs|smb' || echo 'no cifs/smb mounts found'"

# 5. grep for username= in common config dirs (fast)
run grep_username sh -c "grep -R --line-number --exclude-dir=proc --exclude-dir=sys --exclude-dir=dev 'username=' /etc/samba /etc/NetworkManager 2>/dev/null || true"

# 6. user and root crontabs
run cron_user sh -c "crontab -l 2>&1 || echo 'no user crontab or permission denied'"
run cron_root sudo crontab -l -u root 2>&1 || true

# 7. systemd timers (timeout 10s)
run timers systemctl list-timers --all

# 8. NetworkManager journal (last 1 hour) - short timeout
run nm_journal sudo journalctl -u NetworkManager --since "1 hour ago" --no-pager

# 9. syslog tail (last 500 lines)
if [ -f /var/log/syslog ]; then
  run syslog_tail sudo tail -n 500 /var/log/syslog
elif [ -f /var/log/messages ]; then
  run syslog_tail sudo tail -n 500 /var/log/messages
else
  echo "No syslog/messages file found" > "$OUTDIR/syslog_tail.txt"
fi

# 10. list network interfaces and routes
run ip_addr ip addr show
run ip_route ip route show

# 11. list saved secrets in NetworkManager (802.1x flags)
run nmcli_secrets nmcli -g 802-1x.connection-properties connection show || true

# 12. wpa_cli networks (if wpa_cli present)
if command -v wpa_cli >/dev/null 2>&1; then
  run wpa_cli_list sudo wpa_cli list_networks || true
fi

# 13. collect environment and user info
echo "user: $(whoami)" > "$OUTDIR/whoami.txt"
uname -a > "$OUTDIR/uname.txt"
date -u > "$OUTDIR/date.txt"

# 14. compute hashes
for f in "$OUTDIR"/*; do
  [ -f "$f" ] || continue
  sha256sum "$f" >> "$OUTDIR/hashes.sha256" 2>/dev/null || true
done

# 15. package (optional)
tar -czf "${OUTDIR}.tgz" -C "$(dirname "$OUTDIR")" "$(basename "$OUTDIR")"
sha256sum "${OUTDIR}.tgz" > "${OUTDIR}.tgz.sha256"

log "Triage complete. Files: $OUTDIR and ${OUTDIR}.tgz"
log "If a command produced no output, check the corresponding .err file in $OUTDIR for errors."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 38ec2f8490825216fd546f6c80568f1249111df35c59146cf8703b3754b864d27eafaa944d01b2dd7cea801c1e74bf23f058a210b5deba4b583c91796b129f29
SIGNATURE: MEYCIQC61WsCVWeIdFuCRNfC9Mq8jsztd+a885VFxEr+6QxKyQIhAPc15QaHg0giox9G0XJwymWhzIlLofitJwh10b7o1xlM
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: local-triage.sh
EOF-METADATA-END
*/
