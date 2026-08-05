#!/usr/bin/env bash
# Sign the built .app with a Developer ID certificate and notarize it with Apple.
#
# This produces an app that installs cleanly on any Mac, without users having
# to right-click → Open on first launch. It is NOT required for the App Store
# flow (that uses `3rd Party Mac Developer` identities instead).
#
# Required env vars:
#   DEVELOPER_ID_APPLICATION   Signing identity, e.g.
#                              "Developer ID Application: Your Name (ABCDE12345)"
#   APPLE_ID                   Your Apple ID email.
#   APPLE_ID_PASSWORD          App-specific password (appleid.apple.com → Sign-in and Security).
#   APPLE_TEAM_ID              10-char Apple team ID.
#
# Usage:
#   scripts/sign-notarize.sh   # signs build/MultiTime.app in place, notarizes,
#                              # then staples the ticket to the bundle.

set -euo pipefail

cd "$(dirname "$0")/.."

: "${DEVELOPER_ID_APPLICATION:?Set DEVELOPER_ID_APPLICATION to your Developer ID Application identity}"
: "${APPLE_ID:?Set APPLE_ID}"
: "${APPLE_ID_PASSWORD:?Set APPLE_ID_PASSWORD (app-specific password)}"
: "${APPLE_TEAM_ID:?Set APPLE_TEAM_ID}"

APP_NAME="MultiTime"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"

if [[ ! -d "${APP_DIR}" ]]; then
    echo "✗ ${APP_DIR} not found. Run scripts/build-app.sh first."
    exit 1
fi

echo "▶ Re-signing with Developer ID…"
codesign --force --deep --timestamp \
    --sign "${DEVELOPER_ID_APPLICATION}" \
    --entitlements Resources/MultiTime.entitlements \
    --options runtime \
    "${APP_DIR}"

codesign --verify --strict --deep --verbose=2 "${APP_DIR}"

echo "▶ Zipping for notarization…"
ZIP_PATH="${BUILD_DIR}/${APP_NAME}-notarize.zip"
rm -f "${ZIP_PATH}"
ditto -c -k --keepParent "${APP_DIR}" "${ZIP_PATH}"

echo "▶ Submitting to Apple notary service…"
xcrun notarytool submit "${ZIP_PATH}" \
    --apple-id "${APPLE_ID}" \
    --password "${APPLE_ID_PASSWORD}" \
    --team-id "${APPLE_TEAM_ID}" \
    --wait

echo "▶ Stapling ticket…"
xcrun stapler staple "${APP_DIR}"
xcrun stapler validate "${APP_DIR}"

rm -f "${ZIP_PATH}"
echo "✓ Signed, notarized, and stapled ${APP_DIR}"
