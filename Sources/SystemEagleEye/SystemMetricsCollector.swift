import Combine
import Foundation

@MainActor
final class SystemMetricsCollector: ObservableObject {

    @Published private(set) var cpuUserPercent: Double = 0
    @Published private(set) var cpuSystemPercent: Double = 0
    @Published private(set) var cpuIdlePercent: Double = 100
    @Published private(set) var processCount: Int = 0
    @Published private(set) var threadCount: Int = 0

    @Published private(set) var physicalMemoryGB: Double = 0
    @Published private(set) var memoryUsedGB: Double = 0
    @Published private(set) var memoryAppGB: Double = 0
    @Published private(set) var memoryWiredGB: Double = 0
    @Published private(set) var memoryCompressedGB: Double = 0
    @Published private(set) var memoryCachedFilesGB: Double = 0
    @Published private(set) var swapUsedGB: Double = 0
    @Published private(set) var memoryPressureRatio: Double = 0

    @Published private(set) var diskTotalGB: Double = 0
    @Published private(set) var diskUsedGB: Double = 0
    @Published private(set) var diskFreeGB: Double = 0

    @Published private(set) var cpuHistoryUser: [Double] = []
    @Published private(set) var cpuHistorySystem: [Double] = []

    private var previousCPU: HostMetrics.CPUSample?
    private var timer: Timer?
    private let historyLimit = 48
    private var tickIndex = 0

    func startPolling(interval: TimeInterval) {
        stopPolling()
        tick()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        if let curr = HostMetrics.cpuTicks(), let prev = previousCPU {
            let p = HostMetrics.cpuDeltaPercent(prev: prev, curr: curr)
            cpuUserPercent = p.user
            cpuSystemPercent = p.system
            cpuIdlePercent = p.idle
            appendHistory(user: p.user, system: p.system)
        }
        previousCPU = HostMetrics.cpuTicks()

        if let m = HostMetrics.memorySnapshot() {
            let g: (UInt64) -> Double = { Double($0) / 1_073_741_824.0 }
            physicalMemoryGB = g(m.physicalBytes)
            memoryUsedGB = g(m.usedBytes)
            memoryAppGB = g(m.appBytes)
            memoryWiredGB = g(m.wiredBytes)
            memoryCompressedGB = g(m.compressedBytes)
            memoryCachedFilesGB = g(m.cachedFilesBytes)
            swapUsedGB = g(m.swapUsedBytes)
            let ratio = m.physicalBytes > 0 ? Double(m.usedBytes) / Double(m.physicalBytes) : 0
            memoryPressureRatio = min(1, max(0, ratio))
        }

        if let d = HostMetrics.bootVolumeSnapshot() {
            let gb: (Int64) -> Double = { Double($0) / 1_073_741_824.0 }
            diskTotalGB = gb(d.totalBytes)
            diskFreeGB = gb(d.freeBytes)
            diskUsedGB = max(0, diskTotalGB - diskFreeGB)
        }

        tickIndex += 1
        if tickIndex == 1 || tickIndex % 4 == 0 {
            processCount = HostMetrics.processCount()
            threadCount = HostMetrics.threadCount()
        }
    }

    private func appendHistory(user: Double, system: Double) {
        var u = cpuHistoryUser
        var s = cpuHistorySystem
        u.append(user)
        s.append(system)
        if u.count > historyLimit {
            u.removeFirst(u.count - historyLimit)
            s.removeFirst(s.count - historyLimit)
        }
        cpuHistoryUser = u
        cpuHistorySystem = s
    }
}
