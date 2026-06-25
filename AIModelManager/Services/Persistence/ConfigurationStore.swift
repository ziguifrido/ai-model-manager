import Foundation

@Observable
final class ConfigurationStore {
    private(set) var config = ScanConfiguration()
    private let url: URL

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSHomeDirectory())
        self.url = base.appendingPathComponent("AI Model Manager/scan-configuration.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: url) else { return }
        config = (try? JSONDecoder().decode(ScanConfiguration.self, from: data)) ?? ScanConfiguration()
    }

    func save(_ configuration: ScanConfiguration) {
        config = configuration
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
