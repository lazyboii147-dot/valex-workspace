#!/bin/bash
# Language: Bash
# Purpose: Disable inheritance-based ACLs on a specified folder in macOS

# Function to display usage
usage() {
    echo "Usage: $0 /VALEX_VAULT/"
    exit 1
}

# Check if folder path is provided
if [ $# -ne 1 ]; then
    usage
fi

TARGET_FOLDER="$1"

# Check if folder exists
if [ ! -d "$TARGET_FOLDER" ]; then
    echo "Error: Folder '$TARGET_FOLDER' does not exist."
    exit 2
fi

# Remove all ACL entries (disables inheritance)
echo "Removing all ACL entries (disables inheritance) for '$TARGET_FOLDER'..."
chmod -N "$TARGET_FOLDER"

# Verify ACL removal
echo "Current ACLs for '$TARGET_FOLDER':"
ls -le "$TARGET_FOLDER"

echo "Inheritance has been disabled successfully."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 4b33fa169f3071bb3c8dccbcb6d9cc481931822435c4899345cc9081d62cee42d0cf0bc8ec6aa2c7d8bebdcc3d935d4db1ffc587a7a93c23765a0e6f3893b67e
SIGNATURE: MEUCIDlDKpyTg/507YykrF/Q1cTGy2NYdL87WjPixVJiiCR9AiEA/4Y3I1iAlsHV0Of29FzUE+Uxm1OGBaLSzcEhVmtYJh4=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: disable_inheritance.sh
EOF-METADATA-END
*/
