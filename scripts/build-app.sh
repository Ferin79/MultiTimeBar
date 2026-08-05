#!/usr/bin/env bash
# Build MultiTime as a proper .app bundle (menu-bar-only, no Dock icon).
#
# Usage:
#   scripts/build-app.sh              # release build → ./build/MultiTime.app
#   scripts/build-app.sh --run        # build then launch
#
# For App Store submission, see scripts/archive-appstore.sh instead — it
# re-signs and packages the same sources with your distribution certificate.
#
# Requires: Xcode command-line tools (`swift build`, `iconutil`, `codesign`).

set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="MultiTime"
BUNDLE_ID="com.multitime.menubar"
VERSION="1.0.0"
BUILD_NUMBER="1"
CATEGORY="public.app-category.productivity"
COPYRIGHT="© 2026 MultiTime contributors. Released under the MIT License."
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
ICON_DIR="${BUILD_DIR}/icon"

echo "▶ Generating app icon…"
mkdir -p "${ICON_DIR}"
swift scripts/generate-icon.swift "${ICON_DIR}" >/dev/null

echo "▶ Compiling (release)…"
swift build -c release >/dev/null

BIN_PATH=$(swift build -c release --show-bin-path)
EXECUTABLE="${BIN_PATH}/${APP_NAME}"

if [[ ! -x "${EXECUTABLE}" ]]; then
    echo "✗ Executable not found at ${EXECUTABLE}"
    exit 1
fi

echo "▶ Assembling ${APP_DIR}…"
rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"
cp "${EXECUTABLE}" "${MACOS_DIR}/${APP_NAME}"
cp "${ICON_DIR}/AppIcon.icns" "${RESOURCES_DIR}/AppIcon.icns"

cat > "${CONTENTS_DIR}/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${BUILD_NUMBER}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>${CATEGORY}</string>
    <key>NSHumanReadableCopyright</key>
    <string>${COPYRIGHT}</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    <key>NSSupportsSuddenTermination</key>
    <false/>
</dict>
</plist>
PLIST

# Ad-hoc sign with sandbox entitlements so the local dev build behaves like the
# App Store build. Use scripts/archive-appstore.sh for real distribution.
echo "▶ Ad-hoc signing…"
codesign --force --deep \
    --sign - \
    --entitlements Resources/MultiTime.entitlements \
    --options runtime \
    "${APP_DIR}"

# Register with LaunchServices so `open` finds the freshly-built bundle.
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
if [[ -x "${LSREGISTER}" ]]; then
    "${LSREGISTER}" -f "${APP_DIR}" >/dev/null 2>&1 || true
fi

echo "✓ Built ${APP_DIR}"

if [[ "${1:-}" == "--run" ]]; then
    echo "▶ Launching…"
    killall "${APP_NAME}" 2>/dev/null || true
    sleep 0.3
    open "${APP_DIR}"
fi
