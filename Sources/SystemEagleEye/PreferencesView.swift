import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var metrics: SystemMetricsCollector

    @AppStorage(DisplayPreferences.Keys.barCPU, store: DisplayPreferences.suite) private var barCPU = true
    @AppStorage(DisplayPreferences.Keys.barMemory, store: DisplayPreferences.suite) private var barMemory = true
    @AppStorage(DisplayPreferences.Keys.barDisk, store: DisplayPreferences.suite) private var barDisk = true

    @AppStorage(DisplayPreferences.Keys.cardCPU, store: DisplayPreferences.suite) private var cardCPU = true
    @AppStorage(DisplayPreferences.Keys.cardMemory, store: DisplayPreferences.suite) private var cardMemory = true
    @AppStorage(DisplayPreferences.Keys.cardDisk, store: DisplayPreferences.suite) private var cardDisk = true

    @AppStorage(DisplayPreferences.Keys.pollInterval, store: DisplayPreferences.suite) private var pollInterval = 2.0

    var body: some View {
        TabView {
            Form {
                Section("選單列顯示") {
                    Toggle("CPU 使用率（忙碌度）", isOn: $barCPU)
                    Toggle("記憶體壓力比例", isOn: $barMemory)
                    Toggle("可用空間（GB）", isOn: $barDisk)
                }
                Section("資訊卡區塊") {
                    Toggle("CPU（負載圖表、執行緒與程序）", isOn: $cardCPU)
                    Toggle("記憶體詳情", isOn: $cardMemory)
                    Toggle("空間（資訊卡）", isOn: $cardDisk)
                }
                Section("更新頻率") {
                    Picker("輪詢間隔", selection: $pollInterval) {
                        Text("約 1 秒").tag(1.0)
                        Text("約 1.5 秒").tag(1.5)
                        Text("約 2 秒").tag(2.0)
                        Text("約 3 秒").tag(3.0)
                    }
                    .onChange(of: pollInterval) { _, new in
                        metrics.startPolling(interval: new)
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("顯示項目", systemImage: "slider.horizontal.3") }

            Form {
                Section {
                    Text("數值來自本機 Mach／vm／卷宗 API，與「活動監視器」在計算方式上可能略有差異，僅供日常參考。")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("說明", systemImage: "info.circle") }
        }
        .frame(width: 460, height: 360)
    }
}
