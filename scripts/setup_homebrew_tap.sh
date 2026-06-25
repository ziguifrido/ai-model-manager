#!/bin/bash
set -euo pipefail

# ------------------------------------------------------------------
# setup_homebrew_tap.sh — Initialize and publish to Homebrew tap repo
#
# Creates the homebrew-ai-model-manager repository (if it doesn't exist),
# checks out the repo, places the Cask formula, commits, and pushes.
#
# Prerequisites:
#   - gh (GitHub CLI) installed and authenticated
#   - Write access to ziguifrido/homebrew-ai-model-manager
#   - A recent release ZIP with checksums
#
# Usage:
#   ./scripts/setup_homebrew_tap.sh [version] [sha256]
#
# Examples:
#   ./scripts/setup_homebrew_tap.sh 0.1.0 abc123...
#   ./scripts/setup_homebrew_tap.sh 0.1.0 "$(shasum -a 256 /tmp/AIModelManager.zip | awk '{print $1}')"
# ------------------------------------------------------------------

VERSION="${1:-}"
SHA256="${2:-}"

if [ -z "$VERSION" ] || [ -z "$SHA256" ]; then
    echo "Usage: $0 <version> <sha256>"
    echo ""
    echo "  version — Semantic version (e.g. 0.1.0)"
    echo "  sha256  — SHA256 checksum of the release ZIP"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TAP_DIR="/tmp/homebrew-ai-model-manager"
FORMULA="ai-model-manager.rb"

# ---- Clean up any previous checkout ----
rm -rf "$TAP_DIR"

echo "==> Cloning tap repository..."

# If repo doesn't exist, gh will return non-zero; we create it
gh repo view ziguifrido/homebrew-ai-model-manager &>/dev/null || {
    echo "==> Repo not found. Creating ziguifrido/homebrew-ai-model-manager..."
    gh repo create ziguifrido/homebrew-ai-model-manager --public --description "Homebrew tap for AI Model Manager"
    # New repos have no default branch yet; we initialize
    mkdir -p "$TAP_DIR"
    cd "$TAP_DIR"
    git init
    git checkout -b main
    git remote add origin https://github.com/ziguifrido/homebrew-ai-model-manager.git
}

# Clone (or fetch if we just created it)
if [ ! -d "$TAP_DIR/.git" ]; then
    gh repo clone ziguifrido/homebrew-ai-model-manager "$TAP_DIR"
fi

cd "$TAP_DIR"

# Ensure Casks directory exists
mkdir -p Casks

# Generate the formula from template
sed -e "s/{{VERSION}}/$VERSION/g" \
    -e "s/{{SHA256}}/$SHA256/g" \
    "$REPO_DIR/packaging/homebrew/ai-model-manager.rb.template" \
    > "Casks/$FORMULA"

echo "==> Formula written to Casks/$FORMULA"

git add "Casks/$FORMULA"

if git diff --cached --quiet; then
    echo "==> No changes to commit."
else
    git commit -m "Update ai-model-manager to v$VERSION"
    git push origin main
    echo "==> Pushed! Users can now install:"
    echo "    brew tap ziguifrido/ai-model-manager"
    echo "    brew install --cask ai-model-manager"
fi
