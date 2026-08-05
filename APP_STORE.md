# Mac App Store Submission Checklist

Everything below is required by App Store Connect for a Mac app. Items marked
**(automated)** are handled by `scripts/build-app.sh` and
`scripts/archive-appstore.sh`. Items marked **(manual)** must be done in App
Store Connect or the Apple Developer portal.

## Prerequisites (manual)

1. **Apple Developer Program membership** ($99/yr) — https://developer.apple.com/programs/
2. **Team ID** — visible at https://developer.apple.com/account (10-char string).
3. **App Store Connect app record** — https://appstoreconnect.apple.com
   - **Bundle ID**: `com.multitime.menubar` (or your own — remember to update
     `BUNDLE_ID` in both `scripts/build-app.sh` and `scripts/archive-appstore.sh`).
   - **SKU**: `multitime-macos`
   - **Primary language**: English (U.S.)
   - **Category**: Productivity (secondary: Utilities)
4. **Certificates** in Keychain Access:
   - `3rd Party Mac Developer Application: <You> (<TeamID>)`
   - `3rd Party Mac Developer Installer: <You> (<TeamID>)`
5. **Provisioning profile** for the app, downloaded to
   `~/Library/MobileDevice/Provisioning Profiles/`.

## Assets (automated)

The build pipeline produces:

- `build/MultiTime.app` — signed, sandboxed application bundle.
- `build/icon/AppIcon.icns` — 10-size icon set embedded in the app.
- `build/icon/AppIcon-1024.png` — 1024×1024 master icon required for the App
  Store listing (upload manually in App Store Connect → App Information).
- `build/MultiTime.pkg` — signed installer package for upload.

## Metadata (paste into App Store Connect)

All copy lives under `metadata/`:

| Field | File |
|---|---|
| App name | [metadata/en-US/name.txt](metadata/en-US/name.txt) |
| Subtitle | [metadata/en-US/subtitle.txt](metadata/en-US/subtitle.txt) |
| Description | [metadata/en-US/description.txt](metadata/en-US/description.txt) |
| Keywords | [metadata/en-US/keywords.txt](metadata/en-US/keywords.txt) |
| Promotional text | [metadata/en-US/promotional_text.txt](metadata/en-US/promotional_text.txt) |
| Release notes (What's New) | [metadata/en-US/release_notes.txt](metadata/en-US/release_notes.txt) |
| Marketing URL | [metadata/en-US/marketing_url.txt](metadata/en-US/marketing_url.txt) |
| Support URL | [metadata/en-US/support_url.txt](metadata/en-US/support_url.txt) |
| Privacy policy URL | [metadata/en-US/privacy_url.txt](metadata/en-US/privacy_url.txt) |
| Copyright | [metadata/copyright.txt](metadata/copyright.txt) |
| Age rating | [metadata/age_rating.txt](metadata/age_rating.txt) |
| Primary category | [metadata/primary_category.txt](metadata/primary_category.txt) |
| Secondary category | [metadata/secondary_category.txt](metadata/secondary_category.txt) |

The three URL files already point at [github.com/Ferin79/MultiTimeBar](https://github.com/Ferin79/MultiTimeBar).

## Screenshots (manual)

App Store Connect requires macOS screenshots at **2880×1800 or 2560×1600**.
Take them with `⌘⇧5` at your Mac's native resolution and upload three to five
covering:

1. The menu bar strip with several clocks.
2. The Settings window showing city search and the clock list.
3. The Time Travel planner.
4. Light + dark appearance variants (optional but recommended).

## Privacy nutrition label (manual)

In App Store Connect → App Privacy, answer **"No, we do not collect data from
this app."** The `PRIVACY.md` file in this repo backs that up and is what the
`privacy_url.txt` link points to.

## Encryption declaration (manual)

MultiTime does not use encryption. In App Store Connect → Encryption Export
Compliance, select **"No, my app does not use encryption."** — this is the
answer that matches this codebase.

## Build and upload

Set the required environment variables and run the archive script:

```sh
export TEAM_ID="ABCDE12345"
export DIST_APP_IDENTITY="3rd Party Mac Developer Application: Your Name (ABCDE12345)"
export DIST_INSTALLER_IDENTITY="3rd Party Mac Developer Installer: Your Name (ABCDE12345)"
export PROVISIONING_PROFILE="$HOME/Library/MobileDevice/Provisioning Profiles/MultiTime.provisionprofile"

# Optional — enables `--upload`
export ASC_API_KEY_ID="XXXXXXXXXX"
export ASC_API_ISSUER_ID="00000000-0000-0000-0000-000000000000"

# Build a signed .pkg into build/MultiTime.pkg
./scripts/archive-appstore.sh

# Or build and immediately upload to App Store Connect
./scripts/archive-appstore.sh --upload
```

Once uploaded, the build appears in App Store Connect within ~15 minutes.
Attach the metadata, screenshots, and pricing tier, then submit for review.

## Version bumps

For every submission after the first:

- Increment `VERSION` (marketing version, e.g. `1.0.1`) in
  [scripts/build-app.sh](scripts/build-app.sh) — this maps to
  `CFBundleShortVersionString`.
- Increment `BUILD_NUMBER` (must be strictly greater than the last uploaded
  build) — this maps to `CFBundleVersion`.
- Update [metadata/en-US/release_notes.txt](metadata/en-US/release_notes.txt).

## Known reviewer-guideline gotchas for menu bar apps

- App Store review sometimes flags apps whose main UI is only a menu bar item.
  Explain in the App Review notes that MultiTime is intentionally a
  **status bar / menu bar utility** and that all functionality is reachable
  from the menu bar icon → click.
- Because the app has `LSUIElement = YES` and no Dock icon, reviewers will
  need to know how to open the Settings window: **click the clock icon in the
  menu bar → click "Settings…"**. Include this in the "Notes for the Review
  Team" field on the submission form.
