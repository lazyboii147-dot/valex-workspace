#!/usr/bin/env bash
set -euo pipefail

OUTDIR="${OUTDIR:-./evidence_$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$OUTDIR"
log(){ echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $*"; }

# CONFIG: edit these
DC_HOSTS=("dc1.example.local" "dc2.example.local")   # SSHable jump hosts or use az vm run-command
NAC_HOSTS=("nac1.example.local")                     # SSH/API endpoints for NAC/AP controllers
RADIUS_LOG_PATH="/var/log/radius/radius.log"         # adjust per vendor
AZ_RG="<resource-group>"                             # for az run-command if using Azure VMs
AZ_VM_DC_NAMES=("dc-vm-01" "dc-vm-02")               # if DCs are Azure VMs and you prefer az run-command
SUSPECT_USERNAME="<locked_username>"                 # optional: speed up search
TIME_WINDOW_HOURS=6

# 1) Collect 4740 events from Domain Controllers (via az run-command or SSH)
collect_dc_lockouts() {
  log "Collecting Event ID 4740 from DCs (last ${TIME_WINDOW_HOURS}h)"
  for dc in "${AZ_VM_DC_NAMES[@]}"; do
    out="$OUTDIR/${dc}_4740.json"
    log "Running Get-WinEvent on $dc via az vm run-command (requires Azure VM)"
    az vm run-command invoke -g "$AZ_RG" -n "$dc" \
      --command-id RunPowerShellScript \
      --scripts "Get-WinEvent -FilterHashtable @{LogName='Security';Id=4740;StartTime=(Get-Date).AddHours(-$TIME_WINDOW_HOURS)} | Select TimeCreated, @{n='TargetUser';e={\$_.Properties[0].Value}}, @{n='CallerComputer';e={\$_.Properties[1].Value}}, @{n='IpAddress';e={\$_.Properties[18].Value}} | ConvertTo-Json -Depth 4" \
      -o json > "$out" || { log "az run-command failed for $dc; check permissions"; }
    sha256sum "$out" > "$out.sha256"
  done
}

# 2) Pull RADIUS logs from NACs (SSH)
collect_radius_logs() {
  log "Collecting RADIUS logs from NAC hosts"
  for host in "${NAC_HOSTS[@]}"; do
    dest="$OUTDIR/${host}_radius.log"
    log "SSH $host: tail -n 5000 $RADIUS_LOG_PATH"
    ssh "$host" "sudo tail -n 5000 $RADIUS_LOG_PATH" > "$dest" || log "SSH failed to $host"
    sha256sum "$dest" > "$dest.sha256"
  done
}

# 3) Grep for suspect username / repeated failures and extract IP/MAC
analyze_radius() {
  log "Analyzing radius logs for repeated failures"
  for f in "$OUTDIR"/*_radius.log; do
    [ -f "$f" ] || continue
    echo "---- $f ----" > "$f.analysis"
    # vendor-agnostic heuristics: look for 'Fail', 'Access-Reject', 'EAP', username, MACs, IPs
    grep -Ei "reject|fail|access-reject|eap|mschap|$SUSPECT_USERNAME" "$f" | sed -n '1,200p' >> "$f.analysis"
    # extract candidate IPs and MACs
    grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' "$f" | sort -u >> "$f.analysis.ips" || true
    grep -Eo '([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}' "$f" | sort -u >> "$f.analysis.macs" || true
    sha256sum "$f.analysis" "$f.analysis.ips" "$f.analysis.macs" 2>/dev/null >> "$f.sha256" || true
    log "Wrote analysis for $f"
  done
}

# 4) Optionally clear cached credentials on a Windows endpoint via az vm run-command
clear_windows_cached_creds() {
  local vm="$1"
  local target="$2"  # target string from cmdkey list to delete
  log "Clearing cached creds on $vm for target $target"
  az vm run-command invoke -g "$AZ_RG" -n "$vm" \
    --command-id RunPowerShellScript \
    --scripts "cmdkey /list; cmdkey /delete:$target; cmdkey /list" -o json > "$OUTDIR/${vm}_cmdkey_result.json"
  sha256sum "$OUTDIR/${vm}_cmdkey_result.json" > "$OUTDIR/${vm}_cmdkey_result.json.sha256"
}

# 5) Optionally remove WLAN profile (Windows) via run-command
delete_wlan_profile() {
  local vm="$1"
  local profile="$2"
  log "Deleting WLAN profile $profile on $vm"
  az vm run-command invoke -g "$AZ_RG" -n "$vm" \
    --command-id RunPowerShellScript \
    --scripts "netsh wlan show profiles; netsh wlan delete profile name='$profile'; netsh wlan show profiles" -o json > "$OUTDIR/${vm}_wlan_${profile}.json"
  sha256sum "$OUTDIR/${vm}_wlan_${profile}.json" > "$OUTDIR/${vm}_wlan_${profile}.json.sha256"
}

# 6) Temporarily disable port or block MAC on NAC (example via SSH command) - vendor specific
block_mac_on_nac() {
  local host="$1" mac="$2"
  log "Temporarily blocking MAC $mac on $host (vendor CLI/API required)"
  # Example placeholder: on some controllers you can run 'deny mac <mac>'
  ssh "$host" "sudo /usr/local/bin/nacctl block-mac $mac" || log "Block command failed; implement vendor API call"
  echo "Blocked $mac on $host" > "$OUTDIR/${host}_blocked_${mac}.txt"
  sha256sum "$OUTDIR/${host}_blocked_${mac}.txt" > "$OUTDIR/${host}_blocked_${mac}.txt.sha256"
}

# 7) Test authentication from a Linux client (simulate EAP/802.1X is vendor-specific; here we do a simple network test)
test_auth_from_client() {
  local client_ip="$1"
  log "Testing connectivity from client $client_ip (ping + curl to test endpoint)"
  ping -c 3 "$client_ip" > "$OUTDIR/test_ping_${client_ip}.txt" 2>&1 || true
  curl -sS --max-time 10 "http://$client_ip" > "$OUTDIR/test_http_${client_ip}.txt" 2>&1 || true
  sha256sum "$OUTDIR/test_ping_${client_ip}.txt" "$OUTDIR/test_http_${client_ip}.txt" > "$OUTDIR/test_${client_ip}.sha256" || true
}

# Run sequence
collect_dc_lockouts
collect_radius_logs
analyze_radius

log "Triage complete. Evidence in $OUTDIR"
log "Next: inspect *_analysis files for candidate IPs/MACs and correlate with DC 4740 outputs."
log "To clear cached creds or delete WLAN profiles, use clear_windows_cached_creds <vm> <target> and delete_wlan_profile <vm> <profile> functions."

# End
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 1f7fcec95cb22a89026b91b98c7df5a6b62863046470fbb5dd9ca6c2f33b38325302dfc0165f5e429714a675b94b7abf7503bf2c7d307c6a93f90727d2199324
SIGNATURE: MEUCIG4uyxE2qJmrSwQMSi3plnHEcm87auPnjuZoXcEtVdTzAiEA6zWY/k6lh6+6ViNunwAXY9Zn/NBOXNYWlG0tRC5QwKs=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: radius-lockout-triage.sh
EOF-METADATA-END
*/
