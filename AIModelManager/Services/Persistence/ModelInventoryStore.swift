import Foundation

@Observable
final class ModelInventoryStore {
    var models: [AIModel] = []
    var warnings: [String] = []
    var lastUpdated: Date?

    func update(models: [AIModel], warnings: [String]) {
        self.models = models
        self.warnings = warnings
        self.lastUpdated = .now
    }
}
