import Foundation
import SwiftData

@ModelActor
actor PreferencesStore {
    func loadConfiguration() throws -> ScanConfiguration {
        let descriptor = FetchDescriptor<AppPreferencesModel>(
            predicate: #Predicate { $0.id == "main" }
        )
        let results = try modelContext.fetch(descriptor)
        guard let model = results.first else {
            return ScanConfiguration()
        }
        return model.decoded ?? ScanConfiguration()
    }

    func saveConfiguration(_ config: ScanConfiguration) throws {
        let descriptor = FetchDescriptor<AppPreferencesModel>(
            predicate: #Predicate { $0.id == "main" }
        )
        let results = try modelContext.fetch(descriptor)
        if let existing = results.first {
            existing.data = AppPreferencesModel.encode(config)
        } else {
            modelContext.insert(AppPreferencesModel(data: AppPreferencesModel.encode(config)))
        }
        try modelContext.save()
    }
}
