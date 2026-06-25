import Foundation
import SwiftData

@Model
final class AppPreferencesModel {
    var id: String = "main"
    var data: Data

    init(data: Data) {
        self.data = data
    }

    var decoded: ScanConfiguration? {
        try? JSONDecoder().decode(ScanConfiguration.self, from: data)
    }

    static func encode(_ config: ScanConfiguration) -> Data {
        (try? JSONEncoder().encode(config)) ?? Data()
    }
}
