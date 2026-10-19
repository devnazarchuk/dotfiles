#!/usr/bin/env bash

current=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

options="󰃠  100% (Maximum)
󰃟  80%
󰃟  60%
󰃟  50% (Half)
󰃞  40%
󰃞  25%
󰃞  10% (Minimum)
󰃞  1% (Night)"

chosen=$(echo -e "$options" | rofi -dmenu -p "󰃟 Brightness" -mesg "Current: ${current}% | Select preset or enter value (1-100)%")

if [ -n "$chosen" ]; then
    val=$(echo "$chosen" | grep -oE '[0-9]+' | head -n1)
    if [ -n "$val" ]; then
        [ "$val" -gt 100 ] && val=100
        [ "$val" -lt 1 ] && val=1
        ~/.config/hypr/scripts/brightness.sh --set "$val"
    fi
fi
