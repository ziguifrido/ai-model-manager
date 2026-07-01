import Foundation

struct OllamaDeletionStrategy: ModelDeletionStrategy {
    func directoriesToDelete(for model: AIModel) async throws -> [URL] {
        [model.location.standardizedFileURL]
    }

    func estimatedReclaimedBytes(for model: AIModel) async throws -> Int64 {
        let manifestDir = model.location.standardizedFileURL
        var total = ModelMetadataExtractor.directorySize(at: manifestDir, fileSystem: FileSystem.default)

        guard let root = ollamaRoot(for: manifestDir) else {
            return total
        }

        let manifestsRoot = root.appendingPathComponent("manifests", isDirectory: true)
        let blobsDir = root.appendingPathComponent("blobs", isDirectory: true)
        guard FileManager.default.fileExists(atPath: manifestsRoot.path),
              FileManager.default.fileExists(atPath: blobsDir.path) else {
            return total
        }

        guard let currentDigests = digests(in: manifestDir).map(Set.init) else { return total }
        guard !currentDigests.isEmpty else { return total }

        var used = Set<String>()
        guard let enumerator = FileManager.default.enumerator(at: manifestsRoot, includingPropertiesForKeys: nil) else {
            return total
        }

        while let url = enumerator.nextObject() as? URL {
            guard !url.hasDirectoryPath else { continue }
            guard url.standardizedFileURL != manifestDir.standardizedFileURL else { continue }
            guard let digests = digests(in: url) else { continue }
            used.formUnion(digests)
        }

        let remainingUsage = used.subtracting(currentDigests)
        for blobURL in (try? FileManager.default.contentsOfDirectory(at: blobsDir, includingPropertiesForKeys: nil)) ?? [] {
            let digest = blobURL.lastPathComponent.replacingOccurrences(of: "-", with: ":")
            if !remainingUsage.contains(digest) {
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

    private func digests(in modelDir: URL) -> [String]? {
        let files = (try? FileManager.default.contentsOfDirectory(at: modelDir, includingPropertiesForKeys: nil)) ?? []
        var digests: [String] = []
        for file in files where !file.hasDirectoryPath {
            guard let data = try? Data(contentsOf: file),
                  let manifest = try? JSONDecoder().decode(OllamaManifest.self, from: data) else {
                continue
            }

            if let digest = manifest.config?.digest { digests.append(digest) }
            for layer in manifest.layers ?? [] {
                if let digest = layer.digest { digests.append(digest) }
            }
        }
        return digests.isEmpty ? nil : digests
    }
}
