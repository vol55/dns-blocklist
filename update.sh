#!/bin/bash
set -euo pipefail

LIST_URL="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"

SING_BOX="${HOME}/.cache/sing-box/sing-box"
OUTPUT="dns-blocklist.srs"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

[[ -x "$SING_BOX" ]] || {
  echo "sing-box not found" >&2
  exit 1
}

echo "Downloading rules..."
curl -fL \
  --connect-timeout 10 \
  --max-time 120 \
  --retry 3 \
  --retry-delay 5 \
  --retry-all-errors \
  "$LIST_URL" \
  -o "${WORK_DIR}/rules.txt"

echo "Converting rules..."
"$SING_BOX" rule-set convert \
  --type adguard \
  --output "$OUTPUT" \
  "${WORK_DIR}/rules.txt"

[[ -s "$OUTPUT" ]] || {
  echo "Failed to create $OUTPUT" >&2
  exit 1
}

echo "Created $OUTPUT"
