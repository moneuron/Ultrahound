# UltraHound

UltraHound is a native macOS launcher and productivity app for finding apps and files, opening settings, calculating and converting values, searching the web, and using clipboard history.

This is a personal-use fork, intended for the author and for sharing with friends and acquaintances. It is not an official release of the upstream project, and it has no commercial support or maintenance commitment.

## Features

- Search apps and selected folders by name, with typo-tolerant matching.
- Open System Settings panes and run built-in system commands.
- Calculate expressions, convert units, and view alternate colour formats.
- Search the web or open a web address in your browser.
- Keep and search up to 500 copied text items in clipboard history.
- Learn preferred results from what you open.

File search indexes names, not file contents. Emoji search and automatic or manual update checks are not part of this fork.

## Requirements

- Apple Silicon Mac
- macOS 15 or later
- Apple Command Line Tools

## Build and install

Clone this repository, then build the app:

```sh
xcode-select --install # If the Command Line Tools are not already installed
git clone https://github.com/moneuron/Ultrahound.git
cd Ultrahound
scripts/test.sh
scripts/build.sh
```

The build script creates an app bundle in `.build/`. Copy it to Applications as `UltraHound.app`:

```sh
mkdir -p ~/Applications
ditto .build/Ultrahound.app ~/Applications/UltraHound.app
open ~/Applications/UltraHound.app
```

Quit UltraHound before replacing an existing copy. Local builds use the configured signing identity when available, or an ad-hoc signature otherwise; they are not notarized. macOS may ask for permissions again after a rebuild.

On first launch, the Welcome window lets you set the search shortcut, add folders, and try a search. Apps are indexed automatically. Add folders in **Settings…** to search your files; allow access when macOS asks.

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| ⌘Space | Open the search panel (unless changed in Settings) |
| ⌥⌘V | Open clipboard history |
| ↑ / ↓ | Select a result |
| Return | Open, run, copy, or paste the selected result |
| ⌘Return | Show a file in Finder; in clipboard history, copy the item |
| ⌘K | Open the selected result's action menu |
| ⌘Y | Preview a file with Quick Look |
| ⇧⌘C | Copy a file's path |
| Tab or → | Accept inline completion, if enabled in Settings |
| Esc | Close the panel |
| ⌘, | Open Settings |

Click a result to open it. ⌘-click shows a file in Finder; right-click opens its action menu.

## Privacy and data

Search and indexing run on your Mac. UltraHound reads file names, not file contents, and stores its index and clipboard history locally in `~/Library/Application Support/Ultrahound/`.

The app does not check for or download updates. Web searches and addresses are opened by your browser, which makes the relevant network request. The existing license activation/deactivation integration may contact its upstream licensing service with a license key and device identifier.

The clipboard history keeps up to 500 text copies. It skips copies marked private by an app, copies from Keychain Access and Passwords, and text over 100,000 characters. Use **Clear Clipboard History** in the menu to remove saved copies.

## Permissions and troubleshooting

| Permission | Why it may be requested |
|---|---|
| Files and Folders | To search folders you choose |
| Accessibility | To paste a clipboard-history item into the previous app |
| Automation | To run commands that control Finder, System Events, or the login window |

- **A folder or file is missing:** Add the folder in **Settings…**, allow access, and wait for indexing. **Refresh Catalog** rescans selected locations.
- **Clipboard Return copies but does not paste:** Allow UltraHound in **System Settings → Privacy & Security → Accessibility**.
- **A system command is blocked:** Review UltraHound's permission in **System Settings → Privacy & Security → Automation**.
- **A shortcut does not open the panel:** Change it in **Settings…** if another app or macOS already uses it. The Spotlight switch in Settings controls whether ⌘Space is used for UltraHound.

To uninstall, choose the app's uninstall command from its menu bar menu. It removes the app and its local data; files in your selected folders are left untouched.

## Development

The project is Objective-C and C using AppKit, SQLite, and FSEvents, with no third-party build dependencies.

```sh
scripts/test.sh       # Run the Objective-C test suites
scripts/benchmark.sh  # Measure search and catalog performance
tests/install.sh      # Exercise the installer in a temporary location
```

## License and attribution

Copyright (C) 2026 PGHQdev. This personal fork is distributed under the GNU Affero General Public License, version 3. Upstream copyright and attribution notices are retained; see [LICENSE](LICENSE).
