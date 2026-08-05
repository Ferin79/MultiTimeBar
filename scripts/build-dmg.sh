#!/usr/bin/env bash
# Package MultiTime.app into a distributable .dmg.
#
# Usage:
#   scripts/build-dmg.sh                    # produce build/MultiTime-<version>.dmg
#   VERSION=1.2.3 scripts/build-dmg.sh      # override version tag on the filename
#
# Requires:
#   • A prior successful run of scripts/build-app.sh (or scripts/archive-appstore.sh).
#   • `create-dmg` (install via `brew install create-dmg`) — falls back to
#     a plain `hdiutil` image if create-dmg is unavailable.

set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="MultiTime"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
ICON_PATH="${BUILD_DIR}/icon/AppIcon.icns"
VERSION="${VERSION:-$(defaults read "$PWD/${APP_DIR}/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")}"
DMG_PATH="${BUILD_DIR}/${APP_NAME}-${VERSION}.dmg"

if [[ ! -d "${APP_DIR}" ]]; then
    echo "✗ ${APP_DIR} not found. Run scripts/build-app.sh first."
    exit 1
fi

rm -f "${DMG_PATH}"

if command -v create-dmg >/dev/null 2>&1; then
    echo "▶ Building DMG with create-dmg…"
    create-dmg \
        --volname "${APP_NAME} ${VERSION}" \
        --volicon "${ICON_PATH}" \
        --window-pos 200 120 \
        --window-size 620 400 \
        --icon-size 110 \
        --icon "${APP_NAME}.app" 160 200 \
        --hide-extension "${APP_NAME}.app" \
        --app-drop-link 460 200 \
        --no-internet-enable \
        "${DMG_PATH}" \
        "${APP_DIR}"
else
    echo "▶ create-dmg not installed — falling back to plain hdiutil image."
    STAGING=$(mktemp -d)
    trap 'rm -rf "${STAGING}"' EXIT
    cp -R "${APP_DIR}" "${STAGING}/"
    ln -s /Applications "${STAGING}/Applications"
    hdiutil create \
        -volname "${APP_NAME} ${VERSION}" \
        -srcfolder "${STAGING}" \
        -ov -format UDZO \
        "${DMG_PATH}"
fi

echo "▶ Computing checksum…"
shasum -a 256 "${DMG_PATH}" | tee "${DMG_PATH}.sha256"

echo "✓ ${DMG_PATH}"
