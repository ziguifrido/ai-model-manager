#!/bin/bash
set -euo pipefail

APP_PATH="${1:-/tmp/AIModelManager/AIModelManager.app}"
OUTPUT_DIR="${2:-/tmp}"
ZIP_NAME="AIModelManager.zip"

if [ ! -d "$APP_PATH" ]; then
    echo "Error: $APP_PATH not found. Run build_release.sh first."
    exit 1
fi

echo "==> Packaging $APP_PATH into $OUTPUT_DIR/$ZIP_NAME..."
cd "$(dirname "$APP_PATH")"
ditto -c -k --sequesterRsrc --keepParent "$(basename "$APP_PATH")" "$OUTPUT_DIR/$ZIP_NAME"

echo "==> Created $OUTPUT_DIR/$ZIP_NAME"
echo "==> Contents:"
zipinfo -1 "$OUTPUT_DIR/$ZIP_NAME"
