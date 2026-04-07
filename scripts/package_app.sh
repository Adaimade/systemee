#!/usr/bin/env bash
# System Eagle Eye — release .app bundle (bump Supporting/Info.plist version first)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
APP_NAME="System Eagle Eye.app"
swift build -c release
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS" "$APP_NAME/Contents/Resources"
cp "$ROOT/.build/release/SystemEagleEye" "$APP_NAME/Contents/MacOS/"
RES_BUNDLE="$ROOT/.build/release/SystemEagleEye_SystemEagleEye.bundle"
if [[ -d "$RES_BUNDLE" ]]; then
  cp -R "$RES_BUNDLE" "$APP_NAME/Contents/Resources/"
fi
cp "$ROOT/Supporting/Info.plist" "$APP_NAME/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_NAME/Contents/Info.plist" 2>/dev/null || true
echo "Created: $ROOT/$APP_NAME"
echo "Tip: For distribution, sign with Developer ID and notarize (see README.md)."
