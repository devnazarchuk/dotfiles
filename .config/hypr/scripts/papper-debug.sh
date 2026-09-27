#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
LOG_FILE="$HOME/.cache/paper_debug.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

apply_colors() {
    local image_path="$1"
    log "--> Starting color extraction for: $image_path"

    local target_img="$image_path"
    local tmp_img="/tmp/matugen_preview.png"

    # Використовуємо ImageMagick v7 (magick) для швидкого resize без варнінгів
    if command -v magick >/dev/null 2>&1; then
        if magick "$image_path" -resize 500x500\> "$tmp_img" >/dev/null 2>&1; then
            target_img="$tmp_img"
            log "Image resized successfully via magick"
        fi
    elif command -v convert >/dev/null 2>&1; then
        if convert "$image_path" -resize 500x500\> "$tmp_img" >/dev/null 2>&1; then
            target_img="$tmp_img"
            log "Image resized successfully via convert"
        fi
    fi

    log "Running matugen..."
    local matugen_out
    matugen_out=$(matugen image "$target_img" --source-color-index 0 2>&1)
    local matugen_status=$?

    if [ $matugen_status -eq 0 ]; then
        log "matugen SUCCESS"
        # Пауза 0.1s для повного скидання кешу файлу CSS на диск
        sleep 0.1
        if pkill -SIGUSR2 waybar 2>/dev/null; then
            log "Sent SIGUSR2 to waybar"
        elif pkill -SIGUSR1 waybar 2>/dev/null; then
            log "Sent SIGUSR1 to waybar"
        else
            log "ERROR: Failed to send signal to waybar"
        fi
    else
        log "ERROR: matugen FAILED (code $matugen_status): $matugen_out"
    fi
}

# When Rofi initializes
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

# When an item is selected
if [ "$ROFI_RETV" -eq 1 ] && [ -n "$1" ]; then
    # Сховати Rofi миттєво
    pkill -x rofi 2>/dev/null

    image_path="$WALLPAPER_DIR/$1"
    log "=========================================="
    log "Selected wallpaper: $1"

    if [ -f "$image_path" ]; then
        if ! awww query &>/dev/null; then
            awww-daemon >/dev/null 2>&1 &
            sleep 0.1
        fi

        # Встановлення шпалер
        awww img "$image_path" \
            --transition-type any \
            --transition-pos 0.5,0.5 \
            --transition-step 30 \
            --transition-fps 144 \
            --transition-duration 2.5 >/dev/null 2>&1 &

        # Клонування для кешу
        cp "$image_path" "$HOME/.cache/log.png" >/dev/null 2>&1 &

        # Синхронізація для SDDM фоново
        (
            sudo cp "$image_path" /usr/share/sddm/themes/sword/arch.png && \
            sudo chown root:root /usr/share/sddm/themes/sword/arch.png && \
            sudo chmod 644 /usr/share/sddm/themes/sword/arch.png
        ) >/dev/null 2>&1 &

        # Генерація кольорів
        apply_colors "$image_path" &
    else
        log "ERROR: File $image_path does not exist!"
    fi
fi
