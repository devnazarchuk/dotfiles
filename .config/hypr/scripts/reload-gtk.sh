#!/usr/bin/env bash

# --- TOGGLE COLOR SCHEME ---
# Quickly toggle between light and dark color schemes to force GTK apps
# (like modern libadwaita applications) to reload their CSS stylesheets.
current=$(gsettings get org.gnome.desktop.interface color-scheme)

if [[ "$current" == "'prefer-dark'" ]]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
fi

# --- RELOAD GTK THEME FOR TRADITIONAL GTK3 APPS (e.g., Thunar) ---
# Toggle the GTK theme name back and forth. This forces the XSettings daemon
# to notify all open GTK3/GTK4 windows to re-read ~/.config/gtk-3.0/gtk.css.
current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
gsettings set org.gnome.desktop.interface gtk-theme "$current_theme"
