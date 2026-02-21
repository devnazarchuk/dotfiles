#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Dotfile Symlink Manager #

# Function to safely symlink a file or directory
# Usage: safe_link <source_path> <target_path>
safe_link() {
    local src="$1"
    local dest="$2"
    local backup_dir="$HOME/.config/hypr-backups/$(date +%Y%m%d_%H%M%S)"

    # Create backup directory if it doesn't exist
    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ]; then
            # If it's already a symlink, check if it points to the right place
            if [ "$(readlink -f "$dest")" == "$(readlink -f "$src")" ]; then
                echo "${INFO} Symlink already exists for $(basename "$dest"). skipping..."
                return 0
            fi
        fi

        # Move existing file/dir to backup
        echo "${NOTE} Backing up $(basename "$dest") to $backup_dir"
        mv "$dest" "$backup_dir/"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dest")"

    # Create symlink
    ln -s "$(readlink -f "$src")" "$dest"
    echo "${OK} Linked $(basename "$src") -> $dest"
}

# Function to link a whole directory of configs
link_config_dir() {
    local src_dir="$1"
    local target_base="$HOME/.config"
    
    if [ ! -d "$src_dir" ]; then
        echo "${ERROR} Source directory $src_dir not found."
        return 1
    fi

    for item in "$src_dir"/*; do
        local basename=$(basename "$item")
        safe_link "$item" "$target_base/$basename"
    done
}
