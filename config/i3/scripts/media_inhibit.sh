#!/bin/bash

# This script prevents the screen from auto-locking if media is playing.
# It checks playerctl status and resets the X11 screensaver timer.

while true; do
    # Check if any MPRIS-compatible player (like AyuGram, Spotify, Brave) is playing
    if playerctl status 2>/dev/null | grep -q "Playing"; then
        xset s reset
    fi
    sleep 30
done
