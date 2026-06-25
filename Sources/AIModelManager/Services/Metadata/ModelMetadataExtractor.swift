import Foundation

struct ModelMetadataExtractor {
    let fileSystem: FileSystem

    func inspect(url: URL, engine: String, candidateFiles: [URL]) -> AIModel {
        let groupingKey = Self.groupingKey(for: url)
        let displayName = Self.displayName(for: url)
        let deletionLocation = Self.deletionLocation(for: url)
        let size = Self.size(at: deletionLocation, fileSystem: fileSystem)
        return AIModel(
            id: UUID(),
            groupingKey: groupingKey,
            name: displayName,
            engine: engine,
            location: deletionLocation,
            deletionLocation: deletionLocation,
            size: size,
            fileCount: candidateFiles.count,
            primaryExtension: url.pathExtension.lowercased(),
            sha256: nil,
            itemCount: candidateFiles.count
        )
    }

    static func groupingKey(for url: URL) -> String {
        let standardized = url.standardizedFileURL
        let components = standardized.pathComponents
        if let snapshotsIndex = components.firstIndex(of: "snapshots"), snapshotsIndex > 0 {
            return "/" + components.prefix(snapshotsIndex).dropFirst().joined(separator: "/")
        }
        if let versionsIndex = components.firstIndex(of: "versions"), versionsIndex > 0 {
            return "/" + components.prefix(versionsIndex).dropFirst().joined(separator: "/")
        }
        // ponytail: use actual path so sibling variant dirs (e.g. LM Studio) get unique keys
        return standardized.path
    }

    static func deletionLocation(for url: URL) -> URL {
        let resolved = url
        guard !resolved.hasDirectoryPath else {
            let components = Array(resolved.pathComponents)
            if let snapshotsIndex = components.firstIndex(of: "snapshots"), snapshotsIndex > 0 {
                return URL(fileURLWithPath: "/" + components.dropFirst().prefix(snapshotsIndex - 1).joined(separator: "/"), isDirectory: true)
            }
            if let versionsIndex = components.firstIndex(of: "versions"), versionsIndex > 0 {
                return URL(fileURLWithPath: "/" + components.dropFirst().prefix(versionsIndex - 1).joined(separator: "/"), isDirectory: true)
            }
            return resolved
        }

        let components = Array(resolved.pathComponents)
        if let snapshotsIndex = components.firstIndex(of: "snapshots"), snapshotsIndex > 0 {
            return URL(fileURLWithPath: "/" + components.dropFirst().prefix(snapshotsIndex - 1).joined(separator: "/"), isDirectory: true)
        }
        if let versionsIndex = components.firstIndex(of: "versions"), versionsIndex > 0 {
            return URL(fileURLWithPath: "/" + components.dropFirst().prefix(versionsIndex - 1).joined(separator: "/"), isDirectory: true)
        }
        return resolved
    }

    static func displayName(for url: URL) -> String {
        let standardized = url.standardizedFileURL
        let components = Array(standardized.pathComponents)
        if let hfCacheFolder = components.first(where: { $0.hasPrefix("models--") }) {
            return humanizeRepositoryName(hfRepositoryName(from: hfCacheFolder))
        }

        if let snapshotIndex = components.firstIndex(where: { ["snapshots", "versions", "refs"].contains($0) }),
           snapshotIndex > 0 {
            let repoRoot = components[snapshotIndex - 1]
            if repoRoot.hasPrefix("models--") {
                return humanizeRepositoryName(hfRepositoryName(from: repoRoot))
            }
        }

        let parentName = standardized.deletingLastPathComponent().lastPathComponent
        if parentName.hasPrefix("vllm") {
            return humanizeRepositoryName(standardized.deletingLastPathComponent().deletingLastPathComponent().lastPathComponent)
        }

        return humanizeRepositoryName(standardized.deletingPathExtension().lastPathComponent)
    }

    private static func hfRepositoryName(from cacheFolder: String) -> String {
        let trimmed = cacheFolder.replacingOccurrences(of: "models--", with: "")
        let pieces = trimmed.split(separator: "--", omittingEmptySubsequences: false)
        guard pieces.count >= 2 else { return trimmed }
        return pieces.joined(separator: "/")
    }

    private static func humanizeRepositoryName(_ raw: String) -> String {
        var result = raw
        let suffixes = [
            #"(?i)[ _-]?(gguf|safetensors|fp16|fp32|int4|int8|quantized|quant|model|models|checkpoint)$"#,
            #"(?i)[ _-]?(q4_0|q4_1|q4_k_m|q5_0|q5_1|q8_0)$"#
        ]
        for pattern in suffixes {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
            }
        }
        result = result.replacingOccurrences(of: "_", with: " ")
        result = result.replacingOccurrences(of: "  ", with: " ")
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func size(at url: URL, fileSystem: FileSystem) -> Int64 {
        if url.hasDirectoryPath {
            var total: Int64 = 0
            guard let enumerator = fileSystem.enumerator(at: url) else { return 0 }
            for case let fileURL as URL in enumerator {
                if fileURL.hasDirectoryPath { continue }
                let fileSize = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0
                total += fileSize
            }
            return total
        }
        return (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize).map(Int64.init) ?? 0
    }

    static func directorySize(at url: URL, fileSystem: FileSystem) -> Int64 {
        size(at: url, fileSystem: fileSystem)
    }

}
