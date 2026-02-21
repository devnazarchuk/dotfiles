#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland Packages #

# edit your packages desired here. 
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in AUR and official Arch Repo

# add packages wanted here
# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Load package lists
hypr_package=($(read_pkg_list "pkg-lists/main.lst"))
hypr_package_2=($(read_pkg_list "pkg-lists/extra.lst"))
hypr_apps=($(read_pkg_list "pkg-lists/apps.lst"))
uninstall=($(read_pkg_list "pkg-lists/conflicting.lst"))
Extra=()

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }




# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

# Determine if apps should be installed
install_apps=0
if [ "$1" == "--install-apps" ]; then
    install_apps=1
fi

# conflicting packages removal
overall_failed=0
printf "\n%s - ${SKY_BLUE}Removing some packages${RESET} as it conflicts with KooL's Hyprland Dots \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
  uninstall_package "$PKG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    overall_failed=1
  fi
done

if [ $overall_failed -ne 0 ]; then
  echo -e "${ERROR} Some packages failed to uninstall. Please check the log."
fi

printf "\n%.0s" {1..1}

# Installation of main components
printf "\n%s - Installing ${SKY_BLUE}KooL's Hyprland necessary packages${RESET} .... \n" "${NOTE}"

pkg_list=("${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}")
if [ $install_apps -eq 1 ]; then
    pkg_list+=("${hypr_apps[@]}")
fi

for PKG1 in "${pkg_list[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}
