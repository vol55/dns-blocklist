#!/bin/bash
set -euo pipefail

RELEASE_TAG="latest"
RELEASE_TITLE="dns-blocklist"
OUTPUT="dns-blocklist.srs"

[[ -s "$OUTPUT" ]] || {
  echo "$OUTPUT not found or empty" >&2
  exit 1
}

echo "Publishing release..."
if gh release view "$RELEASE_TAG" >/dev/null 2>&1; then
  echo "Release '$RELEASE_TAG' already exists, updating asset..."

  gh release upload "$RELEASE_TAG" \
    "$OUTPUT" \
    --clobber
else
  echo "Creating release '$RELEASE_TAG'..."
  gh release create "$RELEASE_TAG" \
    "$OUTPUT" \
    --title "$RELEASE_TITLE" \
    --latest
fi

echo "Release published"
