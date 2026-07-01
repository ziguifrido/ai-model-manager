import Foundation

protocol ModelDeletionStrategy {
    func directoriesToDelete(for model: AIModel) async throws -> [URL]
    func estimatedReclaimedBytes(for model: AIModel) async throws -> Int64
}

struct DefaultDeletionStrategy: ModelDeletionStrategy {
    func directoriesToDelete(for model: AIModel) async throws -> [URL] {
        [model.location]
    }

    func estimatedReclaimedBytes(for model: AIModel) async throws -> Int64 {
        ModelMetadataExtractor.directorySize(at: model.location, fileSystem: FileSystem.default)
    }
}

extension ModelDeletionStrategy {
    func estimatedReclaimedBytes(for model: AIModel) async throws -> Int64 {
        let dirs = try await directoriesToDelete(for: model)
        return dirs.reduce(0) { $0 + ModelMetadataExtractor.directorySize(at: $1, fileSystem: FileSystem.default) }
    }
}

enum ModelDeletionStrategyFactory {
    static func strategy(for engine: String) -> ModelDeletionStrategy {
        switch engine {
        case "LM Studio": return LMStudioDeletionStrategy()
        case "Ollama": return OllamaDeletionStrategy()
        default: return DefaultDeletionStrategy()
        }
    }
}
