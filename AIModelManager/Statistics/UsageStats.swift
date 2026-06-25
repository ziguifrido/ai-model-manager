import Foundation

struct UsageStats {
    let scannedEngines: Int
    let activeScanDirs: Int
    let lastScanDuration: TimeInterval?

    static var empty: UsageStats {
        UsageStats(scannedEngines: 0, activeScanDirs: 0, lastScanDuration: nil)
    }
}
