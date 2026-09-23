#!/bin/bash
set -euo pipefail

BRANCH="dns-blocklist"
OUTPUT="dns-blocklist.srs"

[[ -s "$OUTPUT" ]] || {
  echo "$OUTPUT not found or empty" >&2
  exit 1
}

git config user.email "github-actions[bot]@users.noreply.github.com"
git config user.name "github-actions[bot]"

git checkout --orphan "$BRANCH"

git add -f "$OUTPUT"
git commit -m "update blocklist"

git push --force origin "$BRANCH"
