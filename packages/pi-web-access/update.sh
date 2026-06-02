#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
HASHES_FILE="$SCRIPT_DIR/hashes.json"
VENDORED_LOCK="$SCRIPT_DIR/package-lock.json"
FLAKE_PACKAGE="pi-web-access"
NPM_PACKAGE="pi-web-access"
GITHUB_OWNER="nicobailon"
GITHUB_REPO="pi-web-access"

stage_path() {
  if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_ROOT" add "$1"
  fi
}

stage_deletion() {
  if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_ROOT" add -u "$1"
  fi
}

build_package() {
  echo "Building $FLAKE_PACKAGE..."
  (cd "$REPO_ROOT" && nix build ".#$FLAKE_PACKAGE" --no-link)
}

current=$(jq -r .version "$HASHES_FILE")
latest=$(npm view "$NPM_PACKAGE" version)

echo "Current: $current, Latest: $latest"

if [ "$current" = "$latest" ]; then
  echo "Already up to date"
  build_package
  exit 0
fi

echo "Prefetching GitHub source..."
prefetch_json=$(nix flake prefetch "github:$GITHUB_OWNER/$GITHUB_REPO/v$latest" --json)
source_hash=$(jq -r .hash <<< "$prefetch_json")
source_path=$(jq -r .storePath <<< "$prefetch_json")

if [ -f "$source_path/package-lock.json" ]; then
  lock_path="$source_path/package-lock.json"
  if [ -f "$VENDORED_LOCK" ]; then
    echo "Upstream has package-lock.json; trashing vendored lock"
    trash "$VENDORED_LOCK"
    stage_deletion "$VENDORED_LOCK"
  fi
elif [ -f "$source_path/npm-shrinkwrap.json" ]; then
  lock_path="$source_path/npm-shrinkwrap.json"
  if [ -f "$VENDORED_LOCK" ]; then
    echo "Upstream has npm-shrinkwrap.json; trashing vendored lock"
    trash "$VENDORED_LOCK"
    stage_deletion "$VENDORED_LOCK"
  fi
else
  echo "Regenerating vendored package-lock.json..."
  workdir=$(mktemp -d "${TMPDIR:-/tmp}/$FLAKE_PACKAGE.XXXXXX")
  cp -R "$source_path/." "$workdir/"
  chmod -R u+w "$workdir"
  (cd "$workdir" && npm install --package-lock-only --ignore-scripts --audit=false --fund=false)
  cp "$workdir/package-lock.json" "$VENDORED_LOCK"
  stage_path "$VENDORED_LOCK"
  lock_path="$VENDORED_LOCK"
fi

echo "Calculating npmDepsHash..."
npm_deps_hash=$(prefetch-npm-deps "$lock_path")

jq --arg version "$latest" \
  --arg sourceHash "$source_hash" \
  --arg npmDepsHash "$npm_deps_hash" \
  '{version: $version, sourceHash: $sourceHash, npmDepsHash: $npmDepsHash}' \
  "$HASHES_FILE" > "$HASHES_FILE.tmp"
mv "$HASHES_FILE.tmp" "$HASHES_FILE"

build_package

echo "Updated $FLAKE_PACKAGE to $latest"
