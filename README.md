# AI Model Manager

[![Build](https://github.com/ziguifrido/ai-model-manager/actions/workflows/build.yml/badge.svg)](https://github.com/ziguifrido/ai-model-manager/actions/workflows/build.yml)
[![Test](https://github.com/ziguifrido/ai-model-manager/actions/workflows/test.yml/badge.svg)](https://github.com/ziguifrido/ai-model-manager/actions/workflows/test.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A native macOS application for discovering and managing local AI models installed by Ollama, LM Studio, Hugging Face, MLX, and vLLM.

---

## Overview

AI Model Manager scans your local model directories, presents them in a clean SwiftUI interface, and helps you understand disk usage, find duplicates, and safely delete models you no longer need.

Version: `0.1.8`

---

## Features

| Feature | Description |
|---------|-------------|
| **Automatic Model Discovery** | Scans default and custom directories for installed models |
| **Ollama Support** | Reads manifest JSON from `registry.ollama.ai`; orphan blob garbage collection |
| **LM Studio Support** | Scans model variants; hub cache cleanup on deletion |
| **Hugging Face Support** | Collapses snapshot/ref/version hierarchy to repo root |
| **MLX Support** | Scans `mlx-models/`, `Models/`, and `.cache/mlx` |
| **vLLM Support** | Scans `.cache/vllm` |
| **Statistics** | Total models, disk usage, per-engine breakdown |
| **Duplicate Detection** | Deduplication via standardized path matching |
| **Safe Deletion** | Preview with per-directory breakdown; undo-aware flow |
| **Native SwiftUI** | NavigationSplitView, Table, grouped Forms, Search, Dark Mode |

---

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16+ **or** Swift 6.0+ toolchain
- Apple Silicon **or** Intel Mac

---

## Installation

### Download from GitHub Releases

1. Go to the [Releases](https://github.com/ziguifrido/ai-model-manager/releases) page.
2. Download `AIModelManager.zip` from the latest release.
3. Extract: `unzip AIModelManager.zip`
4. Move to Applications: `mv AIModelManager.app /Applications/`

### Homebrew

```bash
brew tap ziguifrido/ai-model-manager
brew install --cask ai-model-manager
```

---

## Building

### Xcode (recommended)

```bash
open AIModelManager.xcodeproj
```

Select the `AIModelManagerApp` scheme, choose *My Mac* as destination, and press `⌘R`.

### SwiftPM (CLI)

```bash
# Build the library (business logic only)
swift build --target AIModelManager

# Run tests
swift test
```

---

## Architecture

### MVVM + Observation

- Models (`AIModel`, `EngineKind`, `ScanConfiguration`) are pure Swift structs.
- ViewModels (`LibraryViewModel`, `SettingsViewModel`) use Swift 6 `@Observable`.
- Views (`ContentView`, `ModelBrowserView`, `ModelInspectorView`) observe ViewModels via `@Bindable`.
- Dependency injection via `AppContainer` (`@Observable`, passed through `.environment()`).

### Scanner Architecture

```text
ModelScanner (protocol)
├── OllamaModelScanner
├── LMStudioModelScanner
├── HuggingFaceModelScanner
├── MLXModelScanner
└── VLLMModelScanner
```

Each scanner conforms to `ModelScanner` and returns `[AIModel]`. Scanners are composed in `ModelScannerService` which runs them concurrently via `async let`.

### Deletion Strategy

```text
ModelDeletionStrategy (protocol)
└── LMStudioDeletionStrategy
```

Deletion strategies compute the set of directories to remove. The LM Studio strategy also cleans up the matching hub cache directory. Additional engines can adopt the protocol.

### Statistics

`ModelStatistics` computes totals, per-engine breakdowns, and largest/smallest models from `[AIModel]`. Used by the sidebar and inspector.

---

## Supported Engines

| Engine | Scan Roots | Deletion |
|--------|-----------|----------|
| **Ollama** | `~/.ollama/`, `~/.local/share/ollama/` | Manifest + orphan blob GC |
| **LM Studio** | `~/.lmstudio/models/`, `~/Documents/LM Studio/models/` | Model dir + hub cache |
| **Hugging Face** | `~/.cache/huggingface/hub/` | Repository root |
| **MLX** | `~/.cache/mlx/`, `~/mlx-models/`, `~/Models/` | Model directory |
| **vLLM** | `~/.cache/vllm/` | Model directory |

### Adding a New Engine

1. Create a scanner in `AIModelManager/Engines/<Name>/` conforming to `ModelScanner`.
2. Add default scan roots in `EnginePaths.swift`.
3. Register in `AppContainer.live()`.
4. Add the engine to `EngineKind` enum in `AIModelManager/Models/EngineKind.swift`.

---

## Project Structure

```text
.
├── AIModelManager/              # Source root (library + app)
│   ├── App/                     # @main entry point, DI container, commands
│   ├── Engines/                 # Per-engine scanners
│   │   ├── Ollama/
│   │   ├── LMStudio/
│   │   ├── HuggingFace/
│   │   ├── MLX/
│   │   └── VLLM/
│   ├── Models/                  # AIModel, EngineKind, ScanConfiguration, AppPreferencesModel
│   ├── Services/
│   │   ├── Scanner/             # DirectoryModelScanner, ModelScannerService, FileWatcherService
│   │   ├── Deletion/            # ModelDeletionStrategy + LMStudio impl
│   │   ├── Metadata/            # ModelMetadataExtractor
│   │   ├── Persistence/         # ConfigurationStore, ModelInventoryStore, PreferencesStore
│   │   └── Filesystem/          # FileSystem (thin FileManager wrapper)
│   ├── Statistics/              # ModelStatistics, UsageStats
│   ├── Utilities/               # Formatting, Version
│   ├── ViewModels/              # LibraryViewModel, SettingsViewModel
│   ├── Views/                   # SwiftUI views
│   │   ├── ContentView          # NavigationSplitView
│   │   ├── Sidebar/             # Engine filter
│   │   ├── Browser/             # Model table
│   │   ├── Inspector/           # Model details
│   │   ├── Settings/            # Custom paths
│   │   └── Components/          # DeletionPreviewView
│   ├── Resources/               # Info.plist
│   ├── Assets.xcassets/         # App Icon
│   └── Tests/                   # Unit tests (via SwiftPM)
├── AIModelManager.xcodeproj/    # Xcode project
├── Package.swift                # SwiftPM manifest (CLI builds, CI)
├── scripts/                     # Release automation
├── packaging/                   # Distribution packages
│   └── homebrew/                # Homebrew Cask template
├── docs/                        # Branding and design resources
├── .github/workflows/           # CI/CD pipelines
├── .github/export-options.plist # Export options for notarization
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

---

## Development

### How Scanners Work

`DirectoryModelScanner` walks directories, uses `ModelMetadataExtractor` to create `AIModel` instances with proper display names, grouping keys, and deletion locations, then deduplicates by standardized path.

### How Deletion Works

When a user triggers deletion, the app calls `ModelDeletionStrategy.directoriesToDelete(for:)` to get the list of directories to remove. The LM Studio strategy also locates the matching hub cache directory. The app shows a preview, then removes directories on confirmation.

### How to Add a New Metadata Extractor

Extend `ModelMetadataExtractor` with new static methods for `displayName(for:)`, `groupingKey(for:)`, and `deletionLocation(for:)` to handle custom path layouts.

---

## Releases

Releases are automated via GitHub Actions.

### Creating a Release

```bash
# Tag and push
git tag v1.0.0
git push origin v1.0.0
```

The [release workflow](.github/workflows/release.yml) will:
1. Archive the app with `xcodebuild archive`
2. Export the `.app` bundle
3. Create `AIModelManager.zip` with `ditto` (preserves metadata)
4. Generate `SHA256SUMS` and `SHA256SUMS.txt`
5. Publish a GitHub Release with all artifacts

### Release Artifacts

- `AIModelManager.zip` — Application bundle
- `SHA256SUMS` — SHA-256 checksum
- `SHA256SUMS.txt` — SHA-256 checksum (alternate format)
- Auto-generated release notes

### Manual Build

```bash
# Build release archive
scripts/build_release.sh

# Package into ZIP
scripts/package_app.sh /tmp/AIModelManager/AIModelManager.app /tmp

# Generate checksums
scripts/generate_checksums.sh /tmp
```

---

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.
