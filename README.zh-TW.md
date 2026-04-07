# System Eagle Eye

macOS 選單列系統監看小工具：顯示 CPU、記憶體與啟動卷宗可用空間，點擊可開啟資訊卡查看更多數據。**介面語言**預設為**英文**；可在**偏好設定**改為繁體中文或跟隨系統。

**English README → [README.md](README.md)**

**正式版：1.0.0**（見 `Supporting/Info.plist`）

## 系統需求

- macOS **14.0** 或以上
- Apple Silicon 或 Intel Mac

## 從原始碼建置

```bash
cd systemee
swift build -c release
```

產出執行檔：`.build/release/SystemEagleEye`

## 打包成 .app（建議發佈用）

```bash
./scripts/package_app.sh
```

會在專案根目錄產生 **`System Eagle Eye.app`**，並寫入 `Supporting/Info.plist`（含 `LSUIElement`，Dock 不常駐圖示）。Finder 圖示使用 **`Supporting/AppIcon.icns`**；若更換主圖 **`Supporting/AppIcon-square.png`**（1024×1024），請執行 `./scripts/build_icns.sh` 重新產生 `.icns`。

## 打包成 .dmg（選用）

```bash
./scripts/package_dmg.sh
```

會先執行 `package_app.sh`，再在專案根目錄產生壓縮映像檔 **`System-Eagle-Eye-<版本號>.dmg`**。映像內含 App 與指向 **應用程式** 資料夾的捷徑，方便拖放安裝。僅使用 macOS 內建 **`hdiutil`**，無需額外工具。

## 首次執行與安全性

未簽署的 App 可能被 Gatekeeper 擋下。可：

- 在 Finder **右鍵 → 打開 → 打開**，或  
- 於終端機執行：`xattr -cr "/路徑/System Eagle Eye.app"`

若要對外發佈，建議使用 **Developer ID** 簽署並透過 Apple **公證（notarize）**，使用者即可正常雙擊開啟（請於 Apple Developer 帳號與 Xcode/`notarytool` 流程處理）。

## 隱私與資料

- 數值僅透過本機 Mach／`sysctl`／卷宗 API 讀取，**不連網、不上傳、不蒐集個資**。
- 偏好設定儲存在本機 `UserDefaults`（suite：`com.systemee.SystemEagleEye`）。
- **完整隱私權說明**（英文，含「僅供學術研究／教育用途」定位）：[PRIVACY.md](PRIVACY.md)。

## 推出前快速檢查

- [ ] `Supporting/Info.plist` 中 `CFBundleShortVersionString`／`CFBundleVersion` 已更新  
- [ ] 執行 `./scripts/package_app.sh` 並實機開啟測試  
- [ ] 偏好設定、選單列、資訊卡與結束流程正常  
- [ ] （選用）完成簽署與公證後再散佈

## 授權（開源）

本專案以 [**MIT License**](LICENSE) 釋出。App 內顯示之設計者資訊與 `Info.plist` 之 `NSHumanReadableCopyright` 可作為署名參考；再散布時請保留 `LICENSE` 與著作權聲明。
