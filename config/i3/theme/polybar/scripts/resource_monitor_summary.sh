#!/bin/bash

# Get CPU usage percentage
# Extracts the idle percentage from `top` output.
# This approach finds the field containing 'id', then extracts the number before it.
cpu_line=$(top -bn1 | grep "Cpu(s)")
idle_cpu=$(echo "$cpu_line" | grep -oP '\d+\.\d+\s*id' | awk '{print $1}')
cpu_usage=$(printf "%.0f" "$(echo "100 - $idle_cpu" | bc -l)")

# Get memory usage (used in MB and total in MB)
mem_used_mb=$(free -m | awk '/Mem:/ {print $3}')

# Format for Polybar: CPU: X% | RAM: YMB
echo "CPU: ${cpu_usage}% | RAM: ${mem_used_mb}MB"
