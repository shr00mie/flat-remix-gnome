#!/usr/bin/env bash
# Generate blurred login-screen background from the user's wallpaper and install
# it into every Flat-Remix GNOME Shell theme under THEMES_DIR.
set -euo pipefail

THEMES_DIR="${THEMES_DIR:-./themes}"
BLUR="${BLUR:-6}"
FALLBACK_WALLPAPER="${FALLBACK_WALLPAPER:-/usr/share/backgrounds/warty-final-ubuntu.png}"
LOGIN_BG="$(mktemp /tmp/login-background.XXXXXX)"

cleanup() {
  rm -f "$LOGIN_BG"
}
trap cleanup EXIT

get_wallpaper() {
  local uri path home="${USER_HOME:-$HOME}"
  uri="$(HOME="$home" dconf read /org/gnome/desktop/background/picture-uri 2>/dev/null || true)"
  uri="${uri#\'}"
  uri="${uri%\'}"
  path="${uri#file://}"
  path="$(printf '%b' "$path")"
  if [ -n "$path" ] && [ -f "$path" ]; then
    printf '%s\n' "$path"
    return 0
  fi
  if [ -f "$FALLBACK_WALLPAPER" ]; then
    printf '%s\n' "$FALLBACK_WALLPAPER"
    return 0
  fi
  return 1
}

command -v convert >/dev/null 2>&1 || {
  echo "install-login-background: ImageMagick (convert) is required" >&2
  exit 1
}

wallpaper="$(get_wallpaper)" || {
  echo "install-login-background: no wallpaper found; set FALLBACK_WALLPAPER" >&2
  exit 1
}

if [ "$BLUR" -le 1 ]; then
  cp -f "$wallpaper" "$LOGIN_BG"
else
  convert -scale 10% -gaussian-blur "0x${BLUR}" -resize 1000% "$wallpaper" "$LOGIN_BG"
fi

installed=0
while IFS= read -r assets_dir; do
  cp -f "$LOGIN_BG" "$assets_dir/login-background"
  installed=$((installed + 1))
done < <(find "$THEMES_DIR" -path '*/gnome-shell/assets' -type d 2>/dev/null | sort)

if [ "$installed" -eq 0 ]; then
  echo "install-login-background: no themes found under $THEMES_DIR" >&2
  exit 1
fi

echo "install-login-background: installed login-background in $installed theme(s)"
