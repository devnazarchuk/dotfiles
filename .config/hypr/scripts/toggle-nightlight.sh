#!/usr/bin/env bash
# toggle-nightlight.sh — toggle hyprsunset Night Light filter
TEMP="${1:-3500}"

if pgrep -x hyprsunset >/dev/null; then
    pkill -x hyprsunset
    notify-send -u low -i display-brightness "Night Light" "Disabled"
else
    hyprsunset -t "$TEMP" &
    notify-send -u low -i display-brightness "Night Light" "Enabled (${TEMP}K)"
fi
