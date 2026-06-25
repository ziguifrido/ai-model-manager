import Foundation

struct OllamaModelScanner: ModelScanner {
    let engineName = "Ollama"
    private let fileSystem = FileSystem.default
    let roots: [URL]

    init(roots: [URL] = EnginePaths.defaults(for: .ollama)) {
        self.roots = roots
    }

    func scan() async throws -> [AIModel] {
        var models: [AIModel] = []
        for root in roots where fileSystem.exists(root) {
            if let manifestsRoot = manifestsRoot(in: root) {
                models += scanManifests(root: manifestsRoot)
            }
        }
        return models
    }

    private func scanManifests(root manifestsRoot: URL) -> [AIModel] {
        guard let enumerator = fileSystem.enumerator(at: manifestsRoot) else { return [] }
        var found: [AIModel] = []
        for case let url as URL in enumerator {
            guard !url.hasDirectoryPath else { continue }
            guard !url.lastPathComponent.hasPrefix(".") else { continue }
            guard let model = model(from: url, manifestsRoot: manifestsRoot) else { continue }
            found.append(model)
        }
        return found
    }

    private func manifestsRoot(in root: URL) -> URL? {
        let direct = root.appendingPathComponent("manifests", isDirectory: true)
        if fileSystem.exists(direct) { return direct }

        let nested = root.appendingPathComponent("models", isDirectory: true).appendingPathComponent("manifests", isDirectory: true)
        if fileSystem.exists(nested) { return nested }

        return nil
    }

    private func model(from manifest: URL, manifestsRoot: URL) -> AIModel? {
        guard let data = try? Data(contentsOf: manifest),
              let parsed = try? JSONDecoder().decode(OllamaManifest.self, from: data) else {
            return nil
        }

        let modelFolder = manifest.deletingLastPathComponent()
        let standardizedFolder = modelFolder.standardizedFileURL
        let comps = standardizedFolder.pathComponents
        // ponytail: model name is the component after "library" in the path, works even when prefix stripping fails
        let name = comps.firstIndex(of: "library").flatMap { $0 + 1 < comps.count ? comps[$0 + 1] : nil } ?? standardizedFolder.lastPathComponent
        let size = parsed.totalSize

        return AIModel(
            id: UUID(),
            groupingKey: standardizedFolder.path,
            name: name,
            engine: engineName,
            location: standardizedFolder,
            deletionLocation: standardizedFolder,
            size: size,
            fileCount: 1,
            primaryExtension: nil,
            sha256: nil,
            itemCount: 1
        )
    }

    // ponytail: scans all manifests, deletes blobs whose digest no remaining manifest references
    static func removeOrphanBlobs(roots: [URL] = EnginePaths.defaults(for: .ollama)) {
        let fs = FileSystem.default
        for root in roots where fs.exists(root) {
            let direct = root.appendingPathComponent("manifests", isDirectory: true)
            let nested = root.appendingPathComponent("models", isDirectory: true).appendingPathComponent("manifests", isDirectory: true)
            guard let manifestsRoot = fs.exists(direct) ? direct : (fs.exists(nested) ? nested : nil) else { continue }
            let blobsDir = root.appendingPathComponent("blobs", isDirectory: true)
            guard fs.exists(blobsDir) else { continue }

            var used = Set<String>()
            guard let enumerator = fs.enumerator(at: manifestsRoot) else { continue }
            for case let url as URL in enumerator {
                guard !url.hasDirectoryPath else { continue }
                guard let data = try? Data(contentsOf: url),
                      let manifest = try? JSONDecoder().decode(OllamaManifest.self, from: data) else { continue }
                if let d = manifest.config?.digest { used.insert(d) }
                for layer in manifest.layers ?? [] { if let d = layer.digest { used.insert(d) } }
            }

            for blobURL in fs.directoryContents(of: blobsDir) {
                let digest = blobURL.lastPathComponent.replacingOccurrences(of: "-", with: ":")
                if !used.contains(digest) { try? fs.removeItem(at: blobURL) }
            }
        }
    }
}

private struct OllamaManifest: Decodable {
    struct Layer: Decodable {
        let size: Int64?
        let digest: String?
    }

    let config: Layer?
    let layers: [Layer]?

    var totalSize: Int64 {
        var digests = Set<String>()
        var total: Int64 = 0
        if let config, let size = config.size {
            total += size
        }
        for layer in layers ?? [] {
            if let digest = layer.digest, digests.insert(digest).inserted {
                total += layer.size ?? 0
            }
        }
        return total
    }
}
