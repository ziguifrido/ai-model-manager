#!/bin/bash
set -euo pipefail

PROJECT="AIModelManager.xcodeproj"
SCHEME="AIModelManagerApp"
CONFIGURATION="Release"
ARCHIVE_PATH="/tmp/AIModelManager.xcarchive"

echo "==> Archiving $SCHEME ($CONFIGURATION)..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS"

echo "==> Archive: $ARCHIVE_PATH"
echo "==> .app bundle: $ARCHIVE_PATH/Products/Applications/AI Model Manager.app"

echo ""
echo "To create a release ZIP:"
echo "  ditto -c -k --sequesterRsrc --keepParent \\"
echo '    "$ARCHIVE_PATH/Products/Applications/AI Model Manager.app" \\'
echo "    /tmp/AIModelManager.zip"
