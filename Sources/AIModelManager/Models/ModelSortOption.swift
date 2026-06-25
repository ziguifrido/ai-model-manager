import Foundation

enum ModelSortOption: String, CaseIterable, Identifiable {
    case name
    case size
    case engine

    var id: String { rawValue }
}

