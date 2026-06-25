import Foundation

protocol ModelScanner: Sendable {
    var engineName: String { get }
    func scan() async throws -> [AIModel]
}

