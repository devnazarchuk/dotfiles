#!/bin/bash
# Battery Monitor Script

while true; do
    # Path to battery (adjust BAT0 if needed)
    BAT_PATH="/sys/class/power_supply/BAT0"

    # Check if battery exists
    if [ -d "$BAT_PATH" ]; then
        STATUS=$(cat "$BAT_PATH/status")
        CAPACITY=$(cat "$BAT_PATH/capacity")

        if [ "$STATUS" = "Discharging" ]; then
            if [ "$CAPACITY" -le 10 ]; then
                 notify-send -u critical "CRITICAL BATTERY" "Level: ${CAPACITY}%"
                 # High pitch beep, repeat twice
                 mpv --no-terminal ~/Music/discharged_battery.mp3 > /dev/null 2>&1
            elif [ "$CAPACITY" -le 20 ]; then
                 notify-send "Low Battery" "Level: ${CAPACITY}%"
                 # Low pitch beep, once
                 mpv --no-terminal ~/Music/low_battery.mp3 > /dev/null 2>&1
            fi
        fi
    fi

    # Check every minute
    sleep 60
done
