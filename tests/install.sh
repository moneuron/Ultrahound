#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
fixture="$(mktemp -d)"
trap 'rm -rf -- "$fixture"' EXIT
export ULTRAHOUND_APPLICATIONS_DIR="$fixture/Applications"
scripts/install.sh .build/Ultrahound.app
[[ -x "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app/Contents/MacOS/Ultrahound" ]]
scripts/install.sh .build/Ultrahound.app
find "$ULTRAHOUND_APPLICATIONS_DIR" -path '*/previous.app/Contents/Info.plist' | read -r backup
mv "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app" "$fixture/valid.app"
mkdir -p "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app/Contents"
cp "$fixture/valid.app/Contents/Info.plist" "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.example.unrelated' "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app/Contents/Info.plist"
if scripts/install.sh .build/Ultrahound.app; then echo 'FAIL: replaced unrelated bundle'; exit 1; fi
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app/Contents/Info.plist")" == com.example.unrelated ]]
rm -rf "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app"
ln -s "$fixture/valid.app" "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app"
if scripts/install.sh .build/Ultrahound.app; then echo 'FAIL: followed destination symlink'; exit 1; fi
[[ -L "$ULTRAHOUND_APPLICATIONS_DIR/Ultrahound.app" ]]
echo 'PASS installer: install, upgrade backup, unrelated identity and symlink rejection'
