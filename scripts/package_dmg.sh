#!/usr/bin/env bash
# Build .app then wrap it in a compressed read-only .dmg (drag app → Applications).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
APP_NAME="System Eagle Eye.app"

"$ROOT/scripts/package_app.sh"

VERSION="$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$ROOT/Supporting/Info.plist" 2>/dev/null || echo "0.0.0")"
DMG_NAME="System-Eagle-Eye-${VERSION}.dmg"
STAGE="$(mktemp -d "${TMPDIR:-/tmp}/systemee-dmg.XXXXXX")"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

cp -R "$ROOT/$APP_NAME" "$STAGE/"
# Finder shortcut so users can drag the app into Applications
ln -sf /Applications "$STAGE/Applications"

rm -f "$ROOT/$DMG_NAME"
hdiutil create \
  -volname "System Eagle Eye" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$ROOT/$DMG_NAME"

echo "Created: $ROOT/$DMG_NAME"
echo "Tip: Sign and notarize the .app (or the .dmg) before wide distribution; see README.md."
