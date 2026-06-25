import Foundation

final class FileWatcherService {
    private var sources: [DispatchSourceFileSystemObject] = []

    func startWatching(urls: [URL], onChange: @escaping () -> Void) {
        stop()
        for url in urls {
            let fd = open(url.path, O_EVTONLY)
            guard fd >= 0 else { continue }
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: fd,
                eventMask: [.write, .rename, .delete],
                queue: DispatchQueue.global(qos: .utility)
            )
            source.setEventHandler { onChange() }
            source.setCancelHandler { close(fd) }
            source.resume()
            sources.append(source)
        }
    }

    func stop() {
        sources.forEach { $0.cancel() }
        sources.removeAll()
    }

    deinit { stop() }
}
