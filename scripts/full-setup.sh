#!/usr/bin/env bash
set -euo pipefail

echo "=== FULL AUTOMATED SETUP START ==="

###############################################
# 0. Ensure Node project exists
###############################################
if [ ! -f package.json ]; then
  echo "[+] Creating package.json..."
  npm init -y >/dev/null
fi

###############################################
# 1. Install Tailwind + PostCSS + Autoprefixer
###############################################
echo "[+] Installing Tailwind + PostCSS + Autoprefixer..."
npm install -D tailwindcss postcss autoprefixer

###############################################
# 2. Create Tailwind + PostCSS config if missing
###############################################
if [ ! -f tailwind.config.js ]; then
  echo "[+] Creating tailwind.config.js..."
  cat > tailwind.config.js <<'JS'
module.exports = {
  content: ["./**/*.{html,js,jsx,ts,tsx,py}"],
  theme: { extend: {} },
  plugins: [],
};
JS
fi

if [ ! -f postcss.config.js ]; then
  echo "[+] Creating postcss.config.js..."
  cat > postcss.config.js <<'JS'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
JS
fi

###############################################
# 3. Create input CSS
###############################################
mkdir -p static/css
cat > static/css/input.css <<'CSS'
@tailwind base;
@tailwind components;
@tailwind utilities;
CSS

###############################################
# 4. Build Tailwind CSS
###############################################
echo "[+] Building Tailwind CSS..."
npx tailwindcss -i ./static/css/input.css -o ./static/css/tailwind.css --minify

###############################################
# 5. Compute SRI
###############################################
echo "[+] Computing SRI..."
HASH=$(openssl dgst -sha512 -binary static/css/tailwind.css | openssl base64 -A)
INTEGRITY="sha512-$HASH"

###############################################
# 6. Patch ALL template types
###############################################
echo "[+] Patching templates (HTML, JSX, TSX, Django, Flask)..."

patch_file() {
  local f="$1"
  sed -i.bak \
    -e 's|<script[^>]*cdn.tailwindcss.com[^>]*></script>||g' \
    -e 's|<script[^>]*cdn.tailwindcss.com[^>]*/>||g' \
    "$f"

  if grep -q "</head>" "$f"; then
    if ! grep -q "static/css/tailwind.css" "$f"; then
      sed -i.bak \
        -e "s|</head>|<link rel=\"stylesheet\" href=\"/static/css/tailwind.css\" integrity=\"$INTEGRITY\" crossorigin=\"anonymous\" />\n</head>|" \
        "$f"
    fi
  fi
}

export -f patch_file
export INTEGRITY

find . -type f \( \
  -name "*.html" -o \
  -name "*.jsx" -o \
  -name "*.tsx" -o \
  -name "*.jinja" -o \
  -name "*.jinja2" -o \
  -name "*.ejs" \
\) -exec bash -c 'patch_file "$0"' {} \;

###############################################
# 7. Create GitHub Actions workflow
###############################################
echo "[+] Creating GitHub Actions workflow..."

mkdir -p .github/workflows

cat > .github/workflows/tailwind-build.yml <<'YML'
name: Auto Build Tailwind CSS

on:
  push:
  pull_request:

jobs:
  build-tailwind:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm install
      - run: npx tailwindcss -i ./static/css/input.css -o ./static/css/tailwind.css --minify
      - uses: actions/upload-artifact@v4
        with:
          name: tailwind-css
          path: static/css/tailwind.css
YML

###############################################
# 8. Done
###############################################
echo "=== SETUP COMPLETE ==="
echo "Tailwind CSS built at: static/css/tailwind.css"
echo "SRI: $INTEGRITY"
echo "GitHub Actions workflow created at .github/workflows/tailwind-build.yml"
echo "All templates patched and CDN removed."
/*
*/
/*
EOF-METADATA-BEGIN
HASH: be35ba37fd7a5c8f8e733f7cbdce235bdc2bd26906d0ae741934ea06560a09e33b38af7d5f935e509631f5666c6e83e89e9b2bd87e033cff0854ae06a757e4a6
SIGNATURE: MEUCIFdgOeDJmBKw6hQYH8XPRNkgZ4Nv+t1KImQYU+bQqWc4AiEA2tYIS1eJEyWMUUN7hPONbRholTHVrjRTqaWJ1h+i0R0=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: full-setup.sh
EOF-METADATA-END
*/
