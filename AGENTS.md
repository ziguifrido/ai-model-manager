# AGENTS

## Project Notes

- App name: `AI Model Manager`
- Platform: macOS 14+
- Stack: Swift 6, SwiftUI, MVVM, SwiftData
- Build: Xcode project (`.xcodeproj`) or SwiftPM
- Distribution: Homebrew Cask

## Project Structure

```text
AIModelManager/         — Main source root (library + app)
  App/                  — @main entry point, @Observable DI container, commands
  Engines/
    Ollama/             — OllamaModelScanner, removeOrphanBlobs()
    LMStudio/           — LMStudioModelScanner, LMStudioDeletionStrategy
    HuggingFace/        — HuggingFaceModelScanner
    MLX/                — MLXModelScanner
    VLLM/               — VLLMModelScanner
    EnginePaths.swift   — Default scan roots per engine
    ModelScanner.swift  — Protocol
  Models/               — AIModel, EngineKind, ScanConfiguration, AppPreferencesModel
  Services/
    Scanner/            — DirectoryModelScanner, ModelScannerService, FileWatcherService
    Deletion/           — ModelDeletionStrategy protocol + LMStudio impl
    Metadata/           — ModelMetadataExtractor (display name, grouping, deletion location)
    Persistence/        — ConfigurationStore (@Observable, JSON-backed), ModelInventoryStore, PreferencesStore (SwiftData actor)
    Filesystem/         — FileSystem (thin wrapper over FileManager)
  Statistics/           — ModelStatistics, UsageStats
  Utilities/            — Formatting (byte count formatter), Version
  ViewModels/           — LibraryViewModel, SettingsViewModel (@Observable)
  Views/
    ContentView         — NavigationSplitView (sidebar → browser → inspector)
    Sidebar/            — SidebarView (engine filter list)
    Browser/            — ModelBrowserView (Table + searchable)
    Inspector/          — ModelInspectorView (detail form)
    Settings/           — SettingsView (per-engine custom paths)
    Components/         — DeletionPreviewView (confirmation sheet)
  Resources/            — Info.plist
  Assets.xcassets/      — App icon assets
  Tests/                — AIModelManagerTests (via SwiftPM `swift test`)
AIModelManager.xcodeproj/ — Xcode project (generated, 38 Swift source files)
```

## Scanner Behavior

- **Ollama** — reads manifest JSON files under `<root>/manifests/`, extracts name/size from manifest. Blob-level GC in `removeOrphanBlobs()`.
- **LM Studio** — scans `models/` subdirectories under each configured root. Deletion also cleans up matching directories under `hub/models/`.
- **HuggingFace** — scans HF cache layout (snapshots/refs/versions), collapses to repo root.
- **MLX** — scans `mlx-models/`, `Models/`, and `.cache/mlx`.
- **vLLM** — scans `.cache/vllm`.

## LM Studio Hub Matching

When deleting an LM Studio model, the strategy walks up the path looking for a sibling `hub/models/` directory. The hub dir name match is bidirectional: the model name may be either a substring of the hub dir name (e.g. flat HF-style `models--publisher--model-name`) or the hub dir name may be a substring of the model name (e.g. base `gemma-3-4b` vs quantized `gemma-3-4b-it-qat-4bit`).

## Commits

Only commit when explicitly requested by the user. Never commit without authorization.

When asked to commit, prefer small, logical commits:
1. Business logic changes (Models, Engines, Services)
2. SwiftUI layer (App, Views, ViewModels)
3. Xcode project
4. Resources and assets (icons, Info.plist)
5. CI/CD, scripts, packaging
6. Documentation (CHANGELOG, README, AGENTS)

## Git Flow

- Use short-lived topic branches for fixes and features.
- Name hotfix branches `hotfix/x.y.z` and feature branches `feature/<slug>`.
- Merge or commit back to the mainline only after the branch is validated.

## Commit Style

- Use conventional commits for local and published history.
- Prefer `fix:`, `feat:`, `docs:`, `chore:`, and `refactor:` prefixes.
- Keep each commit focused on one logical change.

## Versioning

- Follow semantic versioning for release numbers.
- Bump `MAJOR` for breaking changes, `MINOR` for backward-compatible features, and `PATCH` for fixes.
- Keep `README.md` and project marketing version in sync with the release version.

## Working Rule

- Keep changes minimal and root-cause focused.
- Prefer native macOS APIs and shared helpers already in the codebase.
- Use `.xcodeproj` for IDE development; `swift test` for CLI testing.
