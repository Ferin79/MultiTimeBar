#!/usr/bin/env bash
# Build MultiTimeBar as a proper .app bundle (menu-bar-only, no Dock icon).
#
# Usage:
#   scripts/build-app.sh              # release build → ./build/MultiTimeBar.app
#   scripts/build-app.sh --run        # build then launch
#
# For App Store submission, see scripts/archive-appstore.sh instead — it
# re-signs and packages the same sources with your distribution certificate.
#
# Requires: Xcode command-line tools (`swift build`, `iconutil`, `codesign`).

set -euo pipefail

cd "$(dirname "$0")/.."

APP_NAME="MultiTimeBar"
BUNDLE_ID="com.ferin79.multitimebar"
VERSION="1.0.0"
BUILD_NUMBER="3"
CATEGORY="public.app-category.productivity"
COPYRIGHT="© 2026 MultiTimeBar contributors. Released under the MIT License."
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
ICON_DIR="${BUILD_DIR}/icon"

# Static source files that get copied verbatim (or with a plist-key patch) into
# the app bundle. Keeping them out of the script means you can edit them with
# proper syntax highlighting and diff them in review.
SRC_INFO_PLIST="Resources/Info.plist"
SRC_XCASSETS="Resources/Assets.xcassets"

echo "▶ Generating app icon…"
mkdir -p "${ICON_DIR}"
swift scripts/generate-icon.swift "${ICON_DIR}" >/dev/null

echo "▶ Building asset catalog (required for App Store)…"
XCASSETS_DIR="${BUILD_DIR}/Assets.xcassets"
APPICONSET_DIR="${XCASSETS_DIR}/AppIcon.appiconset"
rm -rf "${XCASSETS_DIR}"
mkdir -p "${APPICONSET_DIR}"

# Start from the checked-in asset catalog (Contents.json files) and drop in
# the freshly generated PNGs next to the AppIcon manifest.
cp "${SRC_XCASSETS}/Contents.json" "${XCASSETS_DIR}/Contents.json"
cp "${SRC_XCASSETS}/AppIcon.appiconset/Contents.json" "${APPICONSET_DIR}/Contents.json"
cp "${ICON_DIR}/AppIcon.iconset"/icon_*.png "${APPICONSET_DIR}/"

CAR_OUT="${BUILD_DIR}/actool-out"
rm -rf "${CAR_OUT}"
mkdir -p "${CAR_OUT}"

# Prefer the developer-selected actool; fall back to Xcode.app if command-line
# tools are still the active selection.
ACTOOL="$(xcrun --find actool 2>/dev/null || true)"
if [[ -z "${ACTOOL}" && -x /Applications/Xcode.app/Contents/Developer/usr/bin/actool ]]; then
    ACTOOL=/Applications/Xcode.app/Contents/Developer/usr/bin/actool
fi
if [[ -z "${ACTOOL}" ]]; then
    echo "✗ Cannot find actool. Install Xcode.app or run: sudo xcode-select --switch /Applications/Xcode.app"
    exit 1
fi

"${ACTOOL}" \
    --compile "${CAR_OUT}" \
    --platform macosx \
    --minimum-deployment-target 13.0 \
    --app-icon AppIcon \
    --output-partial-info-plist "${BUILD_DIR}/actool-partial.plist" \
    --enable-on-demand-resources NO \
    --development-region en \
    "${XCASSETS_DIR}" >/dev/null

echo "▶ Compiling (release)…"
swift build -c release

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
cp "${CAR_OUT}/Assets.car" "${RESOURCES_DIR}/Assets.car"

# Start from the checked-in Info.plist and patch only the values that change
# per release (version + build). Bundle id, category, copyright, and static
# keys are edited in the source file directly.
cp "${SRC_INFO_PLIST}" "${CONTENTS_DIR}/Info.plist"
PB=/usr/libexec/PlistBuddy
"${PB}" -c "Set :CFBundleShortVersionString ${VERSION}" "${CONTENTS_DIR}/Info.plist"
"${PB}" -c "Set :CFBundleVersion ${BUILD_NUMBER}" "${CONTENTS_DIR}/Info.plist"
"${PB}" -c "Set :CFBundleName ${APP_NAME}" "${CONTENTS_DIR}/Info.plist"
"${PB}" -c "Set :CFBundleDisplayName ${APP_NAME}" "${CONTENTS_DIR}/Info.plist"
"${PB}" -c "Set :CFBundleExecutable ${APP_NAME}" "${CONTENTS_DIR}/Info.plist"
"${PB}" -c "Set :CFBundleIdentifier ${BUNDLE_ID}" "${CONTENTS_DIR}/Info.plist"
"${PB}" -c "Set :LSApplicationCategoryType ${CATEGORY}" "${CONTENTS_DIR}/Info.plist"
"${PB}" -c "Set :NSHumanReadableCopyright ${COPYRIGHT}" "${CONTENTS_DIR}/Info.plist"

# Ad-hoc sign with sandbox entitlements so the local dev build behaves like the
# App Store build. Use scripts/archive-appstore.sh for real distribution.
echo "▶ Stripping quarantine attributes…"
xattr -cr "${APP_DIR}"

echo "▶ Ad-hoc signing…"
codesign --force --deep \
    --sign - \
    --entitlements Resources/MultiTimeBar.entitlements \
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
