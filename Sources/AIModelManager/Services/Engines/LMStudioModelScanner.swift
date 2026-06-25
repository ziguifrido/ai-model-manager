import Foundation

struct LMStudioModelScanner: ModelScanner {
    let engineName = "LM Studio"
    private let fileSystem = FileSystem.default
    let roots: [URL]
    init(roots: [URL] = EnginePaths.defaults(for: .lmStudio)) { self.roots = roots }
    func scan() async throws -> [AIModel] {
        let modelRoots = roots.compactMap(modelsRoot(in:))
        return await DirectoryModelScanner(engineName: engineName, roots: modelRoots, fileSystem: fileSystem).scan()
    }

    private func modelsRoot(in root: URL) -> URL? {
        let standardized = root.standardizedFileURL
        if standardized.lastPathComponent.lowercased() == "models" {
            return standardized
        }

        let directModels = standardized.appendingPathComponent("models", isDirectory: true)
        if fileSystem.exists(directModels) {
            return directModels
        }

        return nil
    }
}
