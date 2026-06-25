import Foundation

struct HuggingFaceModelScanner: ModelScanner {
    let engineName = "HuggingFace"
    private let fileSystem = FileSystem.default
    let roots: [URL]
    init(roots: [URL] = EnginePaths.defaults(for: .huggingFace)) { self.roots = roots }
    func scan() async throws -> [AIModel] {
        await DirectoryModelScanner(engineName: engineName, roots: roots, fileSystem: fileSystem).scan()
    }
}
