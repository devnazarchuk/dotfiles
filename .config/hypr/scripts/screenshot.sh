#!/usr/bin/env bash

# Screenshot & Screen capture utility for Hyprland
# 1. Visually freezes the screen with hyprpicker overlay
# 2. Captures full uncompressed frame to /tmp instantly
# 3. Runs slurp on the frozen screen
# 4. Crops selection and feeds to Satty / clipboard / OCR

MODE="${1:-area}" # area, satty, ocr, active, screen
SAVE_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
FILE_PATH="${SAVE_DIR}/Screenshot_${TIMESTAMP}.png"

TMP_FULL="/tmp/screenshot_full_$$.png"
TMP_CROP="/tmp/screenshot_crop_$$.png"
HP_PID=""

kill_picker() {
    if [ -n "$HP_PID" ]; then
        kill "$HP_PID" 2>/dev/null || true
    fi
    pkill -x hyprpicker 2>/dev/null || true
}

cleanup() {
    kill_picker
    rm -f "$TMP_FULL" "$TMP_CROP"
}
trap cleanup EXIT INT TERM

freeze_screen() {
    # Start hyprpicker in background to visually freeze the screen
    if command -v hyprpicker >/dev/null 2>&1; then
        hyprpicker -rz &
        HP_PID=$!
        sleep 0.05
    fi
    # Instantly capture the frozen frame to /tmp
    grim -l 0 "$TMP_FULL" || { kill_picker; exit 1; }
}

case "$MODE" in
    satty)
        freeze_screen
        GEOM=$(slurp -f "%wx%h+%x+%y" 2>/dev/null)
        kill_picker
        [ -z "$GEOM" ] && exit 0

        magick "$TMP_FULL" -crop "$GEOM" +repage "$TMP_CROP" || exit 1
        satty --filename "$TMP_CROP" --output-filename "$FILE_PATH" --early-exit --actions-on-enter save-to-clipboard --copy-command 'wl-copy'
        ;;

    area)
        freeze_screen
        GEOM=$(slurp -f "%wx%h+%x+%y" 2>/dev/null)
        kill_picker
        [ -z "$GEOM" ] && exit 0

        magick "$TMP_FULL" -crop "$GEOM" +repage "$FILE_PATH" || exit 1
        wl-copy < "$FILE_PATH"
        notify-send -i "$FILE_PATH" "Screenshot" "Region saved and copied to clipboard"
        ;;

    ocr)
        freeze_screen
        GEOM=$(slurp -f "%wx%h+%x+%y" 2>/dev/null)
        kill_picker
        [ -z "$GEOM" ] && exit 0

        magick "$TMP_FULL" -crop "$GEOM" +repage "$TMP_CROP" || exit 1
        TEXT=$(tesseract "$TMP_CROP" stdout -l ukr+eng 2>/dev/null)
        if [ -n "$TEXT" ]; then
            printf "%s" "$TEXT" | wl-copy
            notify-send "⎘ OCR" "Text copied to clipboard"
        fi
        ;;

    active)
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"' 2>/dev/null)
        if [ -n "$GEOM" ] && [ "$GEOM" != "null,null nullxnull" ]; then
            grim -g "$GEOM" "$FILE_PATH" || exit 1
            wl-copy < "$FILE_PATH"
            notify-send -i "$FILE_PATH" "Screenshot" "Active window saved and copied"
        fi
        ;;

    screen)
        grim "$FILE_PATH" || exit 1
        wl-copy < "$FILE_PATH"
        notify-send -i "$FILE_PATH" "Screenshot" "Full screen saved and copied"
        ;;

    *)
        echo "Usage: $0 [satty|area|ocr|active|screen]"
        exit 1
        ;;
esac
