#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HASHES_FILE="$SCRIPT_DIR/hashes.json"
PACKAGE="pi-subagents"

current=$(jq -r .version "$HASHES_FILE")
latest=$(npm view "$PACKAGE" version)

echo "Current: $current, Latest: $latest"

if [ "$current" = "$latest" ]; then
    echo "Already up to date"
    exit 0
fi

url="https://registry.npmjs.org/$PACKAGE/-/$PACKAGE-$latest.tgz"
echo "Calculating source hash..."
hash=$(nix store prefetch-file --hash-type sha256 --json "$url" | jq -r .hash)

jq --arg v "$latest" --arg h "$hash" \
    '{version: $v, sourceHash: $h}' \
    "$HASHES_FILE" > "$HASHES_FILE.tmp"
mv "$HASHES_FILE.tmp" "$HASHES_FILE"

echo "Updated to $latest"
