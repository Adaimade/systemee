# System Eagle Eye

A lightweight macOS menu bar monitor: CPU, memory, and boot volume free space. Click to open an information card with more detail. **Interface language** (English, Traditional Chinese, or follow the system) is chosen in **Preferences**.

**Release: 1.0.0** (see `Supporting/Info.plist`)

**[Traditional Chinese README → README.zh-TW.md](README.zh-TW.md)**

## Requirements

- macOS **14.0** or later
- Apple Silicon or Intel Mac

## Build from source

```bash
cd systemee
swift build -c release
```

Binary: `.build/release/SystemEagleEye`

## Package as .app (recommended for distribution)

```bash
./scripts/package_app.sh
```

This creates **`System Eagle Eye.app`** at the repo root and applies `Supporting/Info.plist` (includes `LSUIElement` so the app does not show a Dock icon by default).

## First launch and security

Unsigned apps may be blocked by Gatekeeper. You can:

- In Finder: **right-click → Open → Open**, or  
- In Terminal: `xattr -cr "/path/to/System Eagle Eye.app"`

For public distribution, sign with **Developer ID** and **notarize** via Apple so users can open the app with a double-click (use your Apple Developer account and Xcode / `notarytool`).

## Privacy and data

- Metrics are read locally via Mach, `sysctl`, and volume APIs only—**no network, no uploads, no personal data collection**.
- Preferences are stored locally in `UserDefaults` (suite: `com.systemee.SystemEagleEye`).
- Full notice (including **academic / educational use** framing): see [PRIVACY.md](PRIVACY.md).

## Pre-release checklist

- [ ] Bump `CFBundleShortVersionString` / `CFBundleVersion` in `Supporting/Info.plist`
- [ ] Run `./scripts/package_app.sh` and smoke-test on hardware
- [ ] Verify preferences, menu bar, info card, and quit flow
- [ ] (Optional) Sign and notarize before wider distribution

## License

This project is released under the [**MIT License**](LICENSE). In-app design credit and `NSHumanReadableCopyright` in `Info.plist` may be used as attribution references; retain `LICENSE` and copyright notices when redistributing.
