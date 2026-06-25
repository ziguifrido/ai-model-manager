import Foundation

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published var configuration: ScanConfiguration = .init()

    private let store: ConfigurationStore

    public init(store: ConfigurationStore) {
        self.store = store
    }

    func load() {
        Task {
            let loaded = await store.load()
            await MainActor.run { self.configuration = loaded }
        }
    }

    func save() {
        let config = configuration
        Task { await store.save(config) }
    }

    func customPaths(for engine: EngineKind) -> [String] {
        configuration.engines[engine]?.customPaths ?? []
    }

    func setCustomPaths(_ paths: [String], for engine: EngineKind) {
        configuration.engines[engine] = EngineScanConfiguration(customPaths: paths)
        save()
    }
}
