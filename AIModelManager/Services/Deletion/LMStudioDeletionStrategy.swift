import Foundation
import OSLog

private let log = Logger(subsystem: "com.myaimodels", category: "LMStudioDeletionStrategy")

struct LMStudioDeletionStrategy: ModelDeletionStrategy {
    func directoriesToDelete(for model: AIModel) async throws -> [URL] {
        let loc = model.location
        log.debug("model location: \(loc.path, privacy: .public)")
        var dirs = [loc]

        var current = loc
        while true {
            let next = current.deletingLastPathComponent()
            if next == current || next.pathComponents.count <= 1 { break }
            current = next

            let hubModels = current.appendingPathComponent("hub", isDirectory: true).appendingPathComponent("models", isDirectory: true)
            log.debug("checking: \(hubModels.path, privacy: .public)")
            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: hubModels.path, isDirectory: &isDir), isDir.boolValue else {
                log.debug("hub/models not found at this level")
                continue
            }

            log.debug("found hub/models at ancestor: \(current.path, privacy: .public)")

            let relPath = loc.path.dropFirst(current.path.count + 1)
            log.debug("relative path: \(relPath, privacy: .public)")
            let parts = relPath.split(separator: "/", maxSplits: 3, omittingEmptySubsequences: true)
            log.debug("parts: \(parts, privacy: .public)")
            guard parts.count >= 3, parts[0] == "models" else {
                log.debug("parts don't match expected structure")
                break
            }

            let modelName = String(parts[2])
            log.debug("model name for hub search: \(modelName, privacy: .public)")

            let hubDirs = Self.matchingHubDirs(hubModels, modelName: modelName, depth: 2)
            log.debug("matching hub dirs: \(hubDirs.map(\.path), privacy: .public)")
            dirs += hubDirs
            break
        }

        let result = Array(Set(dirs))
        log.debug("final dirs: \(result.map(\.path), privacy: .public)")
        return result
    }

    // ponytail: breadth-limited search so unrelated dirs aren't swept up
    private static func matchingHubDirs(_ url: URL, modelName: String, depth: Int) -> [URL] {
        guard depth > 0 else { return [] }
        var matches: [URL] = []
        guard let entries = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey]) else {
            return matches
        }
        for entry in entries {
            guard (try? entry.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true else { continue }
            let name = entry.lastPathComponent.lowercased()
            if name.contains(modelName.lowercased()) || modelName.lowercased().contains(name) {
                matches.append(entry.standardizedFileURL)
            }
            matches += Self.matchingHubDirs(entry, modelName: modelName, depth: depth - 1)
        }
        return matches
    }
}
