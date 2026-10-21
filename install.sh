#!/usr/bin/env bash
# Installs (or updates) Aventyrs on macOS from the latest GitHub release.
#
#   curl -fsSL https://raw.githubusercontent.com/perlamber/aventyrs-client-release/main/install.sh | bash
#
# Files downloaded with curl don't get macOS's "downloaded from the internet" mark, so the app
# opens without the "Apple could not verify…" warning.
set -euo pipefail

REPO="perlamber/aventyrs-client-release"
APP_NAME="Aventyrs.app"

fail() { echo "Error: $*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || fail "this installer is for macOS. On Windows, see the README."
if [ "$(uname -m)" != "arm64" ]; then
  echo "Warning: this build is for Apple Silicon (M1 or newer) Macs and may not run on Intel Macs." >&2
fi

if pgrep -x Aventyrs >/dev/null 2>&1; then
  fail "Aventyrs is running. Quit it and run this again."
fi

echo "Looking up the latest release..."
dmg_url=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -o '"browser_download_url": *"[^"]*\.dmg"' \
  | head -1 \
  | sed -E 's/.*"(https[^"]*)"/\1/') || true
[ -n "${dmg_url:-}" ] || fail "no .dmg found in the latest release of $REPO."

tmp=$(mktemp -d)
mount_point=""
cleanup() {
  if [ -n "$mount_point" ]; then hdiutil detach "$mount_point" -quiet || true; fi
  rm -rf "$tmp"
}
trap cleanup EXIT

echo "Downloading $(basename "$dmg_url")..."
curl -fL --progress-bar -o "$tmp/Aventyrs.dmg" "$dmg_url"

mount_point=$(hdiutil attach -nobrowse -readonly -noautoopen "$tmp/Aventyrs.dmg" \
  | awk -F'\t' '/\/Volumes\// { print $NF }' | tail -1)
[ -n "$mount_point" ] && [ -d "$mount_point/$APP_NAME" ] || fail "couldn't find $APP_NAME in the disk image."

# /Applications is writable for admin users; otherwise fall back to ~/Applications.
dest_dir="/Applications"
if [ ! -w "$dest_dir" ]; then
  dest_dir="$HOME/Applications"
  mkdir -p "$dest_dir"
fi

echo "Installing to $dest_dir/$APP_NAME..."
rm -rf "${dest_dir:?}/$APP_NAME"
ditto "$mount_point/$APP_NAME" "$dest_dir/$APP_NAME"
xattr -dr com.apple.quarantine "$dest_dir/$APP_NAME" 2>/dev/null || true

echo "Done. Open Aventyrs from $dest_dir or Launchpad."
