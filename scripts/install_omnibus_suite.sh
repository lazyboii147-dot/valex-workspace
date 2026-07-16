#!/bin/bash
set -euo pipefail

echo "[*] Installing Omnibus Vault Security Suite..."

# -----------------------------
# 1. Create required directories
# -----------------------------
mkdir -p /VALEX_VAULT
mkdir -p /usr/local/bin
mkdir -p /etc/systemd/system

# -----------------------------
# 2. Create omnibus_audit.sh
# -----------------------------
cat << 'EOF' > /usr/local/bin/omnibus_audit.sh
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
EOF

chmod +x /usr/local/bin/omnibus_audit.sh

# -----------------------------
# 3. Create omnibus_diff.sh
# -----------------------------
cat << 'EOF' > /usr/local/bin/omnibus_diff.sh
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
EOF

chmod +x /usr/local/bin/omnibus_diff.sh

# -----------------------------
# 4. Create omnibus-vault-manager.mjs
# -----------------------------
cat << 'EOF' > /usr/local/bin/omnibus-vault-manager.mjs
#!/usr/bin/env node

import fs from 'fs'
import path from 'path'
import crypto from 'crypto'
import { fileURLToPath } from 'url'
import readline from 'readline'
import { execSync } from 'child_process'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const VAULT_DIR = '/VALEX_VAULT'
const MANIFEST_FILE = path.join(VAULT_DIR, 'manifest.json')
const KEY_PATH = path.join(process.env.HOME || '/root', '.ssh', 'omnibus_ed25519')

function sha256File(filePath) {
  const hash = crypto.createHash('sha256')
  hash.update(fs.readFileSync(filePath))
  return hash.digest('hex')
}

function buildManifest() {
  const files = []

  function walk(dir) {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const full = path.join(dir, entry.name)
      if (entry.isDirectory()) walk(full)
      else if (full !== MANIFEST_FILE) {
        files.push({ path: full, hash: sha256File(full) })
      }
    }
  }

  walk(VAULT_DIR)

  return {
    version: 1,
    generated_at: new Date().toISOString(),
    files
  }
}

function signManifest(manifestPath) {
  execSync(`ssh-keygen -Y sign -f "${KEY_PATH}" -n file "${manifestPath}"`, {
    stdio: 'inherit'
  })
}

async function confirm(prompt) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })
  return new Promise(resolve => {
    rl.question(`${prompt} [y/N]: `, ans => {
      rl.close()
      resolve(/^y(es)?$/i.test(ans.trim()))
    })
  })
}

async function main() {
  if (!fs.existsSync(VAULT_DIR)) {
    console.error(`[CRITICAL] Vault directory missing: ${VAULT_DIR}`)
    process.exit(1)
  }

  console.log('[*] Building new manifest snapshot...')
  const manifest = buildManifest()
  const tmpPath = '/tmp/manifest.new.json'
  fs.writeFileSync(tmpPath, JSON.stringify(manifest, null, 2))

  console.log(`[*] New manifest written to ${tmpPath}`)
  const ok = await confirm('Promote this manifest to baseline and sign it')
  if (!ok) process.exit(0)

  fs.copyFileSync(tmpPath, MANIFEST_FILE)
  console.log(`[*] Baseline manifest updated at ${MANIFEST_FILE}`)

  console.log('[*] Signing manifest...')
  signManifest(MANIFEST_FILE)
  console.log('[*] Manifest signing complete.')
}

main().catch(err => {
  console.error('[FATAL]', err)
  process.exit(1)
})
EOF

chmod +x /usr/local/bin/omnibus-vault-manager.mjs

# -----------------------------
# 5. Create omnibus-audit.service
# -----------------------------
cat << 'EOF' > /etc/systemd/system/omnibus-audit.service
[Unit]
Description=Omnibus Vault Security and Integrity Audit
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/omnibus_audit.sh
ExecStartPost=/usr/local/bin/omnibus_diff.sh
StandardOutput=journal
StandardError=journal
User=root
Group=root
ProtectSystem=full
ProtectHome=true
NoNewPrivileges=true
PrivateTmp=true
TimeoutStartSec=5min

[Install]
WantedBy=multi-user.target
EOF

# -----------------------------
# 6. Create omnibus-audit.timer
# -----------------------------
cat << 'EOF' > /etc/systemd/system/omnibus-audit.timer
[Unit]
Description=Runs Omnibus Vault Audit Hourly

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
Persistent=true
AccuracySec=1min

[Install]
WantedBy=timers.target
EOF

# -----------------------------
# 7. Touch manifest if missing
# -----------------------------
if [ ! -f /VALEX_VAULT/manifest.json ]; then
  echo '{"version":1,"files":[]}' > /VALEX_VAULT/manifest.json
fi

# -----------------------------
# 8. Enable systemd
# -----------------------------
systemctl daemon-reload
systemctl enable --now omnibus-audit.timer

echo "[✓] Omnibus Vault Suite installed successfully."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 27cc97e4845591815c6440bdb6d2cd86baa283189a44cef38451078e98e723f40d7234b342ac19acf012dc4d3df91bdb80a5f69d9fe51a7a55b2ea7f7075a6a3
SIGNATURE: MEYCIQDNQnSbbqgX1eOGmYbS4l9r1x2xHU8lMDGx0EDbZ/YeegIhALyfq09oSE7EQpYQhZ6fJdqB0EL2hhh3P/pmZiw2lmrV
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: install_omnibus_suite.sh
EOF-METADATA-END
*/
