#!/bin/bash
set -euo pipefail

VERSION="${1:-}"
OUTPUT="${2:-/tmp/release_notes.md}"

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version> [output-file]"
    exit 1
fi

cat > "$OUTPUT" << EOF
## $VERSION

### Changes

$(git log --oneline "$(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD" 2>/dev/null || echo "- Initial release.")

### Checksums

\`\`\`
$(cat SHA256SUMS 2>/dev/null || echo "SHA256SUMS available on release assets.")
\`\`\`

### Installation

1. Download \`AIModelManager.zip\` from the release assets.
2. Extract: \`unzip AIModelManager.zip\`
3. Move to Applications: \`mv AIModelManager.app /Applications/\`

Or with Homebrew:

\`\`\`bash
brew tap ziguifrido/ai-model-manager
brew install --cask ai-model-manager
\`\`\`
EOF

echo "==> Release notes written to $OUTPUT"
