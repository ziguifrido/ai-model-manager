import Foundation
import SwiftUI

@MainActor
public final class AppContainer: ObservableObject {
    let scannerService: ModelScannerService
    let inventoryStore: ModelInventoryStore
    let configurationStore: ConfigurationStore
    let settingsViewModel: SettingsViewModel

    init(scannerService: ModelScannerService, inventoryStore: ModelInventoryStore, configurationStore: ConfigurationStore, settingsViewModel: SettingsViewModel) {
        self.scannerService = scannerService
        self.inventoryStore = inventoryStore
        self.configurationStore = configurationStore
        self.settingsViewModel = settingsViewModel
    }

    public static func live() -> AppContainer {
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
        let settingsViewModel = SettingsViewModel(store: configurationStore)
        settingsViewModel.load()
        return AppContainer(scannerService: service, inventoryStore: ModelInventoryStore(), configurationStore: configurationStore, settingsViewModel: settingsViewModel)
    }

    public func makeLibraryViewModel() -> LibraryViewModel {
        LibraryViewModel(scannerService: scannerService, inventoryStore: inventoryStore)
    }

    public func makeSettingsViewModel() -> SettingsViewModel {
        settingsViewModel
    }
}
