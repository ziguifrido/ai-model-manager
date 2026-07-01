import Foundation
import SwiftData

private let mainPreferencesID = "main"

@ModelActor
actor PreferencesStore {
    func loadConfiguration() throws -> ScanConfiguration {
        let results = try modelContext.fetch(FetchDescriptor<AppPreferencesModel>())
        guard let model = results.first(where: { $0.id == mainPreferencesID }) else {
            return ScanConfiguration()
        }
        return model.decoded ?? ScanConfiguration()
    }

    func saveConfiguration(_ config: ScanConfiguration) throws {
        let results = try modelContext.fetch(FetchDescriptor<AppPreferencesModel>())
        if let existing = results.first(where: { $0.id == mainPreferencesID }) {
            existing.data = AppPreferencesModel.encode(config)
        } else {
            modelContext.insert(AppPreferencesModel(data: AppPreferencesModel.encode(config)))
        }
        try modelContext.save()
    }
}
