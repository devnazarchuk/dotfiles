#!/usr/bin/env bash

icon=$1
if playerctl status >/dev/null 2>&1; then
    echo "$icon"
else
    exit 0
fi
