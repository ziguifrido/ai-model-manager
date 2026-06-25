import Foundation

struct VLLMModelScanner: ModelScanner {
    let engineName = "vLLM"
    private let fileSystem = FileSystem.default
    let roots: [URL]
    init(roots: [URL] = EnginePaths.defaults(for: .vllm)) { self.roots = roots }
    func scan() async throws -> [AIModel] {
        await DirectoryModelScanner(engineName: engineName, roots: roots, fileSystem: fileSystem).scan()
    }
}
