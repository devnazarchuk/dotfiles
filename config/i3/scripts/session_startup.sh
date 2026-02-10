#!/usr/bin/env bash

# Interactive session startup script
# Launches work apps on specific workspaces after user confirmation

# Load i3 variables if needed (or just use numbers)
WS_CHAT="3"
WS_LEARN="7"
WS_WORK="8"
WS_TODO="9"

# Rofi menu for confirmation
YES=" Yes"
NO=" No"
CHOICE=$(echo -e "$YES\n$NO" | rofi -dmenu -mesg "Launch work environment?" -theme ~/.config/i3/theme/rofi/confirm.rasi)

if [ "$CHOICE" == "$YES" ]; then
    # Launch AyuGram on 3
    i3-msg "workspace $WS_CHAT; exec AyuGram"
    
    # Launch Noji and Calibre on 7
    i3-msg "workspace $WS_LEARN; exec brave --app=https://noji.io/decks --name=noji-app; exec calibre --detach"
    
    # Launch Notion on 8
    i3-msg "workspace $WS_WORK; exec brave --app=https://www.notion.so --name=notion-app"
    
    # Launch TickTick on 9
    i3-msg "workspace $WS_TODO; exec ticktick"
    
    # Return to workspace 1
    sleep 1
    i3-msg "workspace 1"
fi
