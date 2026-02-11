#!/usr/bin/env bash

# Interactive session startup script
# Launches work apps on specific workspaces after user confirmation

# Rofi menu for confirmation
YES=" Yes"
NO=" No"
CHOICE=$(echo -e "$YES\n$NO" | rofi -dmenu -mesg "Launch work environment?" -theme ~/.config/i3/theme/rofi/confirm.rasi)

if [ "$CHOICE" == "$YES" ]; then
    # 1. Launch Brave on workspace 1
    i3-msg "workspace 1; exec brave"
    sleep 0.5

    # 3. Launch TickTick on workspace 3
    i3-msg "workspace 3; exec ticktick"
    sleep 0.5

    # 4. Launch Telegram (AyuGram) on workspace 4
    i3-msg "workspace 4; exec AyuGram"
    sleep 0.5

    # 5. Launch Noji on workspace 5
    i3-msg "workspace 5; exec brave --app=https://noji.io/decks --name=noji-app"
    sleep 0.5
    
    # 6. Launch Notion on workspace 6
    i3-msg "workspace 6; exec brave --app=https://www.notion.so --name=notion-app"
    sleep 0.5
    
    # Return to workspace 1
    i3-msg "workspace 1"
fi
