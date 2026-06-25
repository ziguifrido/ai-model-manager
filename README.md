# My AI Models

macOS app that discovers and manages local AI models installed by Ollama, LM Studio, HuggingFace, MLX, and vLLM.

Version: `0.0.1-SNAPSHOT`

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16+ **or** Swift 6.0+ toolchain (for CLI builds)

## Install Locally

```bash
# Clone or navigate to the project root, then build the release binary.
swift build -c release

# The binary is now at:
#   .swift/arm64-apple-macosx/release/AIModelManagerApp
# Run it directly from the terminal, or copy it anywhere on your system.

# To install system-wide (optional):
sudo cp .swift/arm64-apple-macosx/release/AIModelManagerApp /usr/local/bin/my-ai-models
my-ai-models
```

The app is a pure SwiftPM project — no Xcode project file required. Open the repo in Xcode via `File → Open Package` if you prefer the IDE.

## Test

```bash
swift test
```

## Distribute

```bash
# Package into a standalone .app bundle
swift build -c release
mkdir -p "My AI Models.app/Contents/MacOS"
cp .swift/arm64-apple-macosx/release/AIModelManagerApp "My AI Models.app/Contents/MacOS/"
cp -r Sources/AIModelManagerApp/Resources "My AI Models.app/Contents/Resources" 2>/dev/null || true

# The app accesses user home paths under ~/.cache and ~/Library — it does not
# use sandboxing, so no code-signing is strictly required for local use.
# For wider distribution, sign and notarise the .app bundle with Apple Developer
# tools before sharing.
```
