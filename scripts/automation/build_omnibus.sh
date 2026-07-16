#!/usr/bin/env bash
# =====================================================================
#  VALEX SECURITY HARDENING AUTO‑BUILDER
#  Creates all directories, writes all remediation modules, and appends
#  patch content exactly as defined in your PCII remediation suite.
# =====================================================================

echo "[VALEX] Initializing security hardening build..."

# ---------------------------------------------------------
# 1. Create directory structure
# ---------------------------------------------------------
mkdir -p src/security
mkdir -p src/telemetry
mkdir -p src/rpc
mkdir -p src/wasm
mkdir -p server

echo "[VALEX] Directory structure created."

# ---------------------------------------------------------
# 2. Create URL Sanitizer
# ---------------------------------------------------------
cat > src/security/urlSanitizer.js << 'EOF'
// PATCH 1 — URL Sanitization Gateway
export function getSanitizedQueryParam(paramName) {
  const params = new URLSearchParams(window.location.search);
  const raw = params.get(paramName);
  if (!raw) return null;
  return raw.replace(/[^a-zA-Z0-9_\-.]/g, '');
}
EOF

# ---------------------------------------------------------
# 3. Secure Deep Merge
# ---------------------------------------------------------
cat > src/security/secureDeepMerge.js << 'EOF'
// PATCH 2 — Secure Deep Merge
export function secureDeepMerge(target, source) {
  if (!source || typeof source !== 'object' || Array.isArray(source)) return source;
  if (!target || typeof target !== 'object' || Array.isArray(target)) target = Object.create(null);

  for (const [key, value] of Object.entries(source)) {
    if (['__proto__','constructor','prototype'].includes(key)) continue;
    target[key] =
      value && typeof value === 'object' && !Array.isArray(value)
        ? secureDeepMerge(target[key] || Object.create(null), value)
        : value;
  }
  return target;
}
EOF

# ---------------------------------------------------------
# 4. Immutable Config Registry
# ---------------------------------------------------------
cat > src/security/immutableConfig.js << 'EOF'
// PATCH 3 — Immutable Config Registry
export function createImmutableConfig(raw) {
  const registry = Object.create(null);
  for (const [key, value] of Object.entries(raw)) {
    if (['__proto__','constructor','prototype'].includes(key)) continue;
    registry[key] =
      value && typeof value === 'object' && !Array.isArray(value)
        ? createImmutableConfig(value)
        : value;
  }
  return Object.freeze(registry);
}
EOF

# ---------------------------------------------------------
# 5. Safe Logging Wrapper
# ---------------------------------------------------------
cat > src/security/safeLog.js << 'EOF'
// PATCH 5 — Safe Logging Wrapper
let lastLog = 0;
const LOG_INTERVAL = 2000;

export function safeLog(level, message, context = {}) {
  const now = Date.now();
  if (now - lastLog < LOG_INTERVAL) return;
  lastLog = now;

  const msg = String(message).replace(/[\r\n\t]/g, ' ');
  const ctx = {};
  for (const [k, v] of Object.entries(context)) {
    ctx[k] = typeof v === 'string'
      ? v.replace(/[\r\n\t]/g, ' ').slice(0, 1024)
      : v;
  }
  console[level](`[VALEX] ${msg}`, ctx);
}
EOF

# ---------------------------------------------------------
# 6. CSP‑Aligned Fetch Wrapper
# ---------------------------------------------------------
cat > src/security/safeFetch.js << 'EOF'
import { safeLog } from './safeLog.js';

// PATCH 6 — CSP‑Aligned Fetch Wrapper
const CSP_ALLOWED = [
  'https://your-app.com',
  'https://api.your-app.com'
];

function isAllowed(url) {
  return CSP_ALLOWED.some(origin => url.startsWith(origin));
}

