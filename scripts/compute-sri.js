#!/usr/bin/env node
const https = require("https");
const { createHash } = require("crypto");

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

(async () => {
  const url = process.argv[2];
  if (!url) {
    console.error("Usage: compute-sri.js <url>");
    process.exit(2);
  }
  try {
    const buf = await fetchBuffer(url);
    const hash = createHash("sha512").update(buf).digest("base64");
    console.log(`sha512-${hash}`);
  } catch (err) {
    console.error("Fetch failed:", err.message);
    process.exit(1);
  }
})();
/*
*/
/*
EOF-METADATA-BEGIN
HASH: b27f6d5e45a51f7a107f62c465bed3cb0ec7b7a3fffa7a30210c35c31088d79edf90ccef2986fad5d762540e58aedf09eb052384c4f4ab59eeb2954962c0fd5d
SIGNATURE: MEUCIDD+p0EAjzyZZapy+ZsIlz+yj7wQ9Mg5aZx9sBI8fzZaAiEA9u7gPwWj6YfxA1xwyzyCqpu8BCF7moG2c9G2/oli+o4=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: compute-sri.js
EOF-METADATA-END
*/
