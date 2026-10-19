#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

apply_colors() {
    local image_path="$1"
    "$HOME/.config/hypr/scripts/theme.sh" apply "$image_path" "smart"
}

# Populate Rofi menu
if [ -z "$ROFI_RETV" ] || [ "$ROFI_RETV" -eq 0 ]; then
    if [ ! -d "$WALLPAPER_DIR" ]; then
        exit 1
    fi

    find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | while read -r filepath; do
        filename=$(basename "$filepath")
        echo -en "${filename}\0icon\x1f${filepath}\n"
    done
    exit 0
fi

# Apply selection
if [ "$ROFI_RETV" -eq 1 ] && [ -n "$1" ]; then
    # Hide Rofi UI immediately
    pkill -x rofi 2>/dev/null

    image_path="$WALLPAPER_DIR/$1"

    if [ -f "$image_path" ]; then
        if ! awww query &>/dev/null; then
            awww-daemon >/dev/null 2>&1 &
            sleep 0.1
        fi

        # Set wallpaper via awww
        awww img "$image_path" \
            --transition-type any \
            --transition-pos 0.5,0.5 \
            --transition-step 30 \
            --transition-fps 144 \
            --transition-duration 2.5 >/dev/null 2>&1 &

        # Cache wallpaper copy
        cp "$image_path" "$HOME/.cache/log.png" >/dev/null 2>&1 &

        # Sync wallpaper for SDDM in background
        (
            sudo cp "$image_path" /usr/share/sddm/themes/sword/arch.png && \
            sudo chown root:root /usr/share/sddm/themes/sword/arch.png && \
            sudo chmod 644 /usr/share/sddm/themes/sword/arch.png
        ) >/dev/null 2>&1 &

        # Run color scheme generation asynchronously
        apply_colors "$image_path" &
    fi
fi
