#!/usr/bin/env bash

# Power supply status (1 = Charging/Plugged in, 0 = Discharging/Battery)
# Replace 'AC' with 'ADP1' if your system uses that name
AC_STATUS=$(cat /sys/class/power_supply/AC/online 2>/dev/null)

if [ "$AC_STATUS" -eq 1 ]; then
    powerprofilesctl set performance
    notify-send -u low -i preferences-system-power "Power Supply" "Plugged in: Switched to Performance 󰓅"
else
    powerprofilesctl set power-saver
    notify-send -u low -i preferences-system-power "Power Supply" "On Battery: Switched to Power Saver 󰾆"
fi

# Refresh SwayNC state
swaync-client -rs 2>/dev/null
