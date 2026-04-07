import AppKit
import SwiftUI

struct InformationCardView: View {
    @Environment(\.openSettings) private var openSettings
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var metrics: SystemMetricsCollector

    @AppStorage(DisplayPreferences.Keys.cardCPU, store: DisplayPreferences.suite) private var cardCPU = true
    @AppStorage(DisplayPreferences.Keys.cardMemory, store: DisplayPreferences.suite) private var cardMemory = true
    @AppStorage(DisplayPreferences.Keys.cardDisk, store: DisplayPreferences.suite) private var cardDisk = true

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                Divider().opacity(0.35)

                if cardCPU {
                    cpuSection
                    Divider().opacity(0.35)
                }
                if cardMemory {
                    memorySection
                    Divider().opacity(0.35)
                }
                if cardDisk {
                    diskSection
                }

                Divider().opacity(0.35)
                footer
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(
            minWidth: TypeScaling.cardMinWidth(for: dynamicTypeSize),
            maxWidth: .infinity,
            maxHeight: 720
        )
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("System Eagle Eye")
                .font(.headline)
            Spacer()
            Button("偏好設定…") {
                openSettings()
            }
            .keyboardShortcut(",", modifiers: .command)
        }
        .padding(.bottom, 10)
    }

    private var cpuSection: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                metricRow(title: "核心／系統", value: metrics.cpuSystemPercent, color: .red)
                metricRow(title: "使用者", value: metrics.cpuUserPercent, color: Color(red: 0.45, green: 0.78, blue: 1))
                metricRow(title: "閒置", value: metrics.cpuIdlePercent, color: .primary)
                countRow(title: "執行緒", value: metrics.threadCount)
                countRow(title: "程序", value: metrics.processCount)
            }
            .fixedSize(horizontal: true, vertical: false)

            CPUHistoryChart(
                userSeries: metrics.cpuHistoryUser,
                systemSeries: metrics.cpuHistorySystem
            )
            .frame(maxWidth: .infinity, minHeight: 80, idealHeight: 96, maxHeight: 120, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
    }

    private func metricRow(title: String, value: Double, color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.2f%%", value))
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .font(.caption)
    }

    private func countRow(title: String, value: Int) -> some View {
        HStack {
            Text("\(title)：")
                .foregroundStyle(.secondary)
            Spacer()
            Text(value, format: .number.grouping(.automatic))
                .monospacedDigit()
        }
        .font(.caption)
    }

    private var memorySection: some View {
        HStack(alignment: .center, spacing: 14) {
            MemoryPressureBar(ratio: metrics.memoryPressureRatio)

            VStack(alignment: .leading, spacing: 6) {
                memoryLine("實體記憶體", metrics.physicalMemoryGB)
                memoryLine("記憶體用量", metrics.memoryUsedGB)
                memoryLine("快取的檔案", metrics.memoryCachedFilesGB)
                memoryLine("使用的交換檔", metrics.swapUsedGB)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: 6) {
                Text("用量組成")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                memoryLine("App 記憶體", metrics.memoryAppGB)
                memoryLine("連線／核心", metrics.memoryWiredGB)
                memoryLine("已壓縮", metrics.memoryCompressedGB)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)
        }
        .padding(.vertical, 10)
        .font(.caption)
    }

    private func memoryLine(_ title: String, _ gb: Double) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(String(format: "%.2f GB", gb))
                .monospacedDigit()
        }
    }

    private var diskSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("空間（啟動卷宗）")
                .font(.caption2)
                .foregroundStyle(.secondary)
            HStack {
                diskMetric("總容量", metrics.diskTotalGB)
                Spacer()
                diskMetric("已使用", metrics.diskUsedGB)
                Spacer()
                diskMetric("可用", metrics.diskFreeGB)
            }
        }
        .padding(.vertical, 10)
    }

    private func diskMetric(_ title: String, _ gb: Double) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(String(format: "%.2f GB", gb))
                .font(.callout)
                .monospacedDigit()
        }
    }

    private var footer: some View {
        HStack(alignment: .bottom, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(DesignCredit.attributionTitle)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                Text(DesignCredit.attributionDetail)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 8)

            Button("結束 System Eagle Eye") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .padding(.top, 10)
    }
}

// MARK: - 設計者資訊（可修改為你的名稱、團隊或連結說明）
private enum DesignCredit {
    static let attributionTitle = "Adaimade 設計與開發"
    static let attributionDetail = "System Eagle Eye 專案 · 2026"
}

private struct MemoryPressureBar: View {
    var ratio: Double

    /// 與右側兩欄文字區總高度接近，避免左側「過短、右下留白」的失衡感。
    private let barColumnWidth: CGFloat = 72
    private let barTrackHeight: CGFloat = 106

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("記憶體壓力")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: barColumnWidth)

            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.primary.opacity(0.08))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(pressureColor)
                        .frame(height: max(4, geo.size.height * CGFloat(min(1, max(0, ratio)))))
                }
            }
            .frame(width: barColumnWidth, height: barTrackHeight)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("記憶體壓力")
        .accessibilityValue(String(format: "%.0f%%", min(100, ratio * 100)))
    }

    private var pressureColor: Color {
        if ratio < 0.65 { return Color(red: 0.16, green: 0.51, blue: 0.08) }
        if ratio < 0.85 { return .yellow.opacity(0.85) }
        return .red.opacity(0.85)
    }
}

private struct CPUHistoryChart: View {
    var userSeries: [Double]
    var systemSeries: [Double]

    var body: some View {
        VStack(spacing: 4) {
            Text("CPU 負載")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let n = max(userSeries.count, systemSeries.count)
                ZStack(alignment: .bottomLeading) {
                    chartPath(series: userSeries, color: Color(red: 0.45, green: 0.78, blue: 1).opacity(0.35), width: w, height: h, count: n)
                    chartPath(series: systemSeries, color: Color.red.opacity(0.4), width: w, height: h, count: n)
                }
            }
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.primary.opacity(0.06)))
        }
    }

    private func chartPath(series: [Double], color: Color, width: CGFloat, height: CGFloat, count: Int) -> some View {
        Path { path in
            guard !series.isEmpty, count > 1 else { return }
            let step = width / CGFloat(max(1, series.count - 1))
            for (i, v) in series.enumerated() {
                let x = CGFloat(i) * step
                let y = height - CGFloat(min(100, max(0, v)) / 100) * height
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            if let lastX = series.indices.last {
                path.addLine(to: CGPoint(x: CGFloat(lastX) * step, y: height))
                path.addLine(to: CGPoint(x: 0, y: height))
                path.closeSubpath()
            }
        }
        .fill(color)
    }
}
