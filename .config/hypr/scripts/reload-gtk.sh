#!/usr/bin/env bash

# --- RELOAD GTK THEME & STYLESHEETS ---
# Toggle the GTK theme name briefly to notify open GTK3/GTK4 windows
# to re-read ~/.config/gtk-3.0/gtk.css and ~/.config/gtk-4.0/gtk.css.
current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
[ -z "$current_theme" ] && current_theme="adw-gtk3-dark"

if [ "$current_theme" = "Adwaita" ]; then
    gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3" 2>/dev/null
else
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita" 2>/dev/null
fi
sleep 0.05
gsettings set org.gnome.desktop.interface gtk-theme "$current_theme" 2>/dev/null
