#!/bin/bash

# Define the function to get and format CPU and Memory data
get_resource_data() {
    # Get CPU usage per core using mpstat
    # mpstat -P ALL 1 1 produces per-core stats for one sample.
    # We process all lines with a timestamp and a CPU identifier ('all' or a number).
    # $NF is the idle percentage.
    cpu_data=$(mpstat -P ALL 1 1 | \
        awk 'BEGIN {OFS="\t"} /^[0-9]{2}:[0-9]{2}:[0-9]{2}/ && ($2 ~ /^[0-9]+$/ || $2 == "all") {
            if ($2 == "all") {
                printf "Total CPU: %.2f%%\n", 100 - $NF
            } else {
                printf "Core %s: %.2f%%\n", $2, 100 - $NF
            }
        }')

    # Get memory usage using free
    mem_data=$(free -h | awk '/Mem:/ {print "Total RAM: " $2 "\nUsed RAM:  " $3 "\nFree RAM:  " $4} /Swap:/ {print "Total Swap: " $2 "\nUsed Swap:  " $3 "\nFree Swap:  " $4}')

    echo "CPU Usage:"
    echo "$cpu_data"
    echo ""
    echo "Memory Usage:"
    echo "$mem_data"
}

# Combine and display with rofi
(
    get_resource_data
) | rofi -dmenu -i -p "Resource Monitor" -theme ~/.config/i3/theme/rofi/launcher.rasi
