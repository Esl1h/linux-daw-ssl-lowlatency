#!/usr/bin/env bash
# Instala o wrapper daw-alsa-ssl e os launchers .desktop para o usuario atual.
# Nao requer root: usa ~/.local/bin e ~/.local/share/applications.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${XDG_BIN_HOME:-$HOME/.local/bin}"
APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
WRAPPER="$BIN_DIR/daw-alsa-ssl"

mkdir -p "$BIN_DIR" "$APP_DIR"

echo "==> Instalando wrapper em $WRAPPER"
install -m 0755 "$SRC_DIR/bin/daw-alsa-ssl" "$WRAPPER"

# Extrai o binario do DAW da linha Exec do template (segundo campo apos o wrapper).
daw_bin_of() { awk -F' ' '/^Exec=/{print $2; exit}' "$1"; }

installed=0
skipped=0
for tpl in "$SRC_DIR"/applications/*.desktop.in; do
  base="$(basename "${tpl%.in}")"
  daw_bin="$(daw_bin_of "$tpl")"
  if [ -n "$daw_bin" ] && [ ! -x "$daw_bin" ]; then
    echo "--  pulando $base (DAW nao encontrado: $daw_bin)"
    skipped=$((skipped+1))
    continue
  fi
  sed "s|__WRAPPER__|$WRAPPER|g" "$tpl" > "$APP_DIR/$base"
  echo "==> Instalado launcher $base"
  installed=$((installed+1))
done

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$APP_DIR" >/dev/null 2>&1 || true
fi

echo
echo "Concluido: $installed launcher(s) instalado(s), $skipped pulado(s)."
if ! printf '%s' ":$PATH:" | grep -q ":$BIN_DIR:"; then
  echo "Aviso: $BIN_DIR nao esta no seu PATH. Adicione ao ~/.zshrc ou ~/.bashrc"
  echo "       se quiser chamar 'daw-alsa-ssl' direto no terminal."
fi
echo "Interface diferente da SSL 2+ MkII? Veja DAW_ALSA_CARD no README."
