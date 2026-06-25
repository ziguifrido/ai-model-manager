# Contributing

## Code Style

- Follow Swift API Design Guidelines.
- Use Swift 6 features (strict concurrency, `@Observable`).
- Avoid third-party dependencies; prefer Apple frameworks and stdlib.
- Keep changes minimal and root-cause focused.
- Use `ponytail:` comments for deliberate simplifications.

## Branch Strategy

- `main` — stable, release-ready.
- Feature branches: `feature/<short-description>`.
- Fix branches: `fix/<short-description>`.

## Pull Request Workflow

1. Open a PR against `main`.
2. Ensure the build passes (`xcodebuild build` and `swift test`).
3. Keep PRs focused on a single concern.
4. Update `CHANGELOG.md` if the change is user-facing.

## Adding a New Engine

1. Create a scanner in `AIModelManager/Engines/<EngineName>/` conforming to `ModelScanner`.
2. Add default scan roots in `EnginePaths.swift`.
3. Register the scanner in `AppContainer.live()`.
4. Add the engine to `EngineKind` enum.

## Development

```bash
# Open in Xcode
open AIModelManager.xcodeproj

# Run tests via CLI
swift test
```

## Releasing

See [RELEASES.md](RELEASES.md) for the release process.
