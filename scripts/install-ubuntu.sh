#!/usr/bin/env bash
# Install Flat-Remix GNOME Shell (Red) + icons on Ubuntu with fixes applied.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
ICONS_REPO="${ICONS_REPO:-$ROOT/../flat-remix}"
SHELL_REPO="${SHELL_REPO:-$ROOT/../flat-remix-gnome}"

install_deps() {
  sudo apt update
  sudo apt install -y make sassc glib-compile-resources imagemagick \
    gtk-update-icon-cache gnome-shell-extensions dconf-cli
}

install_icons() {
  if [ ! -d "$ICONS_REPO" ]; then
    echo "install-ubuntu: icons repo not found at $ICONS_REPO" >&2
    exit 1
  fi
  make -C "$ICONS_REPO" install PREFIX=/usr
  gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Red-Dark'
  echo "install-ubuntu: icon theme set to Flat-Remix-Red-Dark"
}

install_shell_user() {
  if [ ! -d "$SHELL_REPO" ]; then
    echo "install-ubuntu: shell repo not found at $SHELL_REPO" >&2
    exit 1
  fi
  "$SHELL_REPO/install-user-themes.sh"
  gsettings set org.gnome.shell.extensions.user-theme name 'Flat-Remix-Red-Dark-fullPanel'
  echo "install-ubuntu: shell theme set to Flat-Remix-Red-Dark-fullPanel"
}

install_shell_system() {
  "$SHELL_REPO/generate-red-themes.sh"
  sudo cp -a "$SHELL_REPO/themes-red/Flat-Remix-Red-"* /usr/share/themes/
  sudo USER_HOME="$HOME" THEMES_DIR=/usr/share/themes \
    "$SHELL_REPO/scripts/install-login-background.sh"
}

cleanup_flatpak() {
  if command -v flatpak >/dev/null 2>&1; then
    flatpak uninstall --unused -y 2>/dev/null || flatpak uninstall --unused || true
    flatpak update -y org.gtk.Gtk3theme.Yaru org.gtk.Gtk3theme.Flat-Remix-GTK-Red-Dark 2>/dev/null || true
  fi
}

usage() {
  cat <<EOF
Usage: $0 [--deps] [--icons] [--shell] [--shell-system] [--flatpak] [--all]

  --deps           Install apt build dependencies
  --icons          Install Flat-Remix icons to /usr/share/icons
  --shell          Install Red GNOME Shell themes to ~/.themes
  --shell-system   Install Red GNOME Shell themes system-wide
  --flatpak        Prune unused Flatpak runtimes and refresh GTK themes
  --all            Run all of the above (default)
EOF
}

run_deps=0 run_icons=0 run_shell=0 run_shell_system=0 run_flatpak=0

if [ $# -eq 0 ]; then
  run_deps=1 run_icons=1 run_shell=1 run_flatpak=1
else
  for arg in "$@"; do
    case "$arg" in
      --deps) run_deps=1 ;;
      --icons) run_icons=1 ;;
      --shell) run_shell=1 ;;
      --shell-system) run_shell_system=1 ;;
      --flatpak) run_flatpak=1 ;;
      --all) run_deps=1 run_icons=1 run_shell=1 run_flatpak=1 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $arg" >&2; usage; exit 1 ;;
    esac
  done
fi

[ "$run_deps" = "1" ] && install_deps
[ "$run_icons" = "1" ] && install_icons
[ "$run_shell" = "1" ] && install_shell_user
[ "$run_shell_system" = "1" ] && install_shell_system
[ "$run_flatpak" = "1" ] && cleanup_flatpak

echo "install-ubuntu: done. Log out and back in to apply the GNOME Shell theme on Wayland."
