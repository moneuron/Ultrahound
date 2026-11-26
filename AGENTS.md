# Ultrahound

## Project

Ultrahound is a personal-use native macOS launcher for finding apps and files, opening System Settings and built-in commands, quick calculations and conversions, web searches, and clipboard history. It is a personal fork, not an official upstream release or a commercially supported product. It targets Apple Silicon and macOS 15 or later; the Apple Command Line Tools are the only build dependency.

The bundle identifier is `com.ultrahound.app`. Local state is stored in `~/Library/Application Support/Ultrahound/`. Search indexes names, not file contents; apps are scanned automatically and other folders only after the user selects them.

## Current product scope

- The search field has no placeholder. On first use it is empty, showing only the blinking insertion cursor; opening the panel focuses it. Switching between search and clipboard modes clears the field, while reopening the same mode can retain the previous query. An empty query shows no results; it is not a recent-apps view. `SHUsage` learns preferred results for matching queries, rather than suggesting recently used apps.
- Keep the panel minimal, with the intended smooth, Spotlight-like presentation. It is a 600-point-wide dark, translucent panel; preserve its immediate keyboard focus and responsive search. Its height follows the result rows, up to eight rows, while the top edge stays put. Current show/hide and resize code has no explicit animation API; resizing sets the window frame directly. Keep future transitions smooth without delaying input or growth.
- Supporter reminders, the supporter heart/promotion, and their related panel UI are absent. License activation/deactivation code remains; do not conflate it with supporter promotion.
- Emoji and updater implementations/data remain in the repository for now, but are excluded from the shipped app by `scripts/build.sh` (`core/SHEmoji.m`, `core/SHUpdate.m`, and `app/SHUpdater.m`). They are not product features; do not wire them into the app without an explicit product decision. The app does not check for or download updates.

## Branding and version

- The current hound logo artwork is in `docs/media/superhound.png`; `docs/media/logo.png` and `docs/media/logo-dark.png` are the documentation variants. The app resources are `app/AppIcon.icns` (the macOS app icon) and `app/LogoTemplate.png` (a 36×36 template image used in the menu bar and the search-panel footer). The template image is tinted by macOS in the menu bar.
- `scripts/build.sh` copies the prepared ICNS and PNG into the app bundle; it does not generate them. There is no checked-in artwork-generation script. To regenerate the ICNS, export the master artwork at the standard iconset sizes and run `iconutil -c icns AppIcon.iconset -o app/AppIcon.icns`; export the 36×36 transparent template PNG separately.
- The current marketing version is `1`. The About panel displays **Ultrahound**, **Version 1**, and **© 2026 moneuron**. The build script defaults to version `1` and build number `1`; its first argument is the build number and its second is the marketing version.

## Structure

- `app/`: AppKit entry point and integration. `SHAppDelegate` wires the menu bar, shortcuts, welcome/settings windows, library, clipboard, and licensing. `SHSearchPanelController` owns the focused search panel, result presentation, keyboard actions, Quick Look, and clipboard-history mode. `SHSettingsController` and `SHWelcomeController` manage setup and preferences. `SHHotKey`, `SHFolderAccess`, and `SHResultActions` handle shortcuts, selected-folder access, and opening/running results.
- `core/`: UI-independent behavior. `sh_match.c` and `SHSearchSnapshot` match and rank results; `SHQueryController` runs cancellable searches off the main thread; `SHUsage` stores learned query/result preferences. `SHLibrary`, `SHScanner`, `SHCatalog`, and `SHChangeMonitor` scan selected locations, cache entries in SQLite, and react to FSEvents. Other active modules implement answers, web search/address detection, clipboard history, system commands, Spotlight shortcut handling, licensing, and metrics.
- `tests/`: focused Objective-C tests. `scripts/test.sh` checks localization, builds the active suites with AddressSanitizer and UndefinedBehaviorSanitizer, and compares ranking output against `tests/snapshot-equivalence.expected`. It does not run `tests/install.sh`; the emoji and updater tests are not part of this script.
- `scripts/`: build, install, test, release, benchmark, localization, and legacy emoji-data utilities. `docs/` is gitignored except for `docs/media/`; `README.md` is the user-facing project and privacy overview.

## Build, sign, and verify

On Apple Silicon macOS 15 or later with Command Line Tools installed:

```sh
scripts/test.sh
scripts/build.sh [build-number] [version]
codesign --verify --strict .build/Ultrahound.app
```

The app bundle is `.build/Ultrahound.app`. For example, `scripts/build.sh 2 1` produces version `1`, build `2`. The build script compiles the active Objective-C/C sources, writes `Info.plist`, copies localized resources and the app icons, then signs the bundle. It uses a valid signing identity named `Superhound` when available; otherwise it creates an ad-hoc signature. Ad-hoc signing is not Developer ID signing or notarization and macOS may treat it as a different app for privacy permissions. `codesign --verify --strict` checks signature integrity; use `codesign -dv --verbose=2 .build/Ultrahound.app` to inspect the signature details.

`scripts/install.sh .build/Ultrahound.app` verifies the bundle and signature, refuses to replace a running app, and keeps a previous bundle for rollback. `scripts/release.sh` is a separate legacy release flow that requires the `Superhound` identity and still contains upstream publishing references; review and adapt it before using it for an Ultrahound release.

## Maintenance

- Keep changes scoped; match the existing Objective-C/C patterns. Add tests for core behavior changes. Review `tests/snapshot-equivalence.expected` before changing search ranking.
- User-visible strings in `app/` and active `core/` code use `NSLocalizedString`. After text changes, run `python3 -I scripts/strings.py`; run `python3 -I scripts/strings.py --check` or `scripts/test.sh` to validate generated English strings and locale consistency. Keep fixed comparison values separate from translated labels.
- Keep ordinary search and indexing offline. Web requests are made by the chosen browser. The retained license activation/deactivation integration may send the license key and device identifier to its licensing service; do not add unrelated network traffic.
- Clipboard history and licensing data are private local state; never print or expose their contents. Preserve the upstream copyright and attribution notices. This fork is copyright © 2026 moneuron and is distributed under the GNU Affero General Public License, version 3; `LICENSE` contains the license text.
- The search-panel UI has no automated visual test. Do not use full-screen captures; ask the user to inspect visual changes when needed.
