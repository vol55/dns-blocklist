#!/bin/bash
set -euo pipefail

BRANCH="dns-blocklist"
OUTPUT="dns-blocklist.srs"

[[ -s "$OUTPUT" ]] || {
  echo "$OUTPUT not found or empty" >&2
  exit 1
}

git config user.name "vol55"
git config user.email "vol55@users.noreply.github.com"

git checkout --orphan "$BRANCH"
git rm -rf . >/dev/null 2>&1 || true

git add -f "$OUTPUT"
git commit -m "update blocklist"

git push --force origin "$BRANCH"
