#!/usr/bin/env bash
# Regenerate Cuckoo mocks from Cuckoofile.toml (committed output in FocusUpTests/Generated/).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PROJECT_DIR="$ROOT"

CHECKOUT="${CUCKOO_CHECKOUT:-}"
if [[ -z "$CHECKOUT" ]]; then
  CHECKOUT="$(find "${DERIVED_DATA:-$HOME/Library/Developer/Xcode/DerivedData}"/FocusUp-*/SourcePackages/checkouts/Cuckoo -maxdepth 0 2>/dev/null | head -1 || true)"
fi
if [[ -z "$CHECKOUT" ]]; then
  echo "Resolving Swift packages to locate Cuckoo checkout..."
  xcodebuild -resolvePackageDependencies -project "$ROOT/FocusUp.xcodeproj" -scheme FocusUp >/dev/null
  CHECKOUT="$(find "$HOME/Library/Developer/Xcode/DerivedData"/FocusUp-*/SourcePackages/checkouts/Cuckoo -maxdepth 0 2>/dev/null | head -1)"
fi

if [[ ! -d "$CHECKOUT" ]]; then
  echo "error: Cuckoo package checkout not found. Set CUCKOO_CHECKOUT manually." >&2
  exit 1
fi

echo "Generating mocks using Cuckoo at: $CHECKOUT"
swift run --package-path "$CHECKOUT" -c release CuckooGenerator
echo "Wrote $ROOT/FocusUpTests/Generated/GeneratedMocks.swift"
