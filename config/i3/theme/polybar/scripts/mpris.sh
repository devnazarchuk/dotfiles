#!/usr/bin/env bash

# Get all playing/paused players
mapfile -t players < <(playerctl -l 2>/dev/null)

if [[ ${#players[@]} -eq 0 ]]; then
    exit 0
fi

output=""
for p in "${players[@]}"; do
    p_status=$(playerctl -p "$p" status 2>/dev/null)
    if [[ "$p_status" == "Playing" || "$p_status" == "Paused" ]]; then
        title=$(playerctl -p "$p" metadata title 2>/dev/null)
        artist=$(playerctl -p "$p" metadata artist 2>/dev/null)
        
        # Add separator if multiple sources
        if [[ -n "$output" ]]; then output="$output %{F#45475a}|%{F-} "; fi
        
        if [[ -n "$artist" && -n "$title" ]]; then
            output="$output$artist - $title"
        elif [[ -n "$title" ]]; then
            output="$output$title"
        else
            output="$output$p"
        fi
    fi
done

echo "$output"
