#!/usr/bin/env bash

# Dynamic Installer for Dotfiles
# Automatically installs all folders found in ./config/ to ~/.config/

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_SRC_DIR="$DOTFILES_DIR/config"
HOME_CONFIG_DIR="$HOME/.config"

echo ":: Starting Installation..."

# ensure ~/.config exists
mkdir -p "$HOME_CONFIG_DIR"

# 1. Cleanup Old Backups
echo ":: Checking for old backups..."
limit=3
pruned=false
to_prune_list=()

# Find unique base names that have at least one backup folder
base_names=$(find "$HOME_CONFIG_DIR" -maxdepth 1 -name "*_backup*" | sed -E 's/(.*)(_backup.*)/\1/' | xargs -n1 basename | sort -u)

for base in $base_names; do
    backups_count=$(ls -dt "$HOME_CONFIG_DIR/${base}"_backup* 2>/dev/null | wc -l)
    if [ "$backups_count" -gt "$limit" ]; then
        to_prune_list+=("$base")
    fi
done

if [ ${#to_prune_list[@]} -gt 0 ]; then
    echo ":: Found folders with more than $limit backups: ${to_prune_list[*]}"
    read -p "   Prune all to $limit recent backups? [A]ll / [M]anual / [n]o: " global_choice
    
    case "$global_choice" in
        [Aa]*)
            for base in "${to_prune_list[@]}"; do
                backups=$(ls -dt "$HOME_CONFIG_DIR/${base}"_backup* 2>/dev/null)
                to_delete=$(echo "$backups" | tail -n +$((limit + 1)))
                for item in $to_delete; do
                    echo "   Deleting old backup: $(basename "$item")"
                    rm -rf "$item"
                done
            done
            pruned=true
            ;;
        [Mm]*)
            for base in "${to_prune_list[@]}"; do
                backups=$(ls -dt "$HOME_CONFIG_DIR/${base}"_backup* 2>/dev/null)
                count=$(echo "$backups" | wc -l)
                read -p "   Keep only 3 most recent for '$base'? ($count found) [y/N] " choice
                if [[ "$choice" =~ ^[Yy]$ ]]; then
                    to_delete=$(echo "$backups" | tail -n +$((limit + 1)))
                    for item in $to_delete; do
                        echo "   Deleting old backup: $(basename "$item")"
                        rm -rf "$item"
                    done
                    pruned=true
                fi
            done
            ;;
        *)
            echo "   Skipping cleanup."
            ;;
    esac
fi
[ "$pruned" = true ] && echo ":: Pruning complete."

# 2. Determine Backup Suffix for CURRENT installation
suffix="_backup"
counter=0
while true; do
    conflict_found=false
    # Check if backup would conflict for any directory in config/
    for entry in "$CONFIG_SRC_DIR"/*; do
        basename=$(basename "$entry")
        target="$HOME_CONFIG_DIR/$basename"
        backup_target="${target}${suffix}"
        
        if [ -e "$backup_target" ]; then
            conflict_found=true
            break
        fi
    done
    
    if [ "$conflict_found" = true ]; then
        counter=$((counter + 1))
        suffix="_backup${counter}"
    else
        break
    fi
done
echo ":: Backup suffix for this session: '$suffix'"

# 3. Recursive Installation Function
# This function handles granular backup and replacement
# Logic: If item is a file, backup and replace. If directory, recurse.
install_item() {
    local src="$1"
    local base_dest="$2"
    
    for entry in "$src"/*; do
        # Handle hidden files if any (though usually not in these dirs)
        [ -e "$entry" ] || continue
        
        local name=$(basename "$entry")
        local dest_path="$base_dest/$name"
        
        if [ -d "$entry" ]; then
            # If it's a directory, we don't want to replace the whole thing
            # We want to ensure the target exists and then recurse into it
            mkdir -p "$dest_path"
            install_item "$entry" "$dest_path"
        else
            # If it's a file, check if it needs replacement
            if [ -e "$dest_path" ]; then
                if cmp -s "$entry" "$dest_path"; then
                    continue
                fi
                echo "   Backing up: $dest_path -> ${dest_path}${suffix}"
                mv "$dest_path" "${dest_path}${suffix}"
            fi
            echo "   Copying: $entry -> $dest_path"
            cp "$entry" "$dest_path"
        fi
    done
}

# 4. Process .config directory
echo ":: Processing config/ directory..."
install_item "$CONFIG_SRC_DIR" "$HOME_CONFIG_DIR"

# 5. Process local directory
if [ -d "$DOTFILES_DIR/local" ]; then
    echo ":: Processing local/ directory..."
    mkdir -p "$HOME/.local"
    install_item "$DOTFILES_DIR/local" "$HOME/.local"
fi

update-desktop-database ~/.local/share/applications 2>/dev/null
fc-cache -fv

echo ":: Installation Complete!"
echo ":: Make sure to log out and select Hyprland from your session manager."
