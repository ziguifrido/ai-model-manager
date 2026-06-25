import Foundation

public struct ScanSummary: Sendable {
    let models: [AIModel]
    let warnings: [String]
}

public actor ModelScannerService {
    private let scannerFactory: @Sendable (ScanConfiguration) -> [any ModelScanner]
    private let configurationStore: ConfigurationStore
    private let fileSystem: FileSystem

    init(configurationStore: ConfigurationStore, fileSystem: FileSystem, scannerFactory: @escaping @Sendable (ScanConfiguration) -> [any ModelScanner]) {
        self.configurationStore = configurationStore
        self.fileSystem = fileSystem
        self.scannerFactory = scannerFactory
    }

    func scanAll() async -> ScanSummary {
        let configuration = await configurationStore.load()
        let scanners = scannerFactory(configuration)
        return await withTaskGroup(of: (models: [AIModel], warning: String?).self) { group in
            for scanner in scanners {
                group.addTask {
                    do { return (try await scanner.scan(), nil) }
                    catch { return ([], "\(scanner.engineName): \(error.localizedDescription)") }
                }
            }
            var models: [AIModel] = []
            var warnings: [String] = []
            for await result in group {
                models += result.models
                if let warning = result.warning { warnings.append(warning) }
            }
            return ScanSummary(models: DirectoryModelScanner.deduplicate(models), warnings: warnings)
        }
    }
}
