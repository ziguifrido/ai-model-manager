import Foundation

public actor ConfigurationStore {
    private let fileSystem: FileSystem
    private let url: URL

    init(fileSystem: FileSystem = .default) {
        self.fileSystem = fileSystem
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSHomeDirectory())
        self.url = base.appendingPathComponent("My AI Models/scan-configuration.json")
    }

    func load() -> ScanConfiguration {
        guard let data = try? Data(contentsOf: url) else { return ScanConfiguration() }
        return (try? JSONDecoder().decode(ScanConfiguration.self, from: data)) ?? ScanConfiguration()
    }

    func save(_ configuration: ScanConfiguration) {
        do {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            let data = try JSONEncoder.pretty.encode(configuration)
            try data.write(to: url, options: .atomic)
        } catch { }
    }
}

private extension JSONEncoder {
    static var pretty: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}
