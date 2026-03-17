#!/bin/bash

# Variable to store current profile (to avoid applying the same profile twice)
current_profile=""

update_profile() {
    # Check if there is at least one power supply with status online=1
    if cat /sys/class/power_supply/*/online 2>/dev/null | grep -q 1; then
        target_profile="performance"
    else
        target_profile="power-saver"
    fi

    # Change profile only if it differs from the current one
    if [ "$current_profile" != "$target_profile" ]; then
        powerprofilesctl set "$target_profile"
        current_profile="$target_profile"
        
        # Send user-friendly notification
        if [ "$target_profile" = "performance" ]; then
            notify-send -u low -t 3000 "🔌 Power" "Plugged in (Performance)"
        else
            notify-send -u low -t 3000 "🔋 Power" "On Battery (Power Saver)"
        fi
    fi
}

# Set the correct profile immediately on startup
update_profile

# Start continuous listening to udev events from battery or AC
# Every time udev reports changes, call the function
udevadm monitor --subsystem-match=power_supply | while read -r line; do
    update_profile
done
