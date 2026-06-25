import Foundation
import SwiftData

@ModelActor
actor PreferencesStore {
    func loadConfiguration() -> ScanConfiguration {
        let descriptor = FetchDescriptor<AppPreferencesModel>(
            predicate: #Predicate { $0.id == "main" }
        )
        guard let model = try? modelContext.fetch(descriptor).first else {
            return ScanConfiguration()
        }
        return model.decoded ?? ScanConfiguration()
    }

    func saveConfiguration(_ config: ScanConfiguration) {
        let descriptor = FetchDescriptor<AppPreferencesModel>(
            predicate: #Predicate { $0.id == "main" }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.data = AppPreferencesModel.encode(config)
        } else {
            modelContext.insert(AppPreferencesModel(data: AppPreferencesModel.encode(config)))
        }
        try? modelContext.save()
    }
}
