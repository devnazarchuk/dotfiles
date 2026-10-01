#!/usr/bin/env bash
# toggle-grayscale.sh — toggle Hyprland grayscale screen shader
SHADER="$HOME/.config/hypr/shaders/grayscale.glsl"
CURRENT=$(hyprctl getoption decoration:screen_shader | awk '/^str:/{print $2}')

if [ "$CURRENT" = "[[EMPTY]]" ] || [ -z "$CURRENT" ]; then
    hyprctl eval "hl.config({ decoration = { screen_shader = '$SHADER' } })"
    notify-send -u low -i preferences-color "Grayscale Filter" "Enabled"
else
    hyprctl eval "hl.config({ decoration = { screen_shader = '' } })"
    notify-send -u low -i preferences-color "Grayscale Filter" "Disabled"
fi
