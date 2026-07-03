# Flat Remix GNOME Shell on Ubuntu (GNOME 50+)

This fork restores the classic **Flat-Remix-Red-*** shell theme names and
automatically generates the missing `login-background` asset used on the lock
screen.

## Dependencies

```bash
sudo apt update
sudo apt install -y make sassc glib-compile-resources imagemagick \
  gnome-shell-extensions gnome-tweaks dconf-cli
```

Enable **User Themes** in GNOME Extensions (or Tweaks → Extensions).

## Quick install (user themes, recommended)

Installs to `~/.themes/Flat-Remix-Red-*` with login background included:

```bash
git clone https://github.com/shr00mie/flat-remix-gnome.git
cd flat-remix-gnome
./install-user-themes.sh
gsettings set org.gnome.shell.extensions.user-theme name 'Flat-Remix-Red-Dark-fullPanel'
```

Log out and back in (required on Wayland).

## Build Red variants only

```bash
./generate-red-themes.sh
# output: ./themes-red/Flat-Remix-Red-*
```

## Custom accent color

```bash
./generate-color-theme.sh '#ec0101' '#ffffff'
make install-login-background
```

## System-wide install

```bash
./generate-red-themes.sh
sudo cp -a themes-red/Flat-Remix-Red-* /usr/share/themes/
sudo USER_HOME="$HOME" THEMES_DIR=/usr/share/themes \
  ./scripts/install-login-background.sh
```

## Pair with Flat-Remix icons

See the companion [flat-remix](https://github.com/shr00mie/flat-remix) fork:

```bash
git clone https://github.com/shr00mie/flat-remix.git
cd flat-remix
sudo make install PREFIX=/usr
gsettings set org.gnome.desktop.interface icon-theme 'Flat-Remix-Red-Dark'
```

## Fixes included in this fork

- Generates `gnome-shell/assets/login-background` for all built themes
- Restores `Flat-Remix-Red-*` theme directory names for GNOME 50
- `make install` removes stale icon/theme paths before copying (icons repo)
- Ubuntu/GNOME 50 install documentation
