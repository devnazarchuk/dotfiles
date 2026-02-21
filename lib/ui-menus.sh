#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# UI Menu Functions #

# Function to select AUR helper
select_aur_helper() {
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        while true; do
            aur_helper=$(whiptail --title "Neither Yay nor Paru is installed" --checklist "Neither Yay nor Paru is installed. Choose one AUR.\n\nNOTE: Select only 1 AUR helper!\nINFO: spacebar to select" 12 60 2 \
                "yay" "AUR Helper yay" "OFF" \
                "paru" "AUR Helper paru" "OFF" \
                3>&1 1>&2 2>&3)

            if [ $? -ne 0 ]; then  
                return 1
            fi

            if [ -z "$aur_helper" ]; then
                whiptail --title "Error" --msgbox "You must select at least one AUR helper to proceed." 10 60 2
                continue 
            fi

            aur_helper=$(echo "$aur_helper" | tr -d '"')

            if [[ $(echo "$aur_helper" | wc -w) -ne 1 ]]; then
                whiptail --title "Error" --msgbox "You must select exactly one AUR helper." 10 60 2
                continue  
            else
                echo "$aur_helper"
                return 0
            fi
        done
    else
        return 0
    fi
}

# Function to show the main options checklist
select_options() {
    local nvidia_detected="$1"
    local input_group_detected="$2"
    local services_running="$3"
    
    local options_command=(
        whiptail --title "Select Options" --checklist "Choose options to install or configure\nNOTE: 'SPACEBAR' to select & 'TAB' key to change selection" 28 85 20
    )

    if [ "$nvidia_detected" == "true" ]; then
        options_command+=(
            "nvidia" "Do you want script to configure NVIDIA GPU?" "OFF"
            "nouveau" "Do you want Nouveau to be blacklisted?" "OFF"
        )
    fi

    if [ "$input_group_detected" == "true" ]; then
        options_command+=(
            "input_group" "Add your USER to input group for some waybar functionality?" "OFF"
        )
    fi

    if [ "$services_running" == "false" ]; then
        options_command+=(
            "sddm" "Install & configure SDDM login manager?" "OFF"
            "sddm_theme" "Download & Install Additional SDDM theme?" "OFF"
        )
    fi

    options_command+=(
        "gtk_themes" "Install GTK themes? (required for Dark/Light function)" "OFF"
        "bluetooth" "Do you want script to configure Bluetooth?" "OFF"
        "thunar" "Do you want Thunar file manager to be installed?" "OFF"
        "quickshell" "Install quickshell for Desktop-Like Overview?" "OFF"
        "xdph" "Install XDG-DESKTOP-PORTAL-HYPRLAND (for screen share)?" "OFF"
        "zsh" "Install zsh shell with Oh-My-Zsh?" "OFF"
        "pokemon" "Add Pokemon color scripts to your terminal?" "OFF"
        "rog" "Are you installing on Asus ROG laptops?" "OFF"
        "apps" "Install heavier optional apps (mpv, yt-dlp, etc)? (~100MB)" "OFF"
        "dots" "Download and install pre-configured KooL Hyprland dotfiles?" "OFF"
    )

    while true; do
        selected_options=$("${options_command[@]}" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then
            return 1
        fi

        if [ -z "$selected_options" ]; then
            whiptail --title "Warning" --msgbox "No options were selected. Please select at least one option." 10 60
            continue
        fi

        selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')
        
        # Confirmation and Dots check logic could stay here or move to a wrapper
        echo "$selected_options"
        return 0
    done
}
