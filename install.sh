#!/usr/bin/env bash
# Installs the daw-alsa-ssl wrapper and the .desktop launchers for the current user.
# No root required: uses ~/.local/bin and ~/.local/share/applications.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
WRAPPER="$BIN_DIR/daw-alsa-ssl"

mkdir -p "$BIN_DIR" "$APP_DIR"

echo "==> Installing wrapper to $WRAPPER"
install -m 0755 "$SRC_DIR/bin/daw-alsa-ssl" "$WRAPPER"

# Extract the DAW binary from the template Exec line (second field after the wrapper).
daw_bin_of() { awk -F' ' '/^Exec=/{print $2; exit}' "$1"; }

installed=0
skipped=0
for tpl in "$SRC_DIR"/applications/*.desktop.in; do
  base="$(basename "${tpl%.in}")"
  daw_bin="$(daw_bin_of "$tpl")"
  if [ -n "$daw_bin" ] && [ ! -x "$daw_bin" ]; then
    echo "--  skipping $base (DAW not found: $daw_bin)"
    skipped=$((skipped+1))
    continue
  fi
  sed "s|__WRAPPER__|$WRAPPER|g" "$tpl" > "$APP_DIR/$base"
  echo "==> Installed launcher $base"
  installed=$((installed+1))
done

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

echo
echo "Done: $installed launcher(s) installed, $skipped skipped."
if ! printf '%s' ":$PATH:" | grep -q ":$BIN_DIR:"; then
  echo "Note: $BIN_DIR is not in your PATH. Add it to ~/.zshrc or ~/.bashrc"
  echo "      if you want to call 'daw-alsa-ssl' directly from the terminal."
fi
echo "Using an interface other than the SSL 2+ MkII? See DAW_ALSA_CARD in the README."
