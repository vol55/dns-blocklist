#!/bin/bash
set -euo pipefail

OUTPUT="dns-blocklist.srs"
RELEASE_TAG="build-${GITHUB_RUN_NUMBER}-${GITHUB_RUN_ATTEMPT}"
RELEASE_TITLE="dns-blocklist"

[[ -s "$OUTPUT" ]] || {
  echo "$OUTPUT not found or empty" >&2
  exit 1
}

echo "Creating release '$RELEASE_TAG'..."

gh release create "$RELEASE_TAG" \
  "$OUTPUT" \
  --title "$RELEASE_TITLE" \
  --target "$GITHUB_SHA" \
  --latest

echo "Removing old releases..."

while IFS= read -r tag; do
  [[ "$tag" == "$RELEASE_TAG" ]] && continue

  echo "Deleting release '$tag'..."
  gh release delete "$tag" \
    --cleanup-tag \
    --yes
done < <(
  gh release list \
    --limit 1000 \
    --json tagName \
    --jq '.[].tagName'
)

echo "Release published"
