# AGENTS

## Project Notes

- App name: `My AI Models`
- Platform: macOS 14+
- Stack: Swift 6, SwiftUI, MVVM

## Project Structure

```
Sources/
  AIModelManager/
    Models/           — AIModel struct, EngineKind, ModelSortOption, ScanConfiguration
    Views/            — ContentView, ModelTableView, ModelDetailView, SettingsView
    ViewModels/       — LibraryViewModel, SettingsViewModel
    Services/
      Scanner/        — DirectoryModelScanner, ModelScannerService
      Engines/        — One scanner per engine (Ollama, LM Studio, HF, MLX, vLLM)
                      — Deletion strategies (LMStudioDeletionStrategy)
                      — EnginePaths (default scan roots per engine)
      Metadata/       — ModelMetadataExtractor (display name, grouping, size)
      Configuration/  — ConfigurationStore (persistent scan config)
      Filesystem/     — FileSystem (thin wrapper over FileManager)
    Persistence/      — ModelInventoryStore (in-memory model list)
    Utilities/        — Formatting (byte count formatter)
    Support/          — AppContainer (DI assembly)
  AIModelManagerApp/  — @main entry point
Tests/
  AIModelManagerTests/
```

## Scanner Behavior

- **Ollama** — reads manifest JSON files under `<root>/manifests/`, extracts name/size from manifest. Blob-level GC in `removeOrphanBlobs()`.
- **LM Studio** — scans `models/` subdirectories under each configured root. Deletion also cleans up matching directories under `hub/models/`.
- **HuggingFace** — scans HF cache layout (snapshots/refs/versions), collapses to repo root.
- **MLX** — scans `mlx-models/`, `Models/`, and `.cache/mlx`.
- **vLLM** — scans `.cache/vllm`.

## LM Studio Hub Matching

When deleting an LM Studio model, the strategy walks up the path looking for a sibling `hub/models/` directory. The hub dir name match is bidirectional: the model name may be either a substring of the hub dir name (e.g. flat HF-style `models--publisher--model-name`) or the hub dir name may be a substring of the model name (e.g. base `gemma-3-4b` vs quantized `gemma-3-4b-it-qat-4bit`).

## Removed Fields

- `format` (ModelFormat) — removed from AIModel, along with ModelFormat.swift, ModelFormatDetector.swift, ModelFilter.swift (unused).
- `modifiedAt`, `createdAt`, `lastAccess` — removed from AIModel, along with Formatting.date formatter and FileSystem.resourceValues().

## Working Rule

- Keep changes minimal and root-cause focused.
- Prefer native macOS APIs and shared helpers already in the codebase.
