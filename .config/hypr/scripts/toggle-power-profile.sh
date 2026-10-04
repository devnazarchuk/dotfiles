#!/usr/bin/env bash

# Cycle through power profiles: performance → balanced → power-saver → performance
CURRENT=$(powerprofilesctl get 2>/dev/null)

case "$CURRENT" in
    performance)
        NEXT="balanced"
        ICON="󰾅"
        ;;
    balanced)
        NEXT="power-saver"
        ICON="󰾆"
        ;;
    power-saver)
        NEXT="performance"
        ICON="󰓅"
        ;;
    *)
        NEXT="balanced"
        ICON="󰾅"
        ;;
esac

powerprofilesctl set "$NEXT"
notify-send -t 2000 -i battery "${ICON} Power Profile" "Switched to: $NEXT"
