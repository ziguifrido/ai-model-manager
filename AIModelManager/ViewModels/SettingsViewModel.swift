import Foundation

@Observable
final class SettingsViewModel {
    var configuration: ScanConfiguration = .init()
    private let store: ConfigurationStore

    init(store: ConfigurationStore) {
        self.store = store
    }

    func load() {
        store.load()
        configuration = store.config
    }

    func save() {
        store.save(configuration)
    }

    func customPaths(for engine: EngineKind) -> [String] {
        configuration.engines[engine]?.customPaths ?? []
    }

    func setCustomPaths(_ paths: [String], for engine: EngineKind) {
        configuration.engines[engine] = EngineScanConfiguration(customPaths: paths)
        save()
    }
}
