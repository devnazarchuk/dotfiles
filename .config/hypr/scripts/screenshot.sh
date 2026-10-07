#!/usr/bin/env bash

# Screenshot & Screen capture utility for Hyprland
# Freezes the screen immediately by taking a full capture to /tmp first,
# then lets the user select an area and crops the frozen frame.

MODE="${1:-area}" # area, satty, ocr, active, screen
SAVE_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
FILE_PATH="${SAVE_DIR}/Screenshot_${TIMESTAMP}.png"

TMP_FULL="/tmp/screenshot_full_$$.png"
TMP_CROP="/tmp/screenshot_crop_$$.png"

cleanup() {
    rm -f "$TMP_FULL" "$TMP_CROP"
}
trap cleanup EXIT

case "$MODE" in
    satty)
        # 1. Freeze full screen immediately
        grim -l 0 "$TMP_FULL" || exit 1
        # 2. Select region
        GEOM=$(slurp -f "%wx%h+%x+%y" 2>/dev/null)
        [ -z "$GEOM" ] && exit 0
        # 3. Crop selection from frozen image
        magick "$TMP_FULL" -crop "$GEOM" +repage "$TMP_CROP" || exit 1
        # 4. Open in Satty editor
        satty --filename "$TMP_CROP" --output-filename "$FILE_PATH" --early-exit --actions-on-enter save-to-clipboard --copy-command 'wl-copy'
        ;;

    area)
        # 1. Freeze full screen immediately
        grim -l 0 "$TMP_FULL" || exit 1
        # 2. Select region
        GEOM=$(slurp -f "%wx%h+%x+%y" 2>/dev/null)
        [ -z "$GEOM" ] && exit 0
        # 3. Crop directly to final file
        magick "$TMP_FULL" -crop "$GEOM" +repage "$FILE_PATH" || exit 1
        # 4. Copy to clipboard & notify
        wl-copy < "$FILE_PATH"
        notify-send -i "$FILE_PATH" "Screenshot" "Region saved and copied to clipboard"
        ;;

    ocr)
        # 1. Freeze full screen immediately
        grim -l 0 "$TMP_FULL" || exit 1
        # 2. Select region
        GEOM=$(slurp -f "%wx%h+%x+%y" 2>/dev/null)
        [ -z "$GEOM" ] && exit 0
        # 3. Crop selection
        magick "$TMP_FULL" -crop "$GEOM" +repage "$TMP_CROP" || exit 1
        # 4. Recognize text and copy to clipboard
        TEXT=$(tesseract "$TMP_CROP" stdout -l ukr+eng 2>/dev/null)
        if [ -n "$TEXT" ]; then
            printf "%s" "$TEXT" | wl-copy
            notify-send "⎘ OCR" "Text copied to clipboard"
        fi
        ;;

    active)
        # Capture currently focused window
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null)
        if [ -n "$GEOM" ] && [ "$GEOM" != "null,null nullxnull" ]; then
            grim -g "$GEOM" "$FILE_PATH" || exit 1
            wl-copy < "$FILE_PATH"
            notify-send -i "$FILE_PATH" "Screenshot" "Active window saved and copied"
        fi
        ;;

    screen)
        # Full screen capture
        grim "$FILE_PATH" || exit 1
        wl-copy < "$FILE_PATH"
        notify-send -i "$FILE_PATH" "Screenshot" "Full screen saved and copied"
        ;;

    *)
        echo "Usage: $0 [satty|area|ocr|active|screen]"
        exit 1
        ;;
esac
