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
