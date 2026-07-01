import Foundation

struct OllamaDeletionStrategy: ModelDeletionStrategy {
    func directoriesToDelete(for model: AIModel) async throws -> [URL] {
        [model.location.standardizedFileURL]
    }

    func estimatedReclaimedBytes(for model: AIModel) async throws -> Int64 {
        let manifestFile = model.location.standardizedFileURL
        var total = ModelMetadataExtractor.directorySize(at: manifestFile, fileSystem: FileSystem.default)
        let manifestDir = manifestFile.deletingLastPathComponent()

        guard let root = ollamaRoot(for: manifestDir) else {
            return total
        }

        let manifestsRoot = root.appendingPathComponent("manifests", isDirectory: true)
        let blobsDir = root.appendingPathComponent("blobs", isDirectory: true)
        guard FileManager.default.fileExists(atPath: manifestsRoot.path),
              FileManager.default.fileExists(atPath: blobsDir.path) else {
            return total
        }

        guard let currentDigests = digests(in: manifestFile).map(Set.init) else { return total }
        guard !currentDigests.isEmpty else { return total }

        var used = Set<String>()
        guard let enumerator = FileManager.default.enumerator(at: manifestsRoot, includingPropertiesForKeys: nil) else {
            return total
        }

        while let url = enumerator.nextObject() as? URL {
            guard !url.hasDirectoryPath else { continue }
            guard url.standardizedFileURL != manifestFile.standardizedFileURL else { continue }
            guard let digests = digests(in: url) else { continue }
            used.formUnion(digests)
        }

        let exclusiveDigests = currentDigests.subtracting(used)
        for blobURL in (try? FileManager.default.contentsOfDirectory(at: blobsDir, includingPropertiesForKeys: nil)) ?? [] {
            let digest = blobURL.lastPathComponent.replacingOccurrences(of: "-", with: ":")
            if exclusiveDigests.contains(digest) {
                total += ModelMetadataExtractor.directorySize(at: blobURL, fileSystem: FileSystem.default)
            }
        }

        return total
    }

    private func ollamaRoot(for manifestDir: URL) -> URL? {
        var current = manifestDir.standardizedFileURL
        while true {
            let next = current.deletingLastPathComponent()
            if next == current { return nil }
            let blobs = next.appendingPathComponent("blobs", isDirectory: true)
            let manifests = next.appendingPathComponent("manifests", isDirectory: true)
            if FileManager.default.fileExists(atPath: blobs.path), FileManager.default.fileExists(atPath: manifests.path) {
                return next
            }
            current = next
        }
    }

    private func digests(in manifestFile: URL) -> [String]? {
        guard let data = try? Data(contentsOf: manifestFile),
              let manifest = try? JSONDecoder().decode(OllamaManifest.self, from: data) else {
            return nil
        }

        var digests: [String] = []
        if let digest = manifest.config?.digest { digests.append(digest) }
        for layer in manifest.layers ?? [] {
            if let digest = layer.digest { digests.append(digest) }
        }
        return digests.isEmpty ? nil : digests
    }
}
