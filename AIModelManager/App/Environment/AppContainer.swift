import Foundation
import SwiftUI

@Observable
final class AppContainer {
    var scannerService: ModelScannerService
    var inventoryStore: ModelInventoryStore
    var configurationStore: ConfigurationStore

    init(scannerService: ModelScannerService, inventoryStore: ModelInventoryStore, configurationStore: ConfigurationStore) {
        self.scannerService = scannerService
        self.inventoryStore = inventoryStore
        self.configurationStore = configurationStore
    }

    static func live() -> AppContainer {
        let configurationStore = ConfigurationStore()
        let service = ModelScannerService(configurationStore: configurationStore, fileSystem: FileSystem.default) { configuration in
            [
                OllamaModelScanner(roots: EnginePaths.defaults(for: .ollama) + configuration.urls(for: .ollama)),
                LMStudioModelScanner(roots: EnginePaths.defaults(for: .lmStudio) + configuration.urls(for: .lmStudio)),
                HuggingFaceModelScanner(roots: EnginePaths.defaults(for: .huggingFace) + configuration.urls(for: .huggingFace)),
                MLXModelScanner(roots: EnginePaths.defaults(for: .mlx) + configuration.urls(for: .mlx)),
                VLLMModelScanner(roots: EnginePaths.defaults(for: .vllm) + configuration.urls(for: .vllm))
            ]
        }
        return AppContainer(scannerService: service, inventoryStore: ModelInventoryStore(), configurationStore: configurationStore)
    }
}
