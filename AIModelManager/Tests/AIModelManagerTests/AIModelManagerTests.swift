import XCTest
#if canImport(AIModelManager)
@testable import AIModelManager
#else
@testable import AI_Model_Manager
#endif

final class AIModelManagerTests: XCTestCase {
    func testDeduplicationUsesStandardizedPath() {
        let a = AIModel(id: UUID(), groupingKey: "/tmp/model", name: "A", engine: "Ollama", location: URL(fileURLWithPath: "/tmp/a.gguf"), deletionLocation: URL(fileURLWithPath: "/tmp/a.gguf"), size: 1, fileCount: 1, primaryExtension: "gguf", sha256: nil, itemCount: 1)
        let b = AIModel(id: UUID(), groupingKey: "/tmp/model", name: "B", engine: "Ollama", location: URL(fileURLWithPath: "/tmp/./a.gguf"), deletionLocation: URL(fileURLWithPath: "/tmp/a.gguf"), size: 1, fileCount: 1, primaryExtension: "gguf", sha256: nil, itemCount: 1)
        XCTAssertEqual(DirectoryModelScanner.deduplicate([a, b]).count, 1)
    }

    func testGroupingKeyCollapsesHFSnapshots() {
        let path = URL(fileURLWithPath: "/Users/me/.cache/huggingface/hub/models--org--repo/snapshots/abc123/model.safetensors")
        XCTAssertEqual(
            ModelMetadataExtractor.groupingKey(for: path),
            "/Users/me/.cache/huggingface/hub/models--org--repo"
        )
    }

    func testDisplayNameCollapsesHFSnapshotName() {
        let path = URL(fileURLWithPath: "/Users/me/.cache/huggingface/hub/models--meta-llama--Llama-3.2-3B-Instruct/snapshots/abc123/model.safetensors")
        XCTAssertEqual(
            ModelMetadataExtractor.displayName(for: path),
            "Llama-3.2-3B-Instruct"
        )
    }

    func testDisplayNameCollapsesVLLMHFCacheName() {
        let path = URL(fileURLWithPath: "/Users/me/.cache/vllm/models--Qwen--Qwen2.5-7B-Instruct/snapshots/abc123/model.safetensors")
        XCTAssertEqual(
            ModelMetadataExtractor.displayName(for: path),
            "Qwen2.5-7B-Instruct"
        )
    }

    func testDisplayNameRemovesTechnicalSuffixes() {
        let path = URL(fileURLWithPath: "/Volumes/models/Llama-3.1-8B-Instruct-FP16.gguf")
        XCTAssertEqual(
            ModelMetadataExtractor.displayName(for: path),
            "Llama-3.1-8B-Instruct"
        )
    }

    func testDeletionLocationUsesRepositoryRootForHFSnapshot() {
        let path = URL(fileURLWithPath: "/Users/me/.cache/huggingface/hub/models--org--repo/snapshots/abc123/model.safetensors")
        XCTAssertEqual(
            ModelMetadataExtractor.deletionLocation(for: path).path,
            "/Users/me/.cache/huggingface/hub/models--org--repo"
        )
    }

    func testInspectableLocationUsesRepositoryRootForHFSnapshot() {
        let extractor = ModelMetadataExtractor(fileSystem: FileSystem.default)
        let model = extractor.inspect(
            url: URL(fileURLWithPath: "/Users/me/.cache/huggingface/hub/models--org--repo/snapshots/abc123/model.safetensors"),
            engine: "HuggingFace",
            candidateFiles: [URL(fileURLWithPath: "/Users/me/.cache/huggingface/hub/models--org--repo/snapshots/abc123/model.safetensors")]
        )
        XCTAssertEqual(model.location.path, "/Users/me/.cache/huggingface/hub/models--org--repo")
    }

    func testOllamaManifestScannerUsesManifestFolderAndTotalSize() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let manifestDir = tempDir.appendingPathComponent("manifests/registry.ollama.ai/library/qwen3-8b", isDirectory: true)
        try FileManager.default.createDirectory(at: manifestDir, withIntermediateDirectories: true)
        let manifestURL = manifestDir.appendingPathComponent("latest")
        let manifest = #"{"config":{"digest":"sha256:abc","size":10},"layers":[{"digest":"sha256:def","size":20},{"digest":"sha256:def","size":20}]}"#
        try manifest.data(using: .utf8)!.write(to: manifestURL)

        let models = try await OllamaModelScanner(roots: [tempDir]).scan()

