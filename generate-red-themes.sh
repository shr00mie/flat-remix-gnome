#!/usr/bin/env bash
# Build Flat-Remix GNOME Shell themes with the classic Red accent palette and
# emit Flat-Remix-Red-* directory names for compatibility with older installs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

RED_ACCENT="${RED_ACCENT:-#ec0101}"
RED_TEXT="${RED_TEXT:-#ffffff}"
THEMES_DIR="$ROOT/themes"
RED_THEMES_DIR="$ROOT/themes-red"

for cmd in make sassc glib-compile-resources convert; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "generate-red-themes: missing dependency: $cmd" >&2
    exit 1
  }
done

chmod +x "$ROOT/generate-color-theme.sh" "$ROOT/scripts/install-login-background.sh"

export COLOR="$RED_ACCENT"
export TEXT_COLOR="$RED_TEXT"
rm -rf "$THEMES_DIR"/*
make -j build

rm -rf "$RED_THEMES_DIR"
mkdir -p "$RED_THEMES_DIR"

declare -A RENAME=(
  [Flat-Remix-Light]=Flat-Remix-Red-Light
  [Flat-Remix-Light-fullPanel]=Flat-Remix-Red-Light-fullPanel
  [Flat-Remix-Dark]=Flat-Remix-Red-Dark
  [Flat-Remix-Dark-fullPanel]=Flat-Remix-Red-Dark-fullPanel
  [Flat-Remix-Darkest]=Flat-Remix-Red-Darkest
  [Flat-Remix-Darkest-fullPanel]=Flat-Remix-Red-Darkest-fullPanel
)

for src in "${!RENAME[@]}"; do
  dst="${RENAME[$src]}"
  cp -a "$THEMES_DIR/$src" "$RED_THEMES_DIR/$dst"
  cat > "$RED_THEMES_DIR/$dst/index.theme" <<EOF
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=$dst
Comment=Flat Remix GNOME Shell theme (Red accent)
X-GNOME-APIVersion=3.0
EOF
done

THEMES_DIR="$RED_THEMES_DIR" "$ROOT/scripts/install-login-background.sh"

echo "generate-red-themes: built Red variants in $RED_THEMES_DIR"
