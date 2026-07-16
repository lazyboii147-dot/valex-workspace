#!!/bin/bash
# ==============================================================================
# SCRIPT: TheKeyFlay.sh
# ROLE: Manual Vault Cryptographic Asset Discovery & Cataloging
# AUTHOR: Lead Analyst Enrique B. Gonzalez III (CajaCl34r)
# NODE: 90247-GARDENA
# LEGAL BASELINE: CFAA (18 U.S.C. § 1030) // SECURE Data Act Compliance
# ==============================================================================

VAULT_DIR="/VALEX_VAULT"
LOG_OUT="./vault_key_audit_$(date +%Y%m%dT%H%M%SZ).log"

echo "=============================================================================="
echo "[*] INITIATING MANUAL KEY DISCOVERY PROTOCOL WITHIN: $VAULT_DIR"
echo "[*] TARGET LEDGER: $LOG_OUT"
echo "=============================================================================="

if [ ! -d "$VAULT_DIR" ]; then
    echo "[!] ERROR: Target vault path '$VAULT_DIR' does not exist."
    exit 1
fi

{
    echo "=== VALEX_VAULT CRYPTOGRAPHIC ASSET AUDIT ==="
    echo "Timestamp: $(date -u)"
    echo "------------------------------------------------------------------"
    
    # 1. Search by explicit file extension patterns
    echo "[*] Scanning for targeted key extensions (.key, .pub, .asc, .pem, .crt, .sig)..."
    find "$VAULT_DIR" -type f \( -name "*.key" -o -name "*.pub" -o -name "*.asc" -o -name "*.pem" -o -name "*.crt" -o -name "*.sig" \) -exec ls -la {} \;
    
    echo ""
    # 2. Search by internal header signatures (GPG/PGP/OpenSSL structures)
    echo "[*] Scanning file contents for cryptographic armor headers..."
    find "$VAULT_DIR" -type f -not -path "*/.*" 2>/dev/null | while read -r target_file; do
        if grep -qE "BEGIN PGP|BEGIN PRIVATE|BEGIN PUBLIC|BEGIN CERTIFICATE" "$target_file" 2>/dev/null; then
            echo "[!] Cryptographic Header Detected:"
            ls -la "$target_file"
            grep -HnE "BEGIN PGP|BEGIN PRIVATE|BEGIN PUBLIC|BEGIN CERTIFICATE" "$target_file" 2>/dev/null
            echo "------------------------------------------------------------------"
        fi
    done

    echo ""
    # 3. Check specific operational key registries matching your naming conventions
    echo "[*] Scanning for raw symmetric key allocations (e.g., openssl_symmetric.key)..."
    find "$VAULT_DIR" -type f -name "*symmetric*.key" -exec ls -la {} \;

} | tee "$LOG_OUT"

echo "=============================================================================="
echo "[+] EXTRACTION PROTOCOL COMPLETE // RESULTS SAVED TO $LOG_OUT"
echo "=============================================================================="
/*
*/
/*
EOF-METADATA-BEGIN
HASH: c72b29853e7521ae8cfac15bac8e6fd284725152b61e739a9e0cc404c6e31b832bf75d62802ca94c818003f2de466246dafc8abe9f87b61fed84f47db3ab9e28
SIGNATURE: MEYCIQCJZYRPIrYQK+slnXlZR2wcCbrByycWwCo/FN9OHInkpQIhAI7vOXXIw8b474gXQQZL8Tt0OJuzpi+AbXfvFhaNXPgu
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: TheKeyFlay.sh
EOF-METADATA-END
*/
