#!/bin/bash
LOCAL_FILE="/VALEX_VAULT/audit_cleartext_trail.log"
REMOTE_DEST="/secure/staging/"
PRIV_KEY="/VALEX_VAULT/private.pem"
SIG_FILE="${LOCAL_FILE}.sig"

# Sign and dispatch
openssl dgst -sha256 -sign "$PRIV_KEY" -out "$SIG_FILE" "$LOCAL_FILE"
# Transmission logic to Gardena-90247-Alpha
scp "$LOCAL_FILE" "$SIG_FILE" "olvi@gardena-alpha-node:$REMOTE_DEST"
/*
EOF-METADATA-BEGIN
HASH: 8bd43b7feeb873ed7d55b287f3a145794b3caa0545f3a11bac35b552988e01b1b0c9a426fc21cd001b4e5825753ea60f4ea9bde7ed00be4e5779ee165b8a16ef
SIGNATURE: MEYCIQD+se8KYONzVt7sGb/dzfRGz7ujKp90C9Kti4rqJWXNiQIhANGTObKhX8jaPqsCrZIIy7mWsw8tkL2jftcQcTAKqBer
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: dispatch_seal.sh
EOF-METADATA-END
*/
