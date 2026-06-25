import Foundation

struct DirectoryModelScanner {
    let engineName: String
    let roots: [URL]
    let fileSystem: FileSystem

    func scan() async -> [AIModel] {
        await withTaskGroup(of: [AIModel].self) { group in
            for root in roots where fileSystem.exists(root) {
                group.addTask {
                    self.scanRoot(root)
                }
            }
            var results: [AIModel] = []
            for await chunk in group { results += chunk }
            return Self.deduplicate(results)
        }
    }

    private func scanRoot(_ root: URL) -> [AIModel] {
        let extractor = ModelMetadataExtractor(fileSystem: fileSystem)
        var found: [AIModel] = []
        var emittedRoots: [URL] = []
        guard let enumerator = fileSystem.enumerator(at: root) else { return [] }
        for case let url as URL in enumerator {
            if url.lastPathComponent.hasPrefix(".") { continue }
            if isTemporary(url) { continue }
            if isUnderEmittedRoot(url, roots: emittedRoots) { continue }
            if url.hasDirectoryPath {
                if isIgnoredContainer(url) { continue }
                let names = Set(fileSystem.directoryContents(of: url).map { $0.lastPathComponent.lowercased() })
                let candidate = fileSystem.directoryContents(of: url).filter { isModelFile($0) }
                if !candidate.isEmpty || isModelDirectory(names) {
                    found.append(extractor.inspect(url: url, engine: engineName, candidateFiles: candidate.isEmpty ? [url] : candidate))
                    emittedRoots.append(url.standardizedFileURL)
                    enumerator.skipDescendants()
                }
            } else if isModelFile(url) {
                let modelRoot = url.deletingLastPathComponent().standardizedFileURL
                found.append(extractor.inspect(url: url, engine: engineName, candidateFiles: [url]))
                emittedRoots.append(modelRoot)
            }
        }
        return found
    }

    private func isUnderEmittedRoot(_ url: URL, roots: [URL]) -> Bool {
        let path = url.standardizedFileURL.path
        return roots.contains { path.hasPrefix($0.path + "/") || path == $0.path }
    }

    private func isModelDirectory(_ names: Set<String>) -> Bool {
        !names.isDisjoint(with: ["config.json", "tokenizer.json", "generation_config.json", "special_tokens_map.json"])
    }

    private func isModelFile(_ url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return ["gguf","safetensors","bin","pt","pth","ckpt","onnx","mlpackage","mlmodel","json","tokenizer","model"].contains(ext)
    }

    private func isTemporary(_ url: URL) -> Bool {
        let name = url.lastPathComponent.lowercased()
        return name.hasSuffix(".tmp") || name.hasSuffix(".download") || name.contains("partial")
    }

    private func isIgnoredContainer(_ url: URL) -> Bool {
        let name = url.lastPathComponent.lowercased()
        return name.contains("preset") || name == "cache" || name == "tmp" || name == "temp"
    }

    static func deduplicate(_ models: [AIModel]) -> [AIModel] {
        var seen = Set<String>()
        return models.filter { seen.insert($0.groupingKey).inserted }
    }
}
