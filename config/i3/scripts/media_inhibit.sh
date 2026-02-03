#!/bin/bash

# Kill already running instances of this script to prevent duplicates
for pid in $(pgrep -f "media_inhibit.sh"); do
    if [ "$pid" != "$$" ]; then
        kill "$pid"
    fi
done

while true; do
    # Check if any audio is playing (RUNNING state in PulseAudio/PipeWire)
    if pactl list sink-inputs | grep -q "State: RUNNING"; then
        # Reset X idle timer and creating activity
        xset s reset
    fi
    sleep 30
done
