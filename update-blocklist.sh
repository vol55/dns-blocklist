#!/bin/bash
set -euo pipefail

SING_BOX_VERSION="$(
  curl -fsSL \
    https://api.github.com/repos/SagerNet/sing-box/releases/latest |
    jq -r '.tag_name' |
    sed 's/^v//'
)"

LIST_URL="https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt"
SING_BOX_URL="https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz"

WORK_DIR="work"
SING_BOX_DIR="${WORK_DIR}/sing-box-${SING_BOX_VERSION}-linux-amd64"
SING_BOX="${SING_BOX_DIR}/sing-box"

RELEASE_TAG="latest"
RELEASE_TITLE="dns-blocklist"

mkdir -p "$WORK_DIR"

echo "Clean up ..."
find "$WORK_DIR" \
  -mindepth 1 \
  -maxdepth 1 \
  -type d \
  -name 'sing-box-*-linux-amd64' \
  ! -name "sing-box-${SING_BOX_VERSION}-linux-amd64" \
  -exec rm -rf -- {} +
rm -f "${WORK_DIR}/sing-box.tar.gz"
rm -f "${WORK_DIR}/rules.txt"
rm -f "${WORK_DIR}/dns-blocklist.srs"

if [[ -x "$SING_BOX" ]]; then
  echo "sing-box ${SING_BOX_VERSION} already downloaded"
else
  echo "Downloading sing-box ${SING_BOX_VERSION}..."

  curl -fL "$SING_BOX_URL" \
    -o "${WORK_DIR}/sing-box.tar.gz"

  tar -xzf "${WORK_DIR}/sing-box.tar.gz" \
    -C "$WORK_DIR"

  rm -f "${WORK_DIR}/sing-box.tar.gz"
fi

echo "Downloading rules ..."
curl -fL "$LIST_URL" \
  -o "${WORK_DIR}/rules.txt"

echo "Converting to sing-box rule-set..."
"$SING_BOX" rule-set convert \
  --type adguard \
  --output "${WORK_DIR}/dns-blocklist.srs" \
  "${WORK_DIR}/rules.txt"

if [[ ! -s "${WORK_DIR}/dns-blocklist.srs" ]]; then
  echo "Failed to create dns-blocklist.srs" >&2
  exit 1
fi

echo "Publishing release ..."
if gh release view "$RELEASE_TAG" >/dev/null 2>&1; then
  echo "Release '${RELEASE_TAG}' already exists, updating asset ..."

  gh release upload "$RELEASE_TAG" \
    "${WORK_DIR}/dns-blocklist.srs" \
    --clobber
else
  echo "Creating release '${RELEASE_TAG}' ..."

  gh release create "$RELEASE_TAG" \
    "${WORK_DIR}/dns-blocklist.srs" \
    --title "$RELEASE_TITLE" \
    --latest
fi

echo "Release published"
