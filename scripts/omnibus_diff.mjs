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
