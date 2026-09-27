#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

apply_colors() {
    local image_path="$1"
    local target_img="$image_path"
    local tmp_img="/tmp/matugen_preview.png"

    # Resize image using ImageMagick v7 (magick) or v6 (convert) for faster color extraction
    if command -v magick >/dev/null 2>&1; then
        if magick "$image_path" -resize 500x500\> "$tmp_img" >/dev/null 2>&1; then
            target_img="$tmp_img"
        fi
    elif command -v convert >/dev/null 2>&1; then
        if convert "$image_path" -resize 500x500\> "$tmp_img" >/dev/null 2>&1; then
            target_img="$tmp_img"
        fi
    fi

    # Generate color scheme via Matugen
    if matugen image "$target_img" --source-color-index 0 >/dev/null 2>&1; then
        # Brief pause to allow the generated CSS file cache to flush to disk
        sleep 0.1
        pkill -SIGUSR2 waybar 2>/dev/null || pkill -SIGUSR1 waybar 2>/dev/null
    fi
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
