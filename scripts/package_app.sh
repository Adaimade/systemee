#!/usr/bin/env bash
# System Eagle Eye — 正式版 .app 打包（請先確認 Supporting/Info.plist 版本號）
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
APP_NAME="System Eagle Eye.app"
swift build -c release
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS"
cp "$ROOT/.build/release/SystemEagleEye" "$APP_NAME/Contents/MacOS/"
cp "$ROOT/Supporting/Info.plist" "$APP_NAME/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_NAME/Contents/Info.plist" 2>/dev/null || true
echo "已建立：$ROOT/$APP_NAME"
echo "提示：對外發佈前建議以 Developer ID 簽署並公證（見 README.md）。"
