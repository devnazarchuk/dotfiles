#!/bin/bash
# Battery Monitor Script

warned_20=false
warned_10=false

while true; do
    # Path to battery (adjust BAT0 if needed)
    BAT_PATH="/sys/class/power_supply/BAT0"

    # Check if battery exists
    if [ -d "$BAT_PATH" ]; then
        STATUS=$(cat "$BAT_PATH/status")
        CAPACITY=$(cat "$BAT_PATH/capacity")

        if [ "$STATUS" = "Discharging" ]; then
            if [ "$CAPACITY" -le 10 ] && [ "$warned_10" = false ]; then
                 notify-send -u critical "CRITICAL BATTERY" "Level: ${CAPACITY}%"
                 # High pitch beep, repeat twice
                 mpv --no-terminal ~/Music/discharged_battery.mp3 > /dev/null 2>&1
                 warned_10=true
                 warned_20=true
            elif [ "$CAPACITY" -le 20 ] && [ "$CAPACITY" -gt 10 ] && [ "$warned_20" = false ]; then
                 notify-send "Low Battery" "Level: ${CAPACITY}%"
                 # Low pitch beep, once
                 mpv --no-terminal ~/Music/low_battery.mp3 > /dev/null 2>&1
                 warned_20=true
            fi
        fi

        # Reset warnings when charging or when capacity goes back up
        if [ "$CAPACITY" -gt 20 ]; then
            warned_20=false
            warned_10=false
        elif [ "$CAPACITY" -gt 10 ]; then
            warned_10=false
        fi
    fi

    # Check every minute
    sleep 60
done
