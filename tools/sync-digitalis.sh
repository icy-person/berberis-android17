#!/usr/bin/env bash
set -Eeuo pipefail

DIGITALIS_REPO="${DIGITALIS_REPO:-https://github.com/DigitalisX64/platform_frameworks_libs_binary_translation.git}"
DIGITALIS_REF="${DIGITALIS_REF:-android-latest-release}"

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Working tree is not clean; commit or stash changes first." >&2
  exit 1
fi

if ! git remote get-url digitalis >/dev/null 2>&1; then
  git remote add digitalis "$DIGITALIS_REPO"
else
  git remote set-url digitalis "$DIGITALIS_REPO"
fi

git fetch --prune digitalis "$DIGITALIS_REF"

UPSTREAM_SHA="$(git rev-parse "digitalis/$DIGITALIS_REF")"
echo "Digitalis $DIGITALIS_REF -> $UPSTREAM_SHA"

if ! git merge-base HEAD "digitalis/$DIGITALIS_REF" >/dev/null 2>&1; then
  echo "No common ancestor with Digitalis; refusing an unsafe replacement." >&2
  exit 2
fi

BASE="$(git merge-base HEAD "digitalis/$DIGITALIS_REF")"
echo "Common ancestor: $BASE"

if [ "$(git rev-parse HEAD)" = "$UPSTREAM_SHA" ]; then
  echo "Already synchronized."
  exit 0
fi

set +e
git merge --no-ff --no-commit "digitalis/$DIGITALIS_REF"
rc=$?
set -e

if [ "$rc" -ne 0 ]; then
  echo
  echo "Digitalis changed shared files or produced conflicts."
  echo "Resolve them explicitly; do not use a blanket checkout of one side."
  git status --short
  exit "$rc"
fi

git diff --check

echo
echo "Merge prepared successfully."
echo "Review the diff, especially Android.bp, berberis_config.mk, proxy libraries,"
echo "and ARM64 runtime/kernel_api changes."
echo
echo "When satisfied:"
echo "  git commit -m 'sync: Digitalis $UPSTREAM_SHA'"
