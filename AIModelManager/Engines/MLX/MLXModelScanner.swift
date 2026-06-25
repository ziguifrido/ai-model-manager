import Foundation

struct MLXModelScanner: ModelScanner {
    let engineName = "MLX-LM"
    private let fileSystem = FileSystem.default
    let roots: [URL]
    init(roots: [URL] = EnginePaths.defaults(for: .mlx)) { self.roots = roots }
    func scan() async throws -> [AIModel] {
        await DirectoryModelScanner(engineName: engineName, roots: roots, fileSystem: fileSystem).scan()
    }
}
