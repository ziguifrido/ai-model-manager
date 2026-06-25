import Foundation

struct FileSystem: Sendable {
    static let `default` = FileSystem()

    func exists(_ url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }

    func directoryContents(of url: URL) -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])) ?? []
    }

    func enumerator(at url: URL) -> FileManager.DirectoryEnumerator? {
        FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .contentModificationDateKey, .creationDateKey, .fileSizeKey, .contentAccessDateKey], options: [.skipsHiddenFiles], errorHandler: { _, _ in true })
    }

    func removeItem(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
}
