#!/usr/bin/env bash

# Brightness script for Polybar using brightnessctl

# Get brightness level (0-100)
brightness=$(brightnessctl -m | cut -d, -f4 | tr -d '%')

# Icons
if [[ "$brightness" -ge 75 ]]; then
    icon=""
elif [[ "$brightness" -ge 50 ]]; then
    icon=""
elif [[ "$brightness" -ge 25 ]]; then
    icon=""
else
    icon=""
fi

echo "$icon $brightness%"
