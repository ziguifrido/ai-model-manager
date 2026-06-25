import Foundation

struct EngineScanConfiguration: Codable, Sendable, Hashable {
    var customPaths: [String] = []

    var urls: [URL] {
        customPaths
            .map { URL(fileURLWithPath: $0, isDirectory: true) }
            .filter { !$0.path.isEmpty }
    }
}

struct ScanConfiguration: Codable, Sendable, Hashable {
    var engines: [EngineKind: EngineScanConfiguration] = [:]

    func urls(for engine: EngineKind) -> [URL] {
        engines[engine]?.urls ?? []
    }
}

