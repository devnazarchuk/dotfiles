#!/bin/bash
# OCR Script using NormCap
# Forces specific handlers to avoid DBus/Portal issues on i3

# Check if normcap is installed
if ! command -v normcap &> /dev/null; then
    notify-send -u critical "OCR Error" "NormCap not found. Please install it."
    exit 1
fi

# Run NormCap with X11-friendly settings
# --screenshot-handler qt: Uses Qt's internal grabbing (works on X11)
# --clipboard-handler xclip: Uses X11 clipboard
# --notification-handler notify_send: Uses libnotify
# -l eng+ukr: English and Ukrainian
normcap \
    --screenshot-handler qt \
    --clipboard-handler xclip \
    --notification-handler notify_send \
    -l eng ukr rus deu
