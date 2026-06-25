#!/bin/bash
set -euo pipefail

DIR="${1:-/tmp}"
cd "$DIR"

echo "==> Generating checksums..."
shasum -a 256 AIModelManager.zip > SHA256SUMS
shasum -a 256 AIModelManager.zip > SHA256SUMS.txt

echo "==> SHA256: $(cut -d' ' -f1 < SHA256SUMS)"
