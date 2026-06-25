import Foundation

@MainActor
public final class ModelInventoryStore: ObservableObject {
    @Published private(set) var models: [AIModel] = []
    @Published private(set) var warnings: [String] = []
    @Published private(set) var lastUpdated: Date?

    func update(models: [AIModel], warnings: [String]) {
        self.models = models
        self.warnings = warnings
        self.lastUpdated = .now
    }
}
