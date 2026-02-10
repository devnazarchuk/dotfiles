#!/usr/bin/env bash

# Clipboard Archiver Daemon
# Monitors greenclip and copies items to /home/arch/clipboard/
# Enforces a 300-file/folder limit.

ARCHIVE_DIR="/home/arch/clipboard"
GREENCLIP_CACHE="/tmp/greenclip"
LIMIT=300

mkdir -p "$ARCHIVE_DIR"

# Function to prune old files/folders
prune_archive() {
    local count=$(ls -1d "$ARCHIVE_DIR"/* 2>/dev/null | wc -l)
    if [ "$count" -gt "$LIMIT" ]; then
        local to_delete=$((count - LIMIT))
        # Delete oldest items based on modification time
        ls -1trd "$ARCHIVE_DIR"/* | head -n "$to_delete" | xargs -I {} rm -rf "{}"
    fi
}

# Monitor greenclip history file
LAST_HASH=""

while true; do
    # Get the latest entry from greenclip
    latest=$(greenclip print | head -n 1)
    
    if [ -n "$latest" ]; then
        current_hash=$(echo "$latest" | md5sum | cut -d' ' -f1)
        
        if [ "$current_hash" != "$LAST_HASH" ]; then
            LAST_HASH="$current_hash"
            
            # 1. Handle Images
            if [[ "$latest" == "image/png"* ]]; then
                hash=$(echo "$latest" | grep -oE '\-[0-9]+$')
                if [ -f "$GREENCLIP_CACHE/$hash.png" ]; then
                    cp "$GREENCLIP_CACHE/$hash.png" "$ARCHIVE_DIR/$hash.png"
                    prune_archive
                fi
            else
                # 2. Handle File/Folder Paths
                clean_path=$(echo "$latest" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e "s/^'//" -e "s/'$//" -e 's/^"//' -e 's/"$//')
                
                if [[ "$clean_path" == "~"* ]]; then
                    eval_path="${HOME}${clean_path:1}"
                else
                    eval_path="$clean_path"
                fi
                
                if [[ "$eval_path" == /* ]] && [ -e "$eval_path" ]; then
                    filename=$(basename "$eval_path")
                    # Archive if it's a file or directory
                    if [ -d "$eval_path" ]; then
                        cp -r "$eval_path" "$ARCHIVE_DIR/${current_hash:0:8}_$filename"
                    else
                        cp "$eval_path" "$ARCHIVE_DIR/${current_hash:0:8}_$filename"
                    fi
                    prune_archive
                fi
            fi
        fi
    fi
    sleep 2
done
