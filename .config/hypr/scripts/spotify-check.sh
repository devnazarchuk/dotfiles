#!/bin/bash
export PATH="$PATH:~/.spicetify"

if pgrep -x spotify > /dev/null; then
    spicetify refresh -s
fi
