#!/usr/bin/env node
const https = require("https");
const { createHash } = require("crypto");
const { JSDOM } = require("jsdom");

if (process.argv.length < 3) {
  console.error("Usage: node ci-verify-sri.js <page-url>");
  process.exit(2);
}

const pageUrl = process.argv[2];

function fetchBuffer(url) {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location)
        return resolve(fetchBuffer(new URL(res.headers.location, url).toString()));

      if (res.statusCode !== 200)
        return reject(new Error(`HTTP ${res.statusCode} for ${url}`));

      const chunks = [];
      res.on("data", c => chunks.push(c));
      res.on("end", () => resolve(Buffer.concat(chunks)));
    }).on("error", reject);
  });
}

function computeSha512Base64(buffer) {
  return createHash("sha512").update(buffer).digest("base64");
}

async function fetchText(url) {
  const buf = await fetchBuffer(url);
  return buf.toString("utf8");
}

(async () => {
  console.log("Fetching:", pageUrl);
  const html = await fetchText(pageUrl);
  const dom = new JSDOM(html, { url: pageUrl });
  const doc = dom.window.document;

  const scripts = Array.from(doc.querySelectorAll("script[src]")).map(s => ({
    src: new URL(s.getAttribute("src"), pageUrl).toString(),
    integrity: s.getAttribute("integrity")
  }));

  const missing = [];
  const mismatched = [];
  const ok = [];

  for (const s of scripts) {
    const isExternal = new URL(s.src).origin !== new URL(pageUrl).origin;

    if (!isExternal) continue;

    if (!s.integrity) {
      missing.push(s.src);
      continue;
    }

    const token = s.integrity.split(/\s+/).find(t => t.startsWith("sha512-"));
    if (!token) {
      mismatched.push({ src: s.src, reason: "no sha512 token" });
      continue;
    }

    const expected = token.replace("sha512-", "");

    try {
      const buf = await fetchBuffer(s.src);
      const computed = computeSha512Base64(buf);
      if (computed === expected) ok.push(s.src);
      else mismatched.push({ src: s.src, expected, computed });
    } catch (err) {
      mismatched.push({ src: s.src, reason: err.message });
    }
  }

  console.log("OK:", ok.length);
  console.log("Missing integrity:", missing.length);
  console.log("Mismatched:", mismatched.length);

  if (missing.length || mismatched.length) process.exit(1);
  process.exit(0);
})();
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 1269a412e6beb7654620c9f8f62bcce4a6317c952ebcdf00c6a81caaced92417ddeb1ba295ae097f108aaf91f15e34c11735a22d681689533d5d32ae73d039a3
SIGNATURE: MEUCIGXwTwAKUgTZzM6cagHymaOokR1bXS6zkfus0pPVqR0VAiEA8tvY/cT5rZ6uo4cxB1rOmZaqduks5JbG3PGqzZg3jt8=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: ci-verify-sri.js
EOF-METADATA-END
*/
