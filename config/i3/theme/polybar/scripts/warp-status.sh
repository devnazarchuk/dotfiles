#!/bin/bash

# Check if warp-cli is available
if ! command -v /usr/bin/warp-cli &> /dev/null; then
    echo "󰌘 N/A"
    exit 0
fi

# Get WARP status
status=$(warp-cli status 2>/dev/null | grep -i "Status update" | awk '{print $3}')

case "$status" in
    "Connected")
        echo "󰖂 WARP"
        ;;
    "Disconnected")
        echo "󰖂 Off"
        ;;
    "Connecting")
        echo "󰖂 ..."
        ;;
    *)
        echo "󰌘 ?"
        ;;
esac
