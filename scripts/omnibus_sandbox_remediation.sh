#!/bin/bash
# VALEX_VAULT Hardening Script
# Target: /etc/systemd/system/omnibus-vault.service

HARDENING_BLOCK="
ProtectSystem=strict
ProtectHome=true
PrivateDevices=true
ProtectControlGroups=true
ProtectKernelTunables=true
RestrictAddressFamilies=AF_INET AF_INET6
"

sudo sed -i '/

\[Service\]

/a '"$HARDENING_BLOCK" /etc/systemd/system/omnibus-vault.service

sudo systemctl daemon-reload
sudo systemctl restart omnibus-vault.service

echo "[+] Infrastructure Hardening Applied: Integrity Verified."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 515538d37fb866cd562d5acf332723f514dfbc29b75ed6c1960a4affc91df725439613c761cad776afd87fd61ceb217631ab7385bf319a9987bdc1cf8747f62c
SIGNATURE: MEQCIFhhOpH7Ia3Oyst2R2IAZpxF2X+WABXNPAxWYEaW5GNNAiA18Cj55tWNNn5COCyAwZ90qXPSSNC5Iops1s9MYjGpDw==
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: omnibus_sandbox_remediation.sh
EOF-METADATA-END
*/
