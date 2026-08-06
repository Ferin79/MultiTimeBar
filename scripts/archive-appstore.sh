#!/usr/bin/env bash
# Sign, package, and (optionally) upload MultiTimeBar to App Store Connect.
#
# Prerequisites:
#   1. Apple Developer Program membership.
#   2. A Mac App Distribution certificate + Mac Installer Distribution
#      certificate installed in Keychain Access.
#   3. A provisioning profile for the app on App Store Connect (auto-generated
#      when you create the app record — download it and place it at
#      ~/Library/MobileDevice/Provisioning Profiles/).
#   4. An App Store Connect API key stored in ~/.appstoreconnect/private_keys/
#      (see https://appstoreconnect.apple.com/access/api).
#
# Environment variables (required):
#   TEAM_ID                     Your 10-char Apple Team ID.
#   DIST_APP_IDENTITY           Signing identity name for the .app,
#                               e.g. "3rd Party Mac Developer Application: You (ABCDE12345)".
#   DIST_INSTALLER_IDENTITY     Signing identity name for the .pkg,
#                               e.g. "3rd Party Mac Developer Installer: You (ABCDE12345)".
#   PROVISIONING_PROFILE        Path to the .provisionprofile for MultiTimeBar.
#
# Environment variables (optional):
#   ASC_API_KEY_ID              App Store Connect API key ID (enables `--upload`).
#   ASC_API_ISSUER_ID           App Store Connect API issuer ID.
#
# Usage:
#   scripts/archive-appstore.sh              # produce build/MultiTimeBar.pkg
#   scripts/archive-appstore.sh --upload     # produce and upload the .pkg

set -euo pipefail

cd "$(dirname "$0")/.."

: "${TEAM_ID:?Set TEAM_ID to your Apple Developer team ID}"
: "${DIST_APP_IDENTITY:?Set DIST_APP_IDENTITY (see script header)}"
: "${DIST_INSTALLER_IDENTITY:?Set DIST_INSTALLER_IDENTITY (see script header)}"
: "${PROVISIONING_PROFILE:?Set PROVISIONING_PROFILE to the .provisionprofile path}"

APP_NAME="MultiTimeBar"
BUILD_DIR="build"
APP_DIR="${BUILD_DIR}/${APP_NAME}.app"
PKG_PATH="${BUILD_DIR}/${APP_NAME}.pkg"
EMBEDDED_PROFILE="${APP_DIR}/Contents/embedded.provisionprofile"

# 1) Build the app (this regenerates the icon and Info.plist).
./scripts/build-app.sh

# 2) Embed the provisioning profile, then strip the download quarantine
#    xattr that App Store validation refuses to accept.
cp "${PROVISIONING_PROFILE}" "${EMBEDDED_PROFILE}"
xattr -cr "${APP_DIR}"

# 3) Re-sign with the distribution certificate + sandbox entitlements.
echo "▶ Signing with distribution identity…"
codesign --force --deep --timestamp \
    --sign "${DIST_APP_IDENTITY}" \
    --entitlements Resources/MultiTimeBar.entitlements \
    --options runtime \
    "${APP_DIR}"

echo "▶ Verifying signature…"
codesign --verify --strict --deep --verbose=2 "${APP_DIR}"
codesign -d --entitlements - --xml "${APP_DIR}" 2>/dev/null | \
    plutil -convert xml1 -o - - | grep -E "application-identifier|team-identifier|app-sandbox" || true
spctl --assess --type execute --verbose=4 "${APP_DIR}" || true

# 4) Package as an installer .pkg.
echo "▶ Building installer package…"
productbuild --component "${APP_DIR}" /Applications \
    --sign "${DIST_INSTALLER_IDENTITY}" \
    "${PKG_PATH}"

echo "✓ Signed package at ${PKG_PATH}"

if [[ "${1:-}" == "--upload" ]]; then
    : "${ASC_API_KEY_ID:?Set ASC_API_KEY_ID to upload}"
    : "${ASC_API_ISSUER_ID:?Set ASC_API_ISSUER_ID to upload}"
    echo "▶ Uploading to App Store Connect…"
    xcrun altool --upload-app \
        --type macos \
        --file "${PKG_PATH}" \
        --apiKey "${ASC_API_KEY_ID}" \
        --apiIssuer "${ASC_API_ISSUER_ID}"
    echo "✓ Uploaded"
fi
