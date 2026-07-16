#!/usr/bin/env bash
# ==============================================================================
# SCRIPT: verify_and_extract_key.sh
# PURVIEW: Target validation, integrity verification, and cryptographic isolation
# ==============================================================================
set -euo pipefail

# Define strict targeting parameters
EXPECTED_SHA256="3915cc909286446c51fe3d470b82970eeb8c2d825b17a515c3fba9c62773cef2"
TARGET_FILE="./local_triage_20260528T115758Z.tgz"
STAGE_DIR="./.tmp_triage_extraction_$(date +%s)"

echo "[*] Phase 1: Initiating structural integrity audit..."

# 1. Verify existence of the targeted manifest archive
if [ ! -f "$TARGET_FILE" ]; then
    echo "[-] Error: Target file '$TARGET_FILE' not found in current workspace." >&2
    exit 1
fi

# 2. Assert SHA-256 integrity match before any execution or extraction
echo "[*] Computing SHA-256 hash for verification..."
COMPUTED_SHA256=$(sha256sum "$TARGET_FILE" | awk '{print $1}')

if [ "$COMPUTED_SHA256" != "$EXPECTED_SHA256" ]; then
    echo "[-] CRITICAL ERROR: Integrity validation failed." >&2
    echo "    Expected: $EXPECTED_SHA256" >&2
    echo "    Computed: $COMPUTED_SHA256" >&2
    exit 2
fi
echo "[+] Integrity Check: PASSED. Payload signature matches exactly."

# 3. Create isolated runtime directory for extraction
mkdir -p "$STAGE_DIR"
trap 'rm -rf "$STAGE_DIR"' EXIT

echo "[*] Phase 2: Extracting target archive to isolated staging area..."
tar -xzf "$TARGET_FILE" -C "$STAGE_DIR"

# 4. Scan staging area for OpenSSL/SSH private keys or PEM containers
echo "[*] Phase 3: Locating cryptographic key assets..."
KEY_FILE=$(find "$STAGE_DIR" -type f \( -name "*.pem" -o -name "id_*" -o -name "*key*" \) | head -n 1)

if [ -z "$KEY_FILE" ]; then
    # Fallback: scan file contents for standard PEM boundaries if naming conventions differ
    KEY_FILE=$(grep -lR "BEGIN " "$STAGE_DIR" | head -n 1 || true)
fi

if [ -z "$KEY_FILE" ]; then
    echo "[-] Error: No valid OpenSSL PEM structures or SSH keys detected inside the payload." >&2
    exit 3
fi

echo "[+] Target key discovered: $(basename "$KEY_FILE")"
echo "------------------------------------------------------------------------"

# 5. Non-destructive parsing of the key structure (Human-in-the-loop review)
if grep -q "PRIVATE KEY" "$KEY_FILE"; then
    echo "[*] Displaying non-sensitive OpenSSL Private Key Metadata:"
    openssl pkey -in "$KEY_FILE" -text -noout 2>/dev/null | head -n 10
    
    echo -e "\n[*] Computing internal MD5 public modulus fingerprint for verification:"
    openssl pkey -in "$KEY_FILE" -pubout -outform PEM 2>/dev/null | openssl md5 -c
elif grep -q "PUBLIC KEY" "$KEY_FILE" || grep -q "ssh-" "$KEY_FILE"; then
    echo "[*] Target asset identified as a public key component."
    echo "[*] Generating standard SHA-256 public key fingerprint:"
    ssh-keygen -lf "$KEY_FILE"
else
    echo "[!] File contains structural data but format could not be auto-parsed natively."
    cat "$KEY_FILE" | head -n 5
fi

echo "------------------------------------------------------------------------"
echo "[+] Operation complete. Isolated extraction environment has been purged safely."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 60a808b9e027f520e0c5c16726bdbdcec8eb621c69098227687baa170713513971d24a4539473b7c7788507113c81b43d6997a31ae1b3a6dee059c8338bc1b35
SIGNATURE: MEUCIQCGMklFM/d0B+03gAVldgoXRQHbC1Qu64/XOTAzQ2KfCAIgfIN3Ss3lkDkIayaHzLvn9WxyfDby/nrt5gXQE/Kp+OM=
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: verify_and_extract_key.sh
EOF-METADATA-END
*/
