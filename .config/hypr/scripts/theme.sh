#!/usr/bin/env bash

# State files in ~/.cache
mkdir -p "$HOME/.cache"
THEME_MODE_FILE="$HOME/.cache/theme_mode"
THEME_PREF_FILE="$HOME/.cache/theme_pref"
WALLPAPER_CACHE="$HOME/.cache/log.png"
WAYBAR_SIGNAL="9" # RTMIN+9

update_waybar() {
    pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null
    pkill -SIGUSR2 waybar 2>/dev/null || pkill -SIGUSR1 waybar 2>/dev/null
}

get_current_mode() {
    if [ -f "$THEME_MODE_FILE" ]; then
        cat "$THEME_MODE_FILE"
    else
        echo "dark"
    fi
}

get_preference() {
    if [ -f "$THEME_PREF_FILE" ]; then
        cat "$THEME_PREF_FILE"
    else
        echo "smart"
    fi
}

apply_theme() {
    local img="$1"
    local mode="$2"

    [ ! -f "$img" ] && img="$WALLPAPER_CACHE"
    [ ! -f "$img" ] && exit 1

    # If mode not specified, use preference (smart / dark / light)
    [ -z "$mode" ] && mode=$(get_preference)

    # Determine preview / target image
    local target_img="$img"
    local tmp_img="/tmp/matugen_preview.png"
    if command -v magick >/dev/null 2>&1; then
        if magick "$img" -resize 500x500\> "$tmp_img" >/dev/null 2>&1; then
            target_img="$tmp_img"
        fi
    fi

    # Detect effective mode if smart
    local effective_mode="$mode"
    if [ "$mode" = "smart" ]; then
        # Check average image brightness (0-100) via ImageMagick for reliable day/night classification
        local lum=$(magick "$target_img" -colorspace Gray -format "%[fx:int(mean*100)]" info: 2>/dev/null)
        if [ -n "$lum" ] && [ "$lum" -ge 46 ]; then
            effective_mode="light"
        elif [ -n "$lum" ] && [ "$lum" -le 35 ]; then
            effective_mode="dark"
        else
            effective_mode=$(matugen image "$target_img" -m smart --source-color-index 0 --dry-run -j hex 2>/dev/null | jq -r '.mode // "dark"')
        fi
    fi

    # Run Matugen with determined mode
    matugen image "$target_img" -m "$effective_mode" --source-color-index 0 >/dev/null 2>&1

    # Save state
    echo "$effective_mode" > "$THEME_MODE_FILE"

    # Sync GTK color-scheme
    if [ "$effective_mode" = "light" ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null
    fi

    # Reload GTK CSS and Waybar
    ~/.config/hypr/scripts/reload-gtk.sh >/dev/null 2>&1 &
    update_waybar

    # Notify
    notify-send -t 1500 -a "Theme" -i preferences-desktop-theme "Theme Applied" "Mode: ${effective_mode^} (${mode} mode)"
}

case "$1" in
    "get")
        get_current_mode
        ;;
    "pref")
        get_preference
        ;;
    "toggle")
        current=$(get_current_mode)
        if [ "$current" = "dark" ]; then
            new_mode="light"
        else
            new_mode="dark"
        fi
        apply_theme "$WALLPAPER_CACHE" "$new_mode"
        ;;
    "set")
        mode="${2:-smart}"
        case "$mode" in
            "dark"|"light"|"smart")
                echo "$mode" > "$THEME_PREF_FILE"
                apply_theme "$WALLPAPER_CACHE" "$mode"
                ;;
            *)
                echo "Usage: theme.sh set [dark|light|smart]"
                ;;
        esac
        ;;
    "apply")
        img="$2"
        mode="$3"
        apply_theme "$img" "$mode"
        ;;
    "status")
        current=$(get_current_mode)
        pref=$(get_preference)
        if [ "$current" = "light" ]; then
            icon="󰖨"
            label="Light"
        else
            icon="󰔎"
            label="Dark"
        fi
        echo "{\"text\": \"$icon $label\", \"class\": \"$current\", \"tooltip\": \"Theme: $label (Pref: $pref)\\nLMB: Toggle Light/Dark\\nRMB: Reset to Smart (Auto)\"}"
        ;;
    *)
        echo "Usage: theme.sh [get|pref|toggle|set <mode>|apply <image> [mode]|status]"
        ;;
esac
