#!/bin/bash
set -euo pipefail
umask 077
cd "$(dirname "$0")/.."
[[ "$(uname -s)" == Darwin && "$(uname -m)" == arm64 ]] || { echo 'Requires Apple Silicon macOS 15+.' >&2; exit 1; }
version="${1:-1}" short="${2:-1}"
[[ $# -le 2 && "$version" =~ ^[1-9][0-9]{0,5}$ && "$short" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]] || { echo 'Usage: build.sh [positive build number, 1–6 digits] [version, such as 1]' >&2; exit 2; }
mkdir -p .build
stage="$(mktemp -d .build/stage.XXXXXX)"
trap 'rm -rf -- "$stage"' EXIT
bundle="$stage/Ultrahound.app"
mkdir -p "$bundle/Contents/MacOS" "$bundle/Contents/Resources"
cp app/AppIcon.icns "$bundle/Contents/Resources/AppIcon.icns"
cp app/LogoTemplate.png "$bundle/Contents/Resources/LogoTemplate.png"
for folder in app/*.lproj; do if [[ -d "$folder" ]]; then cp -R "$folder" "$bundle/Contents/Resources/"; fi; done
cat > "$bundle/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>com.ultrahound.app</string>
<key>CFBundleName</key><string>Ultrahound</string>
<key>CFBundleDevelopmentRegion</key><string>en</string>
<key>CFBundleLocalizations</key><array><string>en</string><string>ja</string><string>de</string><string>fr</string><string>es</string><string>zh-Hans</string><string>pt-BR</string></array>
<key>CFBundleExecutable</key><string>Ultrahound</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleURLTypes</key><array><dict><key>CFBundleURLName</key><string>com.ultrahound.app</string><key>CFBundleURLSchemes</key><array><string>ultrahound</string></array></dict></array>
<key>CFBundleShortVersionString</key><string>$short</string>
<key>CFBundleVersion</key><string>$version</string>
<key>LSMinimumSystemVersion</key><string>15.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
<key>NSAppTransportSecurity</key><dict><key>NSAllowsLocalNetworking</key><true/></dict>
<key>NSAppleEventsUsageDescription</key><string>Ultrahound sends Empty Trash to Finder, Dark Mode to System Events, and Sleep, Restart, Shut Down, and Log Out to the login window.</string>
<key>NSHumanReadableCopyright</key><string>© 2026 moneuron</string>
</dict></plist>
PLIST
sources=()
for source in app/*.m core/*.m core/*.c; do
 [[ "$source" == app/SHUpdater.m || "$source" == core/SHEmoji.m || "$source" == core/SHUpdate.m ]] || sources+=("$source")
done
/usr/bin/time -lp xcrun clang -arch arm64 -fobjc-arc -fmodules -O2 -Wall -Wextra -Werror \
 -mmacosx-version-min=15.0 -fmodules-cache-path=.build/module-cache -Iapp -Icore \
 "${sources[@]}" -framework AppKit -framework Carbon -framework CoreAudio -framework CoreServices -framework CoreText -framework IOKit -framework Quartz -framework Security -framework ServiceManagement -lsqlite3 \
 -o "$bundle/Contents/MacOS/Ultrahound" 2> "$stage/build-metrics.txt" || { cat "$stage/build-metrics.txt" >&2; exit 1; }
plutil -lint "$bundle/Contents/Info.plist"
# macOS keeps privacy permissions (Documents, Accessibility) for a signature whose certificate stays the same across builds.
# The project certificate "Superhound" is used when it is in the keychain; other builds use an ad-hoc signature, which macOS treats as a new app each time.
identity="$(security find-identity -p codesigning | awk '/"Superhound"/{print $2; exit}')"
codesign --force --sign "${identity:--}" --timestamp=none "$bundle"
codesign --verify --strict "$bundle"
# Only replace this script's build output after successful compile/signing.
if [[ -e .build/Ultrahound.app ]]; then mv .build/Ultrahound.app "$stage/previous.app"; fi
mv "$bundle" .build/Ultrahound.app
cp "$stage/build-metrics.txt" .build/build-metrics.txt
cat .build/build-metrics.txt
echo "Built: $(pwd)/.build/Ultrahound.app"
