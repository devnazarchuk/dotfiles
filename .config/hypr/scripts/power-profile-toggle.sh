#!/usr/bin/env bash

CURRENT=$(powerprofilesctl get)

if [ "$CURRENT" = "power-saver" ]; then
    powerprofilesctl set balanced
    notify-send -u low -i preferences-system-power "Power Profile" "Switched to Balanced 󰾅"
elif [ "$CURRENT" = "balanced" ]; then
    powerprofilesctl set performance
    notify-send -u low -i preferences-system-power "Power Profile" "Switched to Performance 󰓅"
else
    powerprofilesctl set power-saver
    notify-send -u low -i preferences-system-power "Power Profile" "Switched to Power Saver 󰾆"
fi

# Перезагрузка CSS/кнопок у SwayNC без повного перезапуску демона
swaync-client -rs 2>/dev/null
