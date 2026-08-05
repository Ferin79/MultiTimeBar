# MultiTime

A free, open-source, native macOS menu bar app that shows multiple time zones
with country flags — as an unrestricted alternative to paid multi-clock menu bar
apps. Every feature is available to everyone, forever.

Inspired by the (now unavailable) [`rshin7/MultiTimeInMenuBar`](https://github.com/rshin7/MultiTimeInMenuBar)
project and built to replace paywalled alternatives on the App Store.

## Features

- Multiple time zones side-by-side in the menu bar
- Country flag emojis for at-a-glance identification
- 12/24-hour formats, optional seconds, optional day difference (`+1d`, `-3h`)
- Stack clocks in two rows (**free**, not a paid Pro feature)
- Time Travel planner: drag a slider to see when a meeting lands in every zone
- City search across ~150+ major cities and IANA time zones
- Reorder, rename, and remove clocks
- Launch at login (via `SMAppService`, macOS 13+)
- Data stored locally in `UserDefaults` — no accounts, no telemetry, no network

## Requirements

- macOS 13 (Ventura) or newer
- Swift 5.9 / Xcode 15 or newer

## Build & Run

The project is a Swift Package Manager executable, so you can build and run it
straight from the command line:

```sh
swift run -c release MultiTime
```

Or open the folder in Xcode 15+ (which supports `Package.swift` natively) and
press ⌘R.

Because SwiftPM does not build a full `.app` bundle, the executable calls
`NSApp.setActivationPolicy(.accessory)` at launch so it behaves as a
menu-bar-only app (no Dock icon, no main window). For a signed, distributable
`.app` bundle, wrap the sources in an Xcode app target with `LSUIElement = YES`
in `Info.plist`.

## Project Layout

```
Sources/MultiTime/
├── MultiTimeApp.swift        # @main entry point, MenuBarExtra & scenes
├── Models/
│   ├── Clock.swift           # Codable clock model
│   └── TimezoneDatabase.swift# Curated city → time zone map
├── Stores/
│   ├── AppSettings.swift     # UserDefaults-backed preferences
│   ├── ClockStore.swift      # Persistent list of clocks
│   └── TimeTravelState.swift # Slider-driven "what if" offset
├── Views/
│   ├── MenuBarLabelView.swift    # What renders in the menu bar
│   ├── MenuBarContentView.swift  # Dropdown popover
│   ├── SettingsView.swift        # Settings window (⌘,)
│   ├── AddClockView.swift        # City search + add
│   ├── ClockListView.swift       # Reorder / edit / delete
│   └── TimeTravelView.swift      # Time Travel planner window
└── Utils/
    ├── FlagEmoji.swift       # ISO country code → 🇰🇷 emoji
    └── TimeFormatting.swift  # Shared date/time formatters
```

## Privacy

MultiTime is a pure client-side app. It never makes network requests, never
loads remote resources, and never collects analytics. All settings and clocks
live in `UserDefaults` on your Mac. Full policy in [PRIVACY.md](PRIVACY.md).

## Mac App Store distribution

The repo is ready for App Store submission. See [APP_STORE.md](APP_STORE.md)
for the full checklist. Highlights:

- [scripts/generate-icon.swift](scripts/generate-icon.swift) — procedurally
  renders the icon at every required size and packs it into `AppIcon.icns`.
- [scripts/build-app.sh](scripts/build-app.sh) — produces a sandboxed,
  ad-hoc-signed dev bundle for local testing.
- [scripts/archive-appstore.sh](scripts/archive-appstore.sh) — re-signs with
  your distribution certificate, embeds your provisioning profile, packages
  as a `.pkg`, and optionally uploads to App Store Connect.
- [metadata/](metadata/) — fastlane-style folders with the app name,
  subtitle, description, keywords, and URLs ready to paste into App Store
  Connect.
- [Resources/MultiTime.entitlements](Resources/MultiTime.entitlements) — App
  Sandbox entitlement (required by the Mac App Store).

## GitHub Releases (DMG distribution)

Every push of a `v*` tag triggers
[.github/workflows/release.yml](.github/workflows/release.yml), which:

1. Builds and code-signs the `.app` (Developer ID + notarization when the
   secrets are configured, ad-hoc otherwise).
2. Packages it as `MultiTime-<version>.dmg` via
   [scripts/build-dmg.sh](scripts/build-dmg.sh).
3. Publishes a GitHub Release with the DMG and its SHA-256 checksum attached.

To cut a release locally after pushing your changes:

```sh
git tag v1.0.0
git push origin v1.0.0
```

Optional Developer ID signing + notarization is enabled by adding these
repository secrets in **Settings → Secrets and variables → Actions**:

| Secret | Purpose |
|---|---|
| `DEVELOPER_ID_CERT_P12_BASE64` | Base64 of your `.p12` cert (`base64 -i cert.p12 | pbcopy`). |
| `DEVELOPER_ID_CERT_PASSWORD` | Password used when exporting the `.p12`. |
| `DEVELOPER_ID_APPLICATION` | Exact identity name, e.g. `Developer ID Application: You (ABCDE12345)`. |
| `APPLE_ID` | Your Apple ID email. |
| `APPLE_ID_PASSWORD` | App-specific password from appleid.apple.com. |
| `APPLE_TEAM_ID` | 10-char team ID. |

Without those secrets the workflow still ships an installable DMG; users just
need to right-click the app → **Open** the first time to bypass Gatekeeper.

## License

MIT — see [LICENSE](LICENSE). Contributions are welcome.
