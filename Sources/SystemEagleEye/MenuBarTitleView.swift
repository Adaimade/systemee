import SwiftUI

struct MenuBarTitleView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var metrics: SystemMetricsCollector

    @AppStorage(DisplayPreferences.Keys.barCPU, store: DisplayPreferences.suite) private var barCPU = true
    @AppStorage(DisplayPreferences.Keys.barMemory, store: DisplayPreferences.suite) private var barMemory = true
    @AppStorage(DisplayPreferences.Keys.barDisk, store: DisplayPreferences.suite) private var barDisk = true
    @AppStorage(DisplayPreferences.Keys.pollInterval, store: DisplayPreferences.suite) private var pollInterval = 2.0

    var body: some View {
        Text(titleText)
            .font(.caption.monospaced())
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(TypeScaling.menuBarMinimumScale(for: dynamicTypeSize))
            .allowsTightening(true)
            .help("System Eagle Eye")
            .accessibilityLabel("System Eagle Eye，\(titleText)")
            .task {
                metrics.startPolling(interval: pollInterval)
            }
            .onChange(of: pollInterval) { _, new in
                metrics.startPolling(interval: new)
            }
    }

    private var titleText: String {
        var parts: [String] = []
        if barCPU {
            let busy = max(0, min(100, 100 - metrics.cpuIdlePercent))
            parts.append(String(format: "CPU %.0f%%", busy))
        }
        if barMemory {
            parts.append(String(format: "RAM %.0f%%", metrics.memoryPressureRatio * 100))
        }
        if barDisk {
            parts.append(String(format: "空間 %.0fGB", metrics.diskFreeGB))
        }
        if parts.isEmpty {
            return "Eagle Eye"
        }
        return parts.joined(separator: " · ")
    }
}