export async function safeFetch(url, options = {}) {
  if (!isAllowed(url)) throw new Error('Blocked by CSP policy');

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10000);

  try {
    const res = await fetch(url, { ...options, signal: controller.signal });
    clearTimeout(timeout);
    return res;
  } catch (err) {
    clearTimeout(timeout);
    safeLog('error', 'safeFetch failed', { url, error: err.message });
    throw err;
  }
}
EOF

# ---------------------------------------------------------
# 7. Telemetry Schema + SafeTrack
# ---------------------------------------------------------
cat > src/telemetry/telemetry.js << 'EOF'
// PATCH 4 — Telemetry Schema Enforcement
const TelemetrySchemas = {
  page_view: {
    required: ['path'],
    maxLengths: { path: 2048, campaignId: 128 }
  }
};

export function safeTrack(type, data) {
  const schema = TelemetrySchemas[type];
  if (!schema) return;

  const sanitized = {};
  for (const [k, v] of Object.entries(data)) {
    sanitized[k] = typeof v === 'string'
      ? v.replace(/[\r\n\t]/g, ' ').slice(0, 4096)
      : v;
  }

  for (const field of schema.required) {
    if (!sanitized[field]) return;
  }

  for (const [key, max] of Object.entries(schema.maxLengths)) {
    if (sanitized[key]) sanitized[key] = sanitized[key].slice(0, max);
  }

  sendTelemetryPayload({ type, data: sanitized });
}
EOF

# ---------------------------------------------------------
# 8. Hardened RPC Calls
# ---------------------------------------------------------
cat > src/rpc/bardRpc.js << 'EOF'
import { secureDeepMerge } from '../security/secureDeepMerge.js';
import { safeFetch } from '../security/safeFetch.js';

// PATCH — Harden BardChatUi RPC calls
export async function safeRpcCall(endpoint, payload) {
  const cleanPayload = secureDeepMerge({}, payload);

  if (!cleanPayload.rpcids || typeof cleanPayload.rpcids !== 'string') {
    console.warn('[VALEX] RPC call suppressed: invalid rpcids');
    return;
  }

  return safeFetch(endpoint, {
    method: 'POST',
    body: JSON.stringify(cleanPayload)
  });
}
EOF

# ---------------------------------------------------------
# 9. WASM Config Stabilizer
# ---------------------------------------------------------
cat > src/wasm/config.js << 'EOF'
import { createImmutableConfig } from '../security/immutableConfig.js';

// PATCH — Immutable WASM config
const rawConfig = {
  wasmVersion: '1.0.0',
  module: 'BardChatUi',
  requiredKeys: ['id', 'name']
};

export const WASM_CONFIG = createImmutableConfig(rawConfig);
EOF

# ---------------------------------------------------------
# 10. Server‑Side JSON Validation (PHP)
# ---------------------------------------------------------
cat > server/telemetry.php << 'EOF'
<?php
// PATCH 7 — Safe JSON Decoder
function decode_safe_json_to_array(string $json): array {
    $data = json_decode($json, true, 512, JSON_THROW_ON_ERROR);

    if (!is_array($data)) {
        throw new InvalidArgumentException('Invalid JSON payload');
    }

    array_walk_recursive($data, function (&$value) {
        if (is_string($value)) {
            $value = preg_replace('/[\r\n\t]/', ' ', $value);
        }
    });

    return $data;
}
?>
EOF

echo "[VALEX] All security modules created and patched successfully."
echo "[VALEX] You may now: git add . && git commit -m 'Install VALEX security hardening suite'"
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 91d3f8f8abf950ee5ea9352ce7add5b16da436ef8fa1c470a079cae2baf730141608e1a6605de86d4a054cb9779526f8547288db795496727d85214d8143df6c
SIGNATURE: MEYCIQDXSD8tXyjV1suvEy2gkrV9Uwy9y6vJFW1xLppsnUe8xgIhAJidACp4rGIklKFRdpMZYY/QtkeWCdMGYAiHcIXRscaf
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: build_omnibus.sh
EOF-METADATA-END
*/