        XCTAssertEqual(models.count, 1)
        XCTAssertEqual(models[0].name, "qwen3-8b:latest")
        XCTAssertEqual(models[0].location.standardizedFileURL.path, manifestDir.standardizedFileURL.path)
        XCTAssertEqual(models[0].size, 30)
    }

    func testOllamaDeletionStrategyIncludesBlobEstimate() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let manifestDir = tempDir.appendingPathComponent("manifests/registry.ollama.ai/library/qwen3-8b", isDirectory: true)
        try FileManager.default.createDirectory(at: manifestDir, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("blobs"), withIntermediateDirectories: true)
        try "abc".write(to: tempDir.appendingPathComponent("blobs/sha256-abc"), atomically: true, encoding: .utf8)
        try "def".write(to: tempDir.appendingPathComponent("blobs/sha256-def"), atomically: true, encoding: .utf8)
        try "zzz".write(to: tempDir.appendingPathComponent("blobs/sha256-zzz"), atomically: true, encoding: .utf8)
        let manifest = #"{"config":{"digest":"sha256:abc","size":10},"layers":[{"digest":"sha256:def","size":20}]}"#
        try manifest.data(using: .utf8)!.write(to: manifestDir.appendingPathComponent("latest"))

        let model = AIModel(
            id: UUID(),
            groupingKey: manifestDir.standardizedFileURL.path,
            name: "qwen3-8b:latest",
            engine: "Ollama",
            location: manifestDir.standardizedFileURL,
            deletionLocation: manifestDir.standardizedFileURL,
            size: 30,
            fileCount: 1,
            primaryExtension: nil,
            sha256: nil,
            itemCount: 1
        )

        let dirs = try await OllamaDeletionStrategy().directoriesToDelete(for: model)
        let paths = Set(dirs.map(\.standardizedFileURL.path))

        XCTAssertTrue(paths.contains(manifestDir.standardizedFileURL.path))
        XCTAssertEqual(paths.count, 1)

        let estimated = try await OllamaDeletionStrategy().estimatedReclaimedBytes(for: model)
        XCTAssertGreaterThan(estimated, 30)
    }

    func testOllamaDisplayNameIncludesTag() {
        let manifest = URL(fileURLWithPath: "/Users/me/.ollama/models/manifests/registry.ollama.ai/library/qwen3-8b/latest")
        let folder = manifest.deletingLastPathComponent()
        XCTAssertEqual(OllamaModelScanner.displayName(for: manifest, modelFolder: folder), "qwen3-8b:latest")
    }

    func testDeletionLocationUsesFileForStandaloneModel() {
        let path = URL(fileURLWithPath: "/Volumes/models/model.gguf")
        XCTAssertEqual(
            ModelMetadataExtractor.deletionLocation(for: path).path,
            "/Volumes/models/model.gguf"
        )
    }

    func testByteFormatting() {
        XCTAssertFalse(Formatting.byteCount(1024).isEmpty)
    }

    func testLMStudioDeletionStrategyIncludesHubCache() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("hub/models/publisher/model-name"), withIntermediateDirectories: true)
        try "".write(to: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS/model.gguf"), atomically: true, encoding: .utf8)
        try "".write(to: tempDir.appendingPathComponent("hub/models/publisher/model-name/cache.bin"), atomically: true, encoding: .utf8)

        let model = AIModel(id: UUID(), groupingKey: "k", name: "IQ4 XS", engine: "LM Studio",
                            location: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS"),
                            deletionLocation: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS"),
                            size: 1, fileCount: 1, primaryExtension: "gguf", sha256: nil, itemCount: 1)

        let dirs = try await LMStudioDeletionStrategy().directoriesToDelete(for: model)
        let paths = Set(dirs.map { $0.standardizedFileURL.path })
        XCTAssertTrue(paths.contains(tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS").standardizedFileURL.path))
        XCTAssertTrue(paths.contains(tempDir.appendingPathComponent("hub/models/publisher/model-name").standardizedFileURL.path))
        XCTAssertEqual(paths.count, 2)
    }

    func testLMStudioDeletionStrategyFlatHubName() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("hub/models/models--publisher--model-name"), withIntermediateDirectories: true)
        try "".write(to: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS/model.gguf"), atomically: true, encoding: .utf8)
        try "".write(to: tempDir.appendingPathComponent("hub/models/models--publisher--model-name/cache.bin"), atomically: true, encoding: .utf8)

        let model = AIModel(id: UUID(), groupingKey: "k", name: "IQ4 XS", engine: "LM Studio",
                            location: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS"),
                            deletionLocation: tempDir.appendingPathComponent("models/publisher/model-name/IQ4_XS"),
                            size: 1, fileCount: 1, primaryExtension: "gguf", sha256: nil, itemCount: 1)

        let dirs = try await LMStudioDeletionStrategy().directoriesToDelete(for: model)
        let paths = Set(dirs.map { $0.standardizedFileURL.path })
        XCTAssertTrue(paths.contains(tempDir.appendingPathComponent("hub/models/models--publisher--model-name").standardizedFileURL.path))
        XCTAssertEqual(paths.count, 2)
    }

    func testLMStudioVariantDirectoriesNotDeduplicated() async throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let publisher = tempDir.appendingPathComponent("models/bartowski/DeepSeek-R1-0528-GGUF", isDirectory: true)
        try FileManager.default.createDirectory(at: publisher.appendingPathComponent("IQ4_XS", isDirectory: true), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: publisher.appendingPathComponent("Q3_K_S", isDirectory: true), withIntermediateDirectories: true)
        try "".write(to: publisher.appendingPathComponent("IQ4_XS/model.gguf"), atomically: true, encoding: .utf8)
        try "".write(to: publisher.appendingPathComponent("Q3_K_S/model.gguf"), atomically: true, encoding: .utf8)

        let models = await DirectoryModelScanner(engineName: "LM Studio", roots: [tempDir.appendingPathComponent("models")], fileSystem: FileSystem.default).scan()
        XCTAssertEqual(models.count, 2)
        let names = Set(models.map(\.name))
        XCTAssertTrue(names.contains("IQ4 XS"))
        XCTAssertTrue(names.contains("Q3 K S"))
    }

    func testOllamaRemoveOrphanBlobs() throws {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("manifests/registry.ollama.ai/library/qwen3-8b/latest", isDirectory: true), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tempDir.appendingPathComponent("blobs", isDirectory: true), withIntermediateDirectories: true)

        let manifest = #"{"config":{"digest":"sha256:abc","size":10},"layers":[{"digest":"sha256:def","size":20}]}"#
        try manifest.data(using: .utf8)!.write(to: tempDir.appendingPathComponent("manifests/registry.ollama.ai/library/qwen3-8b/latest/manifest.json"))

        try "".write(to: tempDir.appendingPathComponent("blobs/sha256-abc"), atomically: true, encoding: .utf8)
        try "".write(to: tempDir.appendingPathComponent("blobs/sha256-def"), atomically: true, encoding: .utf8)
        try "".write(to: tempDir.appendingPathComponent("blobs/sha256-orphan"), atomically: true, encoding: .utf8)

        OllamaModelScanner.removeOrphanBlobs(roots: [tempDir])

        let remaining = try FileManager.default.contentsOfDirectory(at: tempDir.appendingPathComponent("blobs"), includingPropertiesForKeys: nil)
        let names = Set(remaining.map(\.lastPathComponent))
        XCTAssertTrue(names.contains("sha256-abc"))
        XCTAssertTrue(names.contains("sha256-def"))
        XCTAssertFalse(names.contains("sha256-orphan"))
    }

    func testLMStudioDeletionStrategyWithModelsSymlink() async throws {
        let tmpRoot = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        let realModels = tmpRoot.appendingPathComponent("real-models", isDirectory: true)
        let hubDir = tmpRoot.appendingPathComponent("hub", isDirectory: true)
        try FileManager.default.createDirectory(at: realModels.appendingPathComponent("openai/gpt-oss-20b/Q4_K_M"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: hubDir.appendingPathComponent("models/openai/gpt-oss-20b"), withIntermediateDirectories: true)
        try "".write(to: realModels.appendingPathComponent("openai/gpt-oss-20b/Q4_K_M/model.gguf"), atomically: true, encoding: .utf8)
        try "".write(to: hubDir.appendingPathComponent("models/openai/gpt-oss-20b/cache.bin"), atomically: true, encoding: .utf8)
        try FileManager.default.createSymbolicLink(at: tmpRoot.appendingPathComponent("models", isDirectory: true),
                                                    withDestinationURL: realModels)

        let model = AIModel(id: UUID(), groupingKey: "k", name: "Q4_K_M", engine: "LM Studio",
                            location: tmpRoot.appendingPathComponent("models/openai/gpt-oss-20b/Q4_K_M"),
                            deletionLocation: tmpRoot.appendingPathComponent("models/openai/gpt-oss-20b/Q4_K_M"),
                            size: 1, fileCount: 1, primaryExtension: "gguf", sha256: nil, itemCount: 1)

        let dirs = try await LMStudioDeletionStrategy().directoriesToDelete(for: model)
        let paths = Set(dirs.map { $0.standardizedFileURL.path })
        XCTAssertTrue(paths.contains(tmpRoot.appendingPathComponent("hub/models/openai/gpt-oss-20b").standardizedFileURL.path),
                      "hub cache should be found even when models/ is a symlink")
        XCTAssertEqual(paths.count, 2)
    }
}
