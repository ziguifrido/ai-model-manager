import Foundation
import SwiftData

@Model
final class ScanConfigurationModel {
    var engineRawValues: [String]
    var customPaths: [String]

    init(engineRawValues: [String] = [], customPaths: [String] = []) {
        self.engineRawValues = engineRawValues
        self.customPaths = customPaths
    }

    var engineKind: EngineKind? {
        get { EngineKind(rawValue: engineRawValues.first ?? "") }
        set { engineRawValues = newValue.map { [$0.rawValue] } ?? [] }
    }
}
