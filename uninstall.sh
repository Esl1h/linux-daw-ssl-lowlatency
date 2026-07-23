#!/usr/bin/env bash
# Removes the wrapper and the launchers installed by install.sh.
set -euo pipefail

BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

rm -f "$BIN_DIR/daw-alsa-ssl"
for f in ardour9-ssl mixbus11-ssl mixbus12-ssl livetrax3-ssl reaper-ssl; do
  rm -f "$APP_DIR/$f.desktop"
done

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi
echo "Removed wrapper and launchers."
