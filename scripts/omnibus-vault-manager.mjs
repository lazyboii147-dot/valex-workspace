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
