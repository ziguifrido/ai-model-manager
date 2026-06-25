import Foundation

enum EnginePaths {
    static let home = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
    static func defaults(for engine: EngineKind) -> [URL] {
        switch engine {
        case .ollama:
            return [home.appendingPathComponent(".ollama/models"), URL(fileURLWithPath: "/usr/share/ollama", isDirectory: true)]
        case .lmStudio:
            return [home.appendingPathComponent(".cache/lm-studio"), home.appendingPathComponent("Library/Application Support/LM Studio"), home.appendingPathComponent("Library/Application Support/LM Studio/models")]
        case .huggingFace:
            return [home.appendingPathComponent(".cache/huggingface"), home.appendingPathComponent(".cache/huggingface/hub"), home.appendingPathComponent(".cache/huggingface/transformers")]
        case .mlx:
            return [home.appendingPathComponent(".cache/mlx"), home.appendingPathComponent("mlx-models"), home.appendingPathComponent("Models")]
        case .vllm:
            return [home.appendingPathComponent(".cache/vllm")]
        }
    }
}
