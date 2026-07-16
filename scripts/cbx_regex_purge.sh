#!/usr/bin/env bash
# === CLEARBOXX REGEX PURGE TOOL (AI ARTIFACT EDITION + DRY RUN) ===
# Usage:
#   ./cbx_regex_purge.sh --dry-run
#   ./cbx_regex_purge.sh --apply

set -euo pipefail

VAULT="/VALEX_VAULT"
MODE="${1:-}"

if [[ "$MODE" != "--dry-run" && "$MODE" != "--apply" ]]; then
    echo "Usage: $0 --dry-run | --apply"
    exit 1
fi

# AI-related patterns to remove (regex)
PATTERNS=(
    "gemini-code-"
    "gemini-[A-Za-z0-9_-]+"
    "gpt-[0-9]+"
    "gpt_[A-Za-z0-9_-]+"
    "chatgpt-[A-Za-z0-9_-]+"
    "llama-[A-Za-z0-9_-]+"
    "ai-gen-[A-Za-z0-9_-]+"
    "ai_generated_[A-Za-z0-9_-]+"
    "openai_[A-Za-z0-9_-]+"
    "anthropic_[A-Za-z0-9_-]+"
    "claude-[A-Za-z0-9_-]+"
    "model_[A-Za-z0-9]{8,}"
    "session_[A-Fa-f0-9]{32}"
    "tmp_[A-Za-z0-9]{8}"
    "DEBUG_[A-Z_]+"
)

echo "[PURGE] Mode: $MODE"
echo "[PURGE] Scanning $VAULT"

find "$VAULT" -type f | while read -r file; do
    if ! grep -Iq . "$file"; then
        echo "[SKIP] Binary or unreadable: $file"
        continue
    fi

    echo "[CHECK] $file"

    for pattern in "${PATTERNS[@]}"; do
        if grep -Eq "$pattern" "$file"; then
            if [[ "$MODE" == "--dry-run" ]]; then
                echo "  WOULD REMOVE: $pattern"
            else
                sed -i -E "s/$pattern//g" "$file"
                echo "  REMOVED: $pattern"
            fi
        fi
    done
done

echo "[PURGE] Completed."
/*
EOF-METADATA-BEGIN
HASH: 2ace7f0e983548a40039d25dc0314b6e943a0dc4af841c9f6b9966c988cdaf7818be13c01e1ac20f5fef0afea22469b00cb72201914ff0392ee6891ae22cb145
SIGNATURE: MEQCICkxbZfIgHUIF/RbGK681ZG+P/mpawKxJg2qNv4I7e1QAiAg0uMbkCm7UEDEYh9xiqtshmWSUkMmW15UV6b6b7h32A==
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: cbx_regex_purge.sh
EOF-METADATA-END
*/
