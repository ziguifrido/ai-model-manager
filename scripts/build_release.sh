#!/bin/bash
set -euo pipefail

PROJECT="AIModelManager.xcodeproj"
SCHEME="AIModelManagerApp"
CONFIGURATION="Release"
ARCHIVE_PATH="/tmp/AIModelManager.xcarchive"
EXPORT_PATH="/tmp/AIModelManager"

echo "==> Archiving $SCHEME ($CONFIGURATION)..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS"

echo "==> Exporting .app..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist .github/export-options.plist

echo "==> Archive: $ARCHIVE_PATH"
echo "==> .app bundle: $EXPORT_PATH/AIModelManager.app"
