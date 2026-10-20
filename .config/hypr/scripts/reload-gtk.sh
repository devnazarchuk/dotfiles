#!/usr/bin/env bash
# Sync GTK settings + poke running apps to reload user gtk.css.
#
# Never bounce gtk-theme to a light name while dark (or vice versa).
# Thunar's daemon often applies only the first GtkSettings notify and then
# ignores the restore — that stuck it on Adwaita/light permanently.

set -euo pipefail

XSD_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/xsettingsd/xsettingsd.conf"

current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
current_icons=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'")
current_scheme=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null | tr -d "'")
[ -z "$current_theme" ] && current_theme="adw-gtk3-dark"
[ -z "$current_icons" ] && current_icons="Papirus-Dark"
[ -z "$current_scheme" ] && current_scheme="prefer-dark"

is_dark=0
[[ "$current_scheme" == *dark* || "$current_theme" == *-dark ]] && is_dark=1

# 1. xsettingsd
mkdir -p "$(dirname "$XSD_CONF")"
cat > "$XSD_CONF" <<EOF
Net/ThemeName "$current_theme"
Net/IconThemeName "$current_icons"
Gtk/CursorThemeName "catppuccin-mocha-dark-cursors"
Gtk/CursorThemeSize 21
Gtk/ApplicationPreferDarkTheme $is_dark
Net/EnableEventSounds 1
EnableInputFeedbackSounds 0
Xft/Antialias 1
Xft/Hinting 1
Xft/HintStyle "hintslight"
Xft/RGBA "rgb"
EOF

if command -v xsettingsd >/dev/null 2>&1; then
    if pgrep -x xsettingsd >/dev/null 2>&1; then
        pkill -HUP xsettingsd 2>/dev/null || true
    else
        xsettingsd >/dev/null 2>&1 &
    fi
fi

# 2. xfconf
if command -v xfconf-query >/dev/null 2>&1; then
    if xfconf-query -c xsettings -p /Net/ThemeName >/dev/null 2>&1; then
        xfconf-query -c xsettings -p /Net/ThemeName -s "$current_theme" 2>/dev/null || true
    else
        xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "$current_theme" 2>/dev/null || true
    fi
    if xfconf-query -c xsettings -p /Net/IconThemeName >/dev/null 2>&1; then
        xfconf-query -c xsettings -p /Net/IconThemeName -s "$current_icons" 2>/dev/null || true
    else
        xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "$current_icons" 2>/dev/null || true
    fi
fi

# 3. Re-assert final gtk theme + same-mode icon bounce (GtkSettings notify
#    without switching light↔dark chrome)
if [ "$is_dark" -eq 1 ]; then
    alt_icons="Papirus"
    [ "$current_icons" = "Papirus" ] && alt_icons="Papirus-Dark"
else
    alt_icons="Papirus"
    [ "$current_icons" = "Papirus" ] && alt_icons="Papirus-Light"
fi

gsettings set org.gnome.desktop.interface gtk-theme "$current_theme" 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "$alt_icons" 2>/dev/null || true
sleep 0.05
gsettings set org.gnome.desktop.interface icon-theme "$current_icons" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme "$current_scheme" 2>/dev/null || true

# 4. Thunar daemon caches styles — restart so windows match current mode.
#    Closes open Thunar views; daemon comes back immediately.
if pgrep -x Thunar >/dev/null 2>&1 || pgrep -x thunar >/dev/null 2>&1; then
    thunar -q >/dev/null 2>&1 || true
    sleep 0.15
    thunar --daemon >/dev/null 2>&1 &
fi
