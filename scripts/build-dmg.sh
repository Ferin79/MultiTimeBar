#!/usr/bin/env bash
# Package MultiTimeBar.app into a distributable .dmg.
#
# Usage:
#   scripts/build-dmg.sh                    # produce build/MultiTimeBar-<version>.dmg
#   VERSION=1.2.3 scripts/build-dmg.sh      # override version tag on the filename
#
# Requires:
#   • A prior successful run of scripts/build-app.sh (or scripts/archive-appstore.sh).
#   • `create-dmg` (install via `brew install create-dmg`) — falls back to
#     a plain `hdiutil` image if create-dmg is unavailable.

set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="MultiTimeBar"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
ICON_PATH="${BUILD_DIR}/icon/AppIcon.icns"
VERSION="${VERSION:-$(defaults read "$PWD/${APP_DIR}/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "1.0.0")}"
DMG_PATH="${BUILD_DIR}/${APP_NAME}-${VERSION}.dmg"

if [[ ! -d "${APP_DIR}" ]]; then
    echo "✗ ${APP_DIR} not found. Run scripts/build-app.sh first."
    exit 1
fi

# Detect whether the app has an embedded notarization ticket. Skip the
# quarantine-bypass README when it does — those users won't see the warning.
IS_NOTARIZED=0
if xcrun stapler validate "${APP_DIR}" >/dev/null 2>&1; then
    IS_NOTARIZED=1
fi

STAGING=$(mktemp -d)
trap 'rm -rf "${STAGING}"' EXIT
cp -R "${APP_DIR}" "${STAGING}/"

if [[ "${IS_NOTARIZED}" == "0" ]]; then
    cat > "${STAGING}/First-launch instructions.txt" <<'TXT'
MultiTimeBar is open source and distributed without an Apple Developer
signature. macOS Gatekeeper will show a scary "cannot verify" warning the
first time you open it. This is normal — here is how to get past it once:

  1. Drag MultiTimeBar.app into your Applications folder.
  2. In Finder, right-click MultiTimeBar.app → Open.
  3. Click "Open" in the confirmation dialog.

macOS will remember this choice, and double-click will work from then on.

Alternative (Terminal):
  xattr -dr com.apple.quarantine /Applications/MultiTimeBar.app

Full source code: see the GitHub repository this DMG came from.
TXT
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
        "${STAGING}"
else
    echo "▶ create-dmg not installed — falling back to plain hdiutil image."
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
