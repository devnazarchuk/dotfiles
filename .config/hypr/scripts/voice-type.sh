#!/usr/bin/env bash

PID_FILE="/dev/shm/whisper_recording.pid"
TMP_AUDIO="/dev/shm/whisper_mic.wav"
MODEL_DIR="$HOME/.local/share/whisper-models"
LANG_FILE="$HOME/.cache/whisper_lang"
WAYBAR_SIGNAL="8" # RTMIN+8

mkdir -p "$HOME/.cache"

# Ensure default language is UK
if [ ! -f "$LANG_FILE" ]; then
    echo "uk" > "$LANG_FILE"
fi

CURRENT_LANG=$(cat "$LANG_FILE" 2>/dev/null | tr -d '[:space:]')
[ -z "$CURRENT_LANG" ] && CURRENT_LANG="uk"

update_waybar() {
    pkill -RTMIN+"$WAYBAR_SIGNAL" waybar 2>/dev/null
}

# -----------------
# 1. WAYBAR STATUS
# -----------------
if [ "$1" = "status" ]; then
    if [ -f "$PID_FILE" ]; then
        echo '{"text": "󰍮 REC", "class": "recording", "tooltip": "Voice recording active... (click to stop)"}'
    else
        LANG_UPPER=$(echo "$CURRENT_LANG" | tr '[:lower:]' '[:upper:]')
        echo "{\"text\": \"󰻃 $LANG_UPPER\", \"class\": \"idle\", \"tooltip\": \"Whisper STT ($LANG_UPPER)\\nLMB: start/stop recording\\nRMB: toggle language (UK/EN)\"}"
    fi
    exit 0
fi

# -----------------
# 2. TOGGLE LANGUAGE (UK <-> EN)
# -----------------
if [ "$1" = "toggle-lang" ]; then
    if [ "$CURRENT_LANG" = "uk" ]; then
        echo "en" > "$LANG_FILE"
        notify-send -t 1500 -a "Whisper" -i input-keyboard "🌐 Whisper: English" "Language set to English (EN)"
    else
        echo "uk" > "$LANG_FILE"
        notify-send -t 1500 -a "Whisper" -i input-keyboard "🌐 Whisper: Ukrainian" "Language set to Ukrainian (UK)"
    fi
    update_waybar
    exit 0
fi

# -----------------
# 3. SELECT MODEL
# -----------------
# ggml-small.bin provides the best balance of accuracy and speed on CPU
if [ -f "$MODEL_DIR/ggml-small.bin" ]; then
    MODEL_PATH="$MODEL_DIR/ggml-small.bin"
elif [ -f "$MODEL_DIR/ggml-large-v3-turbo-q5_0.bin" ]; then
    MODEL_PATH="$MODEL_DIR/ggml-large-v3-turbo-q5_0.bin"
elif [ -f "$MODEL_DIR/ggml-base.bin" ]; then
    MODEL_PATH="$MODEL_DIR/ggml-base.bin"
else
    notify-send -u critical "Whisper" "Model not found in $MODEL_DIR"
    exit 1
fi

# -----------------
# 4. TOGGLE RECORDING
# -----------------
if [ -f "$PID_FILE" ]; then
    # --- STOP & TRANSCRIBE ---
    REC_PID=$(cat "$PID_FILE")
    rm -f "$PID_FILE"
    update_waybar

    # Cleanly stop recorder
    if kill -0 "$REC_PID" 2>/dev/null; then
        kill -2 "$REC_PID" 2>/dev/null
        wait "$REC_PID" 2>/dev/null
    fi

    notify-send -t 1500 -a "Whisper" -i media-record "⏳ Transcribing..." "Processing speech (${CURRENT_LANG^^})..."

    if [ ! -s "$TMP_AUDIO" ]; then
        notify-send -t 2000 -a "Whisper" "⚠️ Error" "Audio recording is empty"
        rm -f "$TMP_AUDIO"
        update_waybar
        exit 1
    fi

    # Transcribe: 6 threads for i5-10210U (8 vCPUs), no timestamps, no prints
    if [ "$CURRENT_LANG" = "uk" ]; then
        RAW_TEXT=$(whisper-cli -m "$MODEL_PATH" -f "$TMP_AUDIO" -l uk --prompt "Привіт, це українська мова." -nt -np -t 6 2>/dev/null)
    else
        RAW_TEXT=$(whisper-cli -m "$MODEL_PATH" -f "$TMP_AUDIO" -l en --prompt "This is clean English speech." -nt -np -t 6 2>/dev/null)
    fi
    rm -f "$TMP_AUDIO"

    # Clean bracketed tags, emojis/timestamps and whitespace
    TEXT=$(echo "$RAW_TEXT" | sed -E 's/\[[^]]*\]//g; s/\([^)]*\)//g; s/^[[:space:]]*//; s/[[:space:]]*$//' | tr '\n' ' ' | sed -e 's/[[:space:]]*$//')

    # If Ukrainian mode: safely sanitize any stray non-Ukrainian characters using UTF-8-aware sed (NEVER use tr on UTF-8!)
    if [ "$CURRENT_LANG" = "uk" ]; then
        TEXT=$(echo "$TEXT" | sed 's/[ъЪ]//g; s/[ыЫ]/и/g; s/[эЭ]/е/g; s/[ёЁ]/ьо/g')
    fi

    if [ -n "$TEXT" ]; then
        echo -n "$TEXT" | wl-copy

        ACTIVE_CLASS=$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty' 2>/dev/null | tr '[:upper:]' '[:lower:]')
        sleep 0.1
        case "$ACTIVE_CLASS" in
            kitty|foot|alacritty|wezterm|xst)
                wtype -M ctrl -M shift -k v -m shift -m ctrl
                ;;
            *)
                wtype -M ctrl -k v -m ctrl
                ;;
        esac

        notify-send -t 2500 -a "Whisper" "✅ Transcribed [${CURRENT_LANG^^}]" "$TEXT"
    else
        notify-send -t 1500 -a "Whisper" "ℹ️ No speech detected" "Please try again"
    fi

    update_waybar

else
    # --- START RECORDING ---
    rm -f "$TMP_AUDIO"
    
    LANG_NAME="Ukrainian"
    [ "$CURRENT_LANG" = "en" ] && LANG_NAME="English"
    
    notify-send -t 2000 -a "Whisper" "🎙️ Recording ($LANG_NAME)..." "Speak now (Super+X to finish)"
    
    pw-record --rate 16000 --channels 1 --format s16 "$TMP_AUDIO" &
    echo $! > "$PID_FILE"
    update_waybar
fi
