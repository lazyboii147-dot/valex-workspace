#!/bin/bash
set -euo pipefail

VAULT="/VALEX_VAULT"
SYSTEMD="/etc/systemd/system"

echo "[*] Overwriting and installing full Omnibus Vault Suite..."

mkdir -p "$VAULT"
mkdir -p "$SYSTEMD"

###############################################
# 1. omnibus_audit.mjs
###############################################
cat << 'EOF' > "$VAULT/omnibus_audit.mjs"
#!/usr/bin/env node

import fs from 'fs'
import path from 'path'

const LOG_DIR = "/var/log"
const PATTERN = "TIRCE_VEC"

console.log("[*] Omnibus Audit: starting log scan", new Date().toISOString())

let matches = 0

function scanLogs() {
  const files = fs.readdirSync(LOG_DIR)
  for (const f of files) {
    const full = path.join(LOG_DIR, f)
    if (fs.statSync(full).isFile()) {
      const content = fs.readFileSync(full, 'utf8')
      if (content.includes(PATTERN)) {
        console.log("[MATCH]", full)
        matches++
      }
    }
  }
}

scanLogs()

console.log("[*] Matches found:", matches)
if (matches > 0) process.exit(2)
EOF

chmod +x "$VAULT/omnibus_audit.mjs"

###############################################
# 2. omnibus_diff.mjs
###############################################
cat << 'EOF' > "$VAULT/omnibus_diff.mjs"
#!/usr/bin/env node

import fs from 'fs'
import path from 'path'
import crypto from 'crypto'

const VAULT_DIR = "/VALEX_VAULT"
const MANIFEST = path.join(VAULT_DIR, "manifest.json")

function sha256(file) {
  return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex")
}

function walk(dir, base = dir, out = {}) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) walk(full, base, out)
    else if (entry.isFile() && full !== MANIFEST) {
      out[path.relative(base, full)] = sha256(full)
    }
  }
  return out
}

if (!fs.existsSync(MANIFEST)) {
  console.error("[CRITICAL] Missing manifest:", MANIFEST)
  process.exit(1)
}

const old = JSON.parse(fs.readFileSync(MANIFEST, "utf8"))
const now = walk(VAULT_DIR)

const added = Object.keys(now).filter(k => !old[k])
const removed = Object.keys(old).filter(k => !now[k])
const modified = Object.keys(old).filter(k => now[k] && now[k] !== old[k])

if (!added.length && !removed.length && !modified.length) {
  console.log("[+] No integrity changes detected.")
  process.exit(0)
}

console.log("=== INTEGRITY EXCEPTIONS ===")

for (const f of added) console.log("[UNTRACKED]", f)
for (const f of removed) console.log("[DELETED]", f)
for (const f of modified) console.log("[MODIFIED]", f)

process.exit(2)
EOF

chmod +x "$VAULT/omnibus_diff.mjs"

###############################################
# 3. omnibus-vault-manager.mjs
###############################################
cat << 'EOF' > "$VAULT/omnibus-vault-manager.mjs"
#!/usr/bin/env node

import fs from 'fs'
import path from 'path'
import crypto from 'crypto'
import readline from 'readline'
import { execSync } from 'child_process'

const VAULT_DIR = "/VALEX_VAULT"
const MANIFEST = path.join(VAULT_DIR, "manifest.json")
const KEY = path.join(process.env.HOME || "/root", ".ssh", "omnibus_ed25519")

function sha256(file) {
  return crypto.createHash("sha256").update(fs.readFileSync(file)).digest("hex")
}

function walk(dir, base = dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) walk(full, base, out)
    else if (entry.isFile() && full !== MANIFEST) {
      out.push({ path: full, hash: sha256(full) })
    }
  }
  return out
}

function ask(q) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })
  return new Promise(res => rl.question(q, a => { rl.close(); res(a) }))
}

async function main() {
  const files = walk(VAULT_DIR)
  const manifest = { version: 1, generated_at: new Date().toISOString(), files }

  const tmp = "/tmp/manifest.new.json"
  fs.writeFileSync(tmp, JSON.stringify(manifest, null, 2))

  const ok = await ask("Promote new manifest? (yes/no): ")
  if (ok.trim().toLowerCase() !== "yes") process.exit(0)

  fs.copyFileSync(tmp, MANIFEST)
  console.log("[+] Manifest updated.")

  execSync(`ssh-keygen -Y sign -f "${KEY}" -n file "${MANIFEST}"`, { stdio: "inherit" })
  console.log("[+] Manifest signed.")
}

main()
EOF

chmod +x "$VAULT/omnibus-vault-manager.mjs"

###############################################
# 4. manifest.json (overwrite)
###############################################
cat << 'EOF' > "$VAULT/manifest.json"
{
  "version": 1,
  "files": []
}
EOF

###############################################
# 5. systemd service
###############################################
cat << EOF > "$SYSTEMD/omnibus-audit.service"
[Unit]
Description=Omnibus Vault Audit
After=network.target

[Service]
Type=oneshot
ExecStart=$VAULT/omnibus_audit.mjs
ExecStartPost=$VAULT/omnibus_diff.mjs
StandardOutput=journal
StandardError=journal
EOF

###############################################
# 6. systemd timer
###############################################
cat << EOF > "$SYSTEMD/omnibus-audit.timer"
[Unit]
Description=Hourly Omnibus Vault Audit

[Timer]
OnBootSec=5min
OnUnitActiveSec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now omnibus-audit.timer

echo "[✓] Full overwrite complete. Omnibus Vault Suite installed."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 55670a3e91438ffee9eec9d6230c1fd4a007dae785d2c0c7801f98184f92ceb0428ea1e29e8c88fa4a4ffdb110cbb6a51adadfbbb042a7fbb0d9e1ec023c2d96
SIGNATURE: MEUCIQDhiC/0zNI/yKUSKa3RFPLmMjFXiy1gGcLyGODjGt+MwwIgFQVE7605QxtnYabo78uNRvBCcTpC97reNAmX1f5zSfI=
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: install_omnibus_overwrite.sh
EOF-METADATA-END
*/
