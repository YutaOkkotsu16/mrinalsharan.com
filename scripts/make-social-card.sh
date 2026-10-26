#!/usr/bin/env bash
# Renders scripts/social-card.html to assets/social-card.png (1200x630) with headless Chrome.
set -euo pipefail
cd "$(dirname "$0")/.."
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
"$CHROME" --headless=new --disable-gpu --hide-scrollbars --window-size=1200,630 \
  --virtual-time-budget=5000 --screenshot="$PWD/assets/social-card.png" \
  "file://$PWD/scripts/social-card.html" 2>/dev/null
echo "wrote assets/social-card.png"
