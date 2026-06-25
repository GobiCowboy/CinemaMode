# Cinema Mode for Mac

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-macOS%2014+-blue.svg)](https://developer.apple.com/macos/)

A lightweight macOS menu bar app that dims your screen and hides distractions — so you can focus on what you're watching.

One click. Done.

## What it does

- Hides the menu bar and Dock (on GitHub edition)
- Shows a minimal floating exit button that you can drag anywhere
- Restores your system state exactly as it was when you exit
- Remembers your preferred volume, language, and exit button position

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 16+ or Swift 6.0 toolchain
- Apple Developer account (optional, for code signing)

## Build & Run

### Prerequisites (Swift Package Manager)

```bash
# Clone the repo
git clone https://github.com/<your-username>/CinemaMode.git
cd CinemaMode

# Build and run from source
swift build
./script/build_and_run.sh run
```

### Prerequisites (Xcode)

```bash
# Open the project in Xcode
open CinemaMode.xcodeproj
```

### Build Script Modes

The build script at `script/build_and_run.sh` supports several modes:

```bash
./script/build_and_run.sh run          # Build + run
./script/build_and_run.sh --debug       # Build + launch under lldb
./script/build_and_run.sh --logs         # Build + stream system logs
./script/build_and_run.sh --telemetry    # Build + stream OSLog subsystem
./script/build_and_run.sh --verify       # Build + verify process launches
```

## App Store Release

```bash
# Archive with Xcode (recommended)
xcodebuild archive \
  -project CinemaMode.xcodeproj \
  -scheme CinemaMode \
  -configuration Release \
  -destination 'platform=macOS' \
  -archivePath dist/CinemaMode.xcarchive

# Export for App Store
xcodebuild -exportArchive \
  -archivePath dist/CinemaMode.xcarchive \
  -exportPath dist/AppStoreExport \
  -exportOptionsPlist Config/AppStore/ExportOptions.plist
```

> **Note:** The App Store version (`com.cinemamode.app`) requires an active Apple Developer Program membership. Create your app record on [App Store Connect](https://appstoreconnect.apple.com/) before exporting.

## Distribution Differences

| | GitHub Edition | App Store Edition |
|---|---|---|
| Bundle ID | Development | `com.cinemamode.app` |
| Dock auto-hide | ✅ | ❌ |
| Sandbox | ❌ | ✅ |
| Apple Events | ❌ | ✅ (volume only) |
| Distribution | Code-sign & share | App Store |

## Architecture

```
CinemaMode/                  ← App & UI layer (SwiftUI + AppKit bridge)
├── App/                     ← Application lifecycle, menu bar entry
├── Services/                ← System UI controls (floating panel, settings, presentation)
└── Views/                   ← SwiftUI views

CinemaModeCore/              ← Business logic (pure Swift)
├── Models/                  ← Data models
├── Services/                ← CinemaModeService (state machine)
├── Stores/                  ← PreferencesStore
└── Support/                 ← Errors, logging, localization

Tests/                       ← Unit tests
docs/                        ← Product specs & architecture docs
```

Key design decisions:
- **Pure AppKit for system controls** — menu bar, floating panels, window management
- **SwiftUI for user content** — settings page and exit button
- **State machine** — enter → active → exiting → idle, with recovery on failure
- **LSUIElement** — no Dock icon, menu bar only

## License

[MIT](LICENSE)
