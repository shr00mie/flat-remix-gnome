#!/usr/bin/env bash
# Build Red GNOME Shell themes and install them to ~/.themes for the user-theme
# GNOME Shell extension.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
TARGET="${TARGET:-$HOME/.themes}"
BACKUP="${BACKUP:-1}"

cd "$ROOT"
"$ROOT/generate-red-themes.sh"

mkdir -p "$TARGET"
if [ "$BACKUP" = "1" ]; then
  backup_dir="$TARGET/.backup-flat-remix-red-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$backup_dir"
  for theme in "$ROOT"/themes-red/Flat-Remix-Red-*; do
    name="$(basename "$theme")"
    if [ -d "$TARGET/$name" ]; then
      cp -a "$TARGET/$name" "$backup_dir/"
    fi
  done
fi

for theme in "$ROOT"/themes-red/Flat-Remix-Red-*; do
  name="$(basename "$theme")"
  rm -rf "$TARGET/$name"
  cp -a "$theme" "$TARGET/$name"
  echo "install-user-themes: installed $name -> $TARGET/$name"
done

echo "install-user-themes: set shell theme with:"
echo "  gsettings set org.gnome.shell.extensions.user-theme name 'Flat-Remix-Red-Dark-fullPanel'"
