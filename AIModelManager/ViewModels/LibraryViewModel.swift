import Foundation
import AppKit

@Observable
final class LibraryViewModel {
    var searchText = ""
    var selectedEngine = ""
    var sortOption: ModelSortOption = .name
    var isScanning = false
    var selectedModelIDs: Set<UUID> = []
    var showDeletionPreview = false
    var pendingDeletionDirectories: [URL] = []
    var pendingDeletionErrors: [String] = []

    private let scannerService: ModelScannerService
    let inventoryStore: ModelInventoryStore

    init(scannerService: ModelScannerService, inventoryStore: ModelInventoryStore) {
        self.scannerService = scannerService
        self.inventoryStore = inventoryStore
    }

    var models: [AIModel] {
        var output = inventoryStore.models
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            output = output.filter { $0.name.lowercased().contains(q) || $0.engine.lowercased().contains(q) || ($0.primaryExtension?.lowercased().contains(q) ?? false) }
        }
        if !selectedEngine.isEmpty { output = output.filter { $0.engine == selectedEngine } }
        switch sortOption {
        case .name: output.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .size: output.sort { $0.size > $1.size }
        case .engine: output.sort { $0.engine.localizedStandardCompare($1.engine) == .orderedAscending }
        }
        return output
    }

    var engines: [String] { Array(Set(inventoryStore.models.map(\.engine))).sorted() }

    var selectedModels: [AIModel] {
        inventoryStore.models.filter { selectedModelIDs.contains($0.id) }
    }

    var selectedModelsSize: Int64 {
        selectedModels.reduce(0) { $0 + $1.size }
    }

    func scanNow() {
        isScanning = true
        Task {
            let summary = await scannerService.scanAll()
            inventoryStore.update(models: summary.models, warnings: summary.warnings)
            isScanning = false
        }
    }

    func prepareDeletion() async {
        let models = selectedModels
        var dirs: [URL] = []
        var errors: [String] = []
        for model in models {
            let strategy = ModelDeletionStrategyFactory.strategy(for: model.engine)
            do {
                dirs += try await strategy.directoriesToDelete(for: model)
            } catch {
                errors.append("\(model.name): \(error.localizedDescription)")
            }
        }
        pendingDeletionDirectories = Array(Set(dirs))
        pendingDeletionErrors = errors
        showDeletionPreview = true
    }

    func executeDeletion() {
        let modelsToDelete = selectedModels
        let idsToDelete = Set(modelsToDelete.map(\.id))
        let dirs = pendingDeletionDirectories
        var warnings = pendingDeletionErrors
        for dir in dirs {
            do { try FileSystem.default.removeItem(at: dir) }
            catch { warnings.append("Failed to delete \(dir.lastPathComponent): \(error.localizedDescription)") }
        }
        if modelsToDelete.contains(where: { $0.engine == "Ollama" }) {
            OllamaModelScanner.removeOrphanBlobs()
        }
        inventoryStore.update(models: inventoryStore.models.filter { !idsToDelete.contains($0.id) }, warnings: inventoryStore.warnings + warnings)
        selectedModelIDs.removeAll()
        showDeletionPreview = false
        pendingDeletionDirectories = []
        pendingDeletionErrors = []
    }

    func cancelDeletion() {
        showDeletionPreview = false
        pendingDeletionDirectories = []
        pendingDeletionErrors = []
    }

    func openInFinder(_ model: AIModel) {
        NSWorkspace.shared.activateFileViewerSelecting([model.location])
    }

    func openSelectedInFinder() {
        let urls = selectedModels.map(\.location)
        guard !urls.isEmpty else { return }
        NSWorkspace.shared.activateFileViewerSelecting(urls)
    }
}
