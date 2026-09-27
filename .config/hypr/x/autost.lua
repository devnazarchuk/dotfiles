-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
hl.on("hyprland.start", function ()
    -- Session env for portals / user services
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")

    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wayland-pipewire-idle-inhibit -q")
    hl.exec_cmd("hyprsunset -t 5000")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("bluetoothctl power on")
    hl.exec_cmd("~/.config/hypr/scripts/upbat.sh")
    hl.exec_cmd("~/.config/hypr/scripts/power-auto.sh")
    -- Theme & Cursor Sync
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'catppuccin-mocha-dark-cursors'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 21")
    hl.exec_cmd("hyprctl setcursor catppuccin-mocha-dark-cursors 21")

end)
