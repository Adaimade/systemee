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

# Mounted volume icon (same artwork as the app)
if [[ -f "$ROOT/Supporting/AppIcon.icns" ]]; then
  cp "$ROOT/Supporting/AppIcon.icns" "$STAGE/.VolumeIcon.icns"
  # Folder flag so Finder uses .VolumeIcon.icns on the disk image root (when Xcode SetFile exists)
  if SETFILE="$(command -v SetFile 2>/dev/null)"; then
    "$SETFILE" -a C "$STAGE" || true
  elif [[ -n "${DEVELOPER_DIR:-}" && -x "${DEVELOPER_DIR}/Tools/SetFile" ]]; then
    "${DEVELOPER_DIR}/Tools/SetFile" -a C "$STAGE" || true
  fi
fi

rm -f "$ROOT/$DMG_NAME"
hdiutil create \
  -volname "System Eagle Eye" \
  -srcfolder "$STAGE" \
  -ov \
  -format UDZO \
  "$ROOT/$DMG_NAME"

DMG_PATH="$ROOT/$DMG_NAME"
APP_PATH="$ROOT/$APP_NAME"
# Finder icon for the .dmg file itself (matches the app icon)
if osascript <<APPLESCRIPT 2>/dev/null
tell application "Finder"
  set dmgFile to POSIX file "${DMG_PATH}" as alias
  set appFile to POSIX file "${APP_PATH}" as alias
  set icon of dmgFile to icon of appFile
end tell
APPLESCRIPT
then
  echo "Set Finder icon on $(basename "$DMG_PATH") to match the app."
else
  echo "Note: Could not assign custom icon to the .dmg (Finder/AppleScript unavailable). The mounted volume may still show the custom icon."
fi

echo "Created: $ROOT/$DMG_NAME"
echo "Tip: Sign and notarize the .app (or the .dmg) before wide distribution; see README.md."
