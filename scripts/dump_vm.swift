import Darwin
import Foundation

var stats = vm_statistics64()
var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
let kr = withUnsafeMutablePointer(to: &stats) {
    $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
        host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
    }
}
guard kr == KERN_SUCCESS else { fatalError("host_statistics64 failed") }

var pageSize: vm_size_t = 0
_ = withUnsafeMutablePointer(to: &pageSize) { host_page_size(mach_host_self(), $0) }
let ps = UInt64(pageSize)
let phys = ProcessInfo.processInfo.physicalMemory

func gb(_ bytes: UInt64) -> Double { Double(bytes) / 1_073_741_824.0 }

let active = UInt64(stats.active_count) * ps
let wired = UInt64(stats.wire_count) * ps
let comp = UInt64(stats.compressor_page_count) * ps
let internalP = UInt64(stats.internal_page_count) * ps
let externalP = UInt64(stats.external_page_count) * ps
let inactive = UInt64(stats.inactive_count) * ps
let speculative = UInt64(stats.speculative_count) * ps
let purgeable = UInt64(stats.purgeable_count) * ps
let free = UInt64(stats.free_count) * ps
let totalUncomp = stats.total_uncompressed_pages_in_compressor * UInt64(ps)

print("pageSize=\(pageSize)")
print("physical GB=\(gb(phys))")
print("counts: active=\(stats.active_count) wire=\(stats.wire_count) compressor_page_count=\(stats.compressor_page_count) internal=\(stats.internal_page_count) external=\(stats.external_page_count)")
print("total_uncompressed_pages_in_compressor=\(stats.total_uncompressed_pages_in_compressor)")
print("--- GB ---")
print("active=\(gb(active)) wired=\(gb(wired)) compressor_page_count*ps=\(gb(comp)) internal*ps=\(gb(internalP))")
print("our used (a+w+c)=\(gb(active+wired+comp))")
print("phys - free=\(gb(phys > free ? phys - free : 0))")
print("app_proxy internal=\(gb(internalP)) external file=\(gb(externalP))")
let cached = inactive + speculative + purgeable + externalP
print("cached formula (i+s+p+e)=\(gb(cached))")
