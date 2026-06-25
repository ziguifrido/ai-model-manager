import Foundation

protocol ModelDeletionStrategy {
    func directoriesToDelete(for model: AIModel) async throws -> [URL]
}

struct DefaultDeletionStrategy: ModelDeletionStrategy {
    func directoriesToDelete(for model: AIModel) async throws -> [URL] {
        [model.location]
    }
}

enum ModelDeletionStrategyFactory {
    static func strategy(for engine: String) -> ModelDeletionStrategy {
        switch engine {
        case "LM Studio": return LMStudioDeletionStrategy()
        default: return DefaultDeletionStrategy()
        }
    }
}
