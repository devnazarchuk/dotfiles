#!/usr/bin/env bash

# Robust MPRIS script for Polybar
# Supports multiple players and handles missing metadata

# Get the list of players
players=$(playerctl -l 2>/dev/null)

if [[ -z "$players" ]]; then
    echo " Offline"
    exit 0
fi

# Find the first playing player
active_player=$(playerctl -l 2>/dev/null | head -n 1)
status=$(playerctl status 2>/dev/null)

if [[ "$status" == "Playing" ]]; then
    icon=""
elif [[ "$status" == "Paused" ]]; then
    icon=""
else
    echo " Offline"
    exit 0
fi

# Get metadata
title=$(playerctl metadata title 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)

if [[ -n "$artist" && -n "$title" ]]; then
    echo "$icon $artist - $title"
elif [[ -n "$title" ]]; then
    echo "$icon $title"
else
    # Fallback to player name if no title
    echo "$icon $active_player"
fi
