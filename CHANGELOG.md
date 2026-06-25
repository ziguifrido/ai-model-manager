# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.2] - 2026-06-25

### Fixed

- Release workflow: skip `xcodebuild -exportArchive` entirely (method deprecated in Xcode 16.4, requires team ID). Package `.app` directly from the archive's `Products/Applications/` directory.

## [0.1.1] - 2026-06-25

### Fixed

- Release export now uses `development` signing method (ad-hoc) instead of `developer-id`, which required a Developer ID certificate not available on CI runners.

## [0.1.0] - 2026-06-25

### Added

- macOS native SwiftUI application with `NavigationSplitView` (sidebar, browser, inspector).
- `@Observable` MVVM architecture using Swift 6 observation.
- Model scanners for Ollama, LM Studio, Hugging Face, MLX, and vLLM.
- Safe deletion with LM Studio hub cache cleanup.
- Model statistics (total count, disk usage, per-engine breakdown).
- Settings view for custom scan paths per engine.
- Search and filter by engine or name.
- Sort by name, size, or engine.
- Deletion preview with size and directory list.
- File watcher stub for incremental scanning.
- SwiftData model for preferences.
- GitHub Actions CI/CD with build, test, and release workflows.
- Homebrew Cask template for distribution.
- Release automation scripts.
- App icon.

### Changed

- Refactored from SwiftPM executable to Xcode project (.xcodeproj).
- Moved all source files under `AIModelManager/` directory.
- `ConfigurationStore` migrated from actor to `@Observable` class.
- Removed `format` and `modifiedAt`/`createdAt`/`lastAccess` fields from `AIModel`.
- LM Studio deletion strategy now uses bidirectional hub name matching.

[0.1.2]: https://github.com/ziguifrido/ai-model-manager/releases/tag/v0.1.2
[0.1.1]: https://github.com/ziguifrido/ai-model-manager/releases/tag/v0.1.1
[0.1.0]: https://github.com/ziguifrido/ai-model-manager/releases/tag/v0.1.0
