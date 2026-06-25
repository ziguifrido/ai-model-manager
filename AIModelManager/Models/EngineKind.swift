import Foundation

enum EngineKind: String, CaseIterable, Identifiable, Codable, Sendable {
    case ollama
    case lmStudio
    case huggingFace
    case mlx
    case vllm

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ollama: return "Ollama"
        case .lmStudio: return "LM Studio"
        case .huggingFace: return "Hugging Face"
        case .mlx: return "MLX"
        case .vllm: return "vLLM"
        }
    }
}

