import SwiftUI

struct MenuBarTitleView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.locale) private var locale
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
            .help(L10n.string("help.app", locale: locale))
            .accessibilityLabel(L10n.format("a11y.menubar", locale: locale, titleText))
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
            parts.append(L10n.format("menu.cpu_format", locale: locale, busy))
        }
        if barMemory {
            parts.append(L10n.format("menu.ram_format", locale: locale, metrics.memoryPressureRatio * 100))
        }
        if barDisk {
            parts.append(L10n.format("menu.disk_format", locale: locale, metrics.diskFreeGB))
        }
        if parts.isEmpty {
            return L10n.string("menu.fallback_title", locale: locale)
        }
        return parts.joined(separator: " · ")
    }
}
