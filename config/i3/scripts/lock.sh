#!/bin/bash
# Lock Screen Script with Blur
# Dependencies: i3lock, imagemagick, maim

# Temporary file for the screenshot
IMAGE="/tmp/i3lock.png"

# Take a screenshot
maim "$IMAGE"

# Blur the screenshot (fast blur)
# -scale 10% -scale 1000% is faster than -blur
convert "$IMAGE" -scale 10% -scale 1000% "$IMAGE"

# Add a lock icon or text if desired (optional, adding text here)
# convert "$IMAGE" -gravity center -annotate +0+0 "Locked" "$IMAGE"

# Lock the screen
i3lock -i "$IMAGE"

# Clean up
rm "$IMAGE"
