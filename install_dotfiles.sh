#!/bin/bash

# Change working directory to where the script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "➡️ Starting Hyprland configuration installation from $DOTFILES_DIR..."

# Ensure all necessary base folders exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/share/fonts"

echo "🔧 Setting up ~/.config/hypr directory..."

# Since your repository contains ONLY the hypr folder (the root of the repo = contents of the hypr folder),
# we can just link or copy this repository to ~/.config/hypr

if [ "$DOTFILES_DIR" != "$CONFIG_DIR/hypr" ]; then
    echo "  Symlinking the repository itself as the hypr folder..."
    
    # If there is already an original folder/file that is NOT a symlink, make a backup
    if [ -e "$CONFIG_DIR/hypr" ] && [ ! -L "$CONFIG_DIR/hypr" ]; then
        echo "    [!] Found existing folder. Backing up to: hypr.bak"
        mv "$CONFIG_DIR/hypr" "$CONFIG_DIR/hypr.bak"
    fi
    
    # Create a symbolic link
    ln -sfn "$DOTFILES_DIR" "$CONFIG_DIR/hypr"
else
    echo "  [i] You have already cloned the repository directly to $CONFIG_DIR/hypr!"
    echo "      No symlink needed, configuration is already in place."
fi

# --- 2. SYSTEMD USER UNITS ---
if [ -d "$DOTFILES_DIR/systemd/user" ]; then
    echo "⚙️  Installing systemd user units..."
    mkdir -p "$CONFIG_DIR/systemd/user"
    for unit in "$DOTFILES_DIR/systemd/user"/*; do
        if [ -f "$unit" ]; then
            unit_name=$(basename "$unit")
            echo "  Symlinking systemd unit $unit_name..."
            ln -sfn "$unit" "$CONFIG_DIR/systemd/user/$unit_name"
        fi
    done
    
    echo "  Reloading systemd daemon..."
    systemctl --user daemon-reload
fi

# Any additional files or fonts can also be installed from here,
# if you add them to the same repository. For example:
# if [ -d "$DOTFILES_DIR/fonts" ]; then
#     cp -r "$DOTFILES_DIR/fonts/"* "$HOME/.local/share/fonts/"
#     fc-cache -fv > /dev/null
# fi

echo "✅ Installation completed successfully!"
