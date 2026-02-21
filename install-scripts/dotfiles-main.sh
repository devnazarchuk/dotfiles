#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download from main #


## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions and symlink manager
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi
if ! source "$(dirname "$(readlink -f "$0")")/../lib/dotfile-manager.sh"; then
  echo "Failed to source dotfile-manager.sh"
  exit 1
fi

# Link Function for the dots
deploy_dots() {
    local folder="$1"
    echo "${INFO} Deploying dotfiles from $folder..."
    # For now, we still allow copy.sh but suggest linking for the future
    # If the user wants to transition to linking, they can call safe_link here.
    # We will link the entire .config/hypr if it exists in the dots.
    if [ -d "$folder/.config" ]; then
        link_config_dir "$folder/.config"
    else
        # Fallback to copy.sh if the structure is different
        chmod +x "$folder/copy.sh"
        ./"$folder/copy.sh"
    fi
}

# Check if Hyprland-Dots exists
printf "${NOTE} Cloning and Installing ${SKY_BLUE}KooL's Hyprland Dots${RESET}....\n"

if [ -d Hyprland-Dots ]; then
  cd Hyprland-Dots
  git stash && git pull
  deploy_dots "."
else
  if git clone --depth=1 https://github.com/JaKooLit/Hyprland-Dots; then
    cd Hyprland-Dots || exit 1
    deploy_dots "."
  else
    echo -e "$ERROR Can't download ${YELLOW}KooL's Hyprland-Dots${RESET} . Check your internet connection"
  fi
fi

printf "\n%.0s" {1..2}