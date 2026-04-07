import Darwin
import Foundation

/// `HOST_CPU_LOAD`（數值 3）在部分 Swift 匯入環境下無法以符號存取。
private let kHostCPULoadFlavor: host_flavor_t = 3

enum HostMetrics {

    struct CPUSample {
        var user: UInt32
        var system: UInt32
        var idle: UInt32
        var nice: UInt32
    }

    static func cpuTicks() -> CPUSample? {
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        var load = host_cpu_load_info()
        let kr = withUnsafeMutablePointer(to: &load) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), kHostCPULoadFlavor, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return nil }
        return CPUSample(
            user: load.cpu_ticks.0,
            system: load.cpu_ticks.1,
            idle: load.cpu_ticks.2,
            nice: load.cpu_ticks.3
        )
    }

    static func cpuDeltaPercent(prev: CPUSample, curr: CPUSample) -> (user: Double, system: Double, idle: Double) {
        let du = Double(curr.user &- prev.user)
        let ds = Double(curr.system &- prev.system)
        let di = Double(curr.idle &- prev.idle)
        let dn = Double(curr.nice &- prev.nice)
        let total = du + ds + di + dn
        guard total > 0 else { return (0, 0, 100) }
        return (du / total * 100, ds / total * 100, di / total * 100)
    }

    struct MemorySnapshot {
        var physicalBytes: UInt64
        var usedBytes: UInt64
        var appBytes: UInt64
        var wiredBytes: UInt64
        var compressedBytes: UInt64
        var cachedFilesBytes: UInt64
        var swapUsedBytes: UInt64
    }

    static func memorySnapshot() -> MemorySnapshot? {
        let physical = UInt64(ProcessInfo.processInfo.physicalMemory)
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let kr = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard kr == KERN_SUCCESS else { return nil }

        var pageSize: vm_size_t = 0
        _ = withUnsafeMutablePointer(to: &pageSize) { host_page_size(mach_host_self(), $0) }
        let ps = UInt64(pageSize)

        let active = UInt64(stats.active_count) * ps
        let wired = UInt64(stats.wire_count) * ps
        let compressed = UInt64(stats.compressor_page_count) * ps
        let external = UInt64(stats.external_page_count) * ps

        // 「記憶體用量」對齊活動監視器主數字：約為 App／作用中 + 連線 + 已壓縮（不把整包 file cache 再加進已用量，否則會動輒 ≈100%）。
        let usedUncapped = active + wired + compressed
        let used = min(physical, usedUncapped)

        // 「快取的檔案」：活動監視器約等於檔案支援分頁量。若把 inactive／purgeable 再整包加進 external，
        // 會與 file-backed inactive 重複計入，數字會膨到 50GB+（與約 27GB 的實際顯示不符）。
        let cachedFiles = min(physical, external)

        var swapUsed: UInt64 = 0
        var mib: [Int32] = [CTL_VM, VM_SWAPUSAGE]
        var swap = xsw_usage()
        var len = MemoryLayout<xsw_usage>.size
        _ = mib.withUnsafeMutableBufferPointer { ptr in
            sysctl(ptr.baseAddress, 2, &swap, &len, nil, 0)
        }
        swapUsed = UInt64(swap.xsu_used)

        // 近似「App 記憶體」：以作用中分頁為主（與活動監視器常見數值較接近）。internal 多為匿名分頁統計，與 active 範疇重疊，不宜再加總。
        let appLike = min(physical, active)

        return MemorySnapshot(
            physicalBytes: physical,
            usedBytes: used,
            appBytes: appLike,
            wiredBytes: wired,
            compressedBytes: compressed,
            cachedFilesBytes: cachedFiles,
            swapUsedBytes: swapUsed
        )
    }

    struct DiskSnapshot {
        var totalBytes: Int64
        var freeBytes: Int64
    }

    static func bootVolumeSnapshot() -> DiskSnapshot? {
        let url = URL(fileURLWithPath: "/")
        do {
            let values = try url.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityForImportantUsageKey
            ])
            guard let total = values.volumeTotalCapacity,
                  let avail = values.volumeAvailableCapacityForImportantUsage else { return nil }
            let total64 = Int64(total)
            let free64 = Int64(avail)
            return DiskSnapshot(totalBytes: total64, freeBytes: free64)
        } catch {
            return nil
        }
    }

    static func processCount() -> Int {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var length = 0
        let mibCount = u_int(mib.count)
        guard sysctl(&mib, mibCount, nil, &length, nil, 0) == 0, length > 0 else { return 0 }
        return length / MemoryLayout<kinfo_proc>.stride
    }

    static func threadCount() -> Int {
        let maxBytes = proc_listpids(UInt32(PROC_ALL_PIDS), 0, nil, 0)
        guard maxBytes > 0 else { return 0 }
        let pidCount = Int(maxBytes) / MemoryLayout<pid_t>.size
        var pids = [pid_t](repeating: 0, count: pidCount)
        let got = proc_listpids(UInt32(PROC_ALL_PIDS), 0, &pids, maxBytes)
        guard got > 0 else { return 0 }
        let n = Int(got) / MemoryLayout<pid_t>.size
        var threads = 0
        for i in 0..<n {
            let pid = pids[i]
            if pid <= 0 { continue }
            var info = proc_taskinfo()
            let sz = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &info, Int32(MemoryLayout<proc_taskinfo>.size))
            if sz == MemoryLayout<proc_taskinfo>.size {
                threads += Int(info.pti_threadnum)
            }
        }
        return threads
    }
}
