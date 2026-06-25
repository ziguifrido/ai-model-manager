import Foundation

struct AIModel: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let groupingKey: String
    let name: String
    let engine: String
    let location: URL
    let deletionLocation: URL
    let size: Int64
    let fileCount: Int
    let primaryExtension: String?
    let sha256: String?
    let itemCount: Int
}
