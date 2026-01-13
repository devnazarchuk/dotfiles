#!/bin/bash
# Screen Recording Script using ffmpeg
# Dependencies: ffmpeg, libnotify, slop (or maim -s), xwininfo

PID_FILE="/tmp/recording_pid"
OUTPUT_DIR="$HOME/Videos/Screencasts"
mkdir -p "$OUTPUT_DIR"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    kill -INT "$PID"
    wait "$PID"
    rm "$PID_FILE"
    notify-send "Screen Recording" "Recording stopped and saved."
    exit 0
fi


# Start Recording
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_FILE="$OUTPUT_DIR/recording_$TIMESTAMP.mp4"
VIDEO_SIZE="1920x1080" # Default
OFFSET_X="0"
OFFSET_Y="0"

# Check arguments
if [ "$1" == "region" ]; then
    # Get selection
    SLOP=$(slop -f "%x %y %w %h" 2>/dev/null) || exit 1
    read -r -a GEOMETRY <<< "$SLOP"
    OFFSET_X="${GEOMETRY[0]}"
    OFFSET_Y="${GEOMETRY[1]}"
    VIDEO_SIZE="${GEOMETRY[2]}x${GEOMETRY[3]}"
else
    # Fullscreen (get current screen resolution using i3-msg)
    # This grabs the resolution of the active output
    VIDEO_SIZE=$(i3-msg -t get_outputs | jq -r '.[] | select(.active == true) | .rect | "\(.width)x\(.height)"' | head -n 1)
    if [ -z "$VIDEO_SIZE" ]; then
        VIDEO_SIZE="1920x1080" # Fallback
    fi
fi

notify-send "Screen Recording" "Recording started... ($VIDEO_SIZE)"

# Run ffmpeg
# -y: overwrite
# -f x11grab: grab x11
# -s: size
# -i: input (:0.0+X,Y)
# -framerate 30
ffmpeg -y \
    -f x11grab \
    -framerate 30 \
    -video_size "$VIDEO_SIZE" \
    -i ":0.0+$OFFSET_X,$OFFSET_Y" \
    -c:v libx264 -preset ultrafast -crf 23 \
    -pix_fmt yuv420p \
    "$OUTPUT_FILE" &

echo $! > "$PID_FILE"
