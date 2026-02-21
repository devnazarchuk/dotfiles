#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Core Installation Logic Functions #

# Function to execute basic setup (base, pacman, aur helper)
run_basic_setup() {
    local aur_helper="$1"
    local log="$2"

    execute_script "00-base.sh"
    sleep 1
    execute_script "pacman.sh"
    sleep 1

    if [ "$aur_helper" == "paru" ]; then
        execute_script "paru.sh"
    elif [ "$aur_helper" == "yay" ]; then
        execute_script "yay.sh"
    fi
    sleep 1
}

# Function to run Hyprland core installations
run_core_installations() {
    local log="$2"
    local install_apps_flag=""
    
    # Check if apps was selected in the options array
    # This assumes we have access to the options array or pass a flag
    if [[ " ${options[@]} " =~ " apps " ]]; then
        install_apps_flag="--install-apps"
    fi

    echo "${INFO} Installing KooL Hyprland additional packages..." | tee -a "$log"
    execute_script "01-hypr-pkgs.sh" "$install_apps_flag"

    echo "${INFO} Installing pipewire and pipewire-audio..." | tee -a "$log"
    execute_script "pipewire.sh"

    echo "${INFO} Installing necessary fonts..." | tee -a "$log"
    execute_script "fonts.sh"

    echo "${INFO} Installing Hyprland..." | tee -a "$log"
    execute_script "hyprland.sh"
}

# Function to process optional components
process_options() {
    local options=("$@")
    local log="$LOG" # LOG should be inherited or passed
    
    for option in "${options[@]}"; do
        case "$option" in
            sddm)
                echo "${INFO} Installing and configuring SDDM..." | tee -a "$log"
                execute_script "sddm.sh"
                ;;
            nvidia)
                echo "${INFO} Configuring nvidia stuff" | tee -a "$log"
                execute_script "nvidia.sh"
                ;;
            nouveau)
                echo "${INFO} blacklisting nouveau" | tee -a "$log"
                execute_script "nvidia_nouveau.sh"
                ;;
            gtk_themes)
                echo "${INFO} Installing GTK themes..." | tee -a "$log"
                execute_script "gtk_themes.sh"
                ;;
            input_group)
                echo "${INFO} Adding user into input group..." | tee -a "$log"
                execute_script "InputGroup.sh"
                ;;
            quickshell)
                echo "${INFO} Installing quickshell for Desktop Overview..." | tee -a "$log"
                execute_script "quickshell.sh"
                ;;
            xdph)
                echo "${INFO} Installing xdg-desktop-portal-hyprland..." | tee -a "$log"
                execute_script "xdph.sh"
                ;;
            bluetooth)
                echo "${INFO} Configuring Bluetooth..." | tee -a "$log"
                execute_script "bluetooth.sh"
                ;;
            thunar)
                echo "${INFO} Installing Thunar file manager..." | tee -a "$log"
                execute_script "thunar.sh"
                execute_script "thunar_default.sh"
                ;;
            sddm_theme)
                echo "${INFO} Downloading & Installing Additional SDDM theme..." | tee -a "$log"
                execute_script "sddm_theme.sh"
                ;;
            zsh)
                echo "${INFO} Installing zsh with Oh-My-Zsh..." | tee -a "$log"
                execute_script "zsh.sh"
                ;;
            pokemon)
                echo "${INFO} Adding Pokemon color scripts to terminal..." | tee -a "$log"
                execute_script "zsh_pokemon.sh"
                ;;
            rog)
                echo "${INFO} Installing ROG laptop packages..." | tee -a "$log"
                execute_script "rog.sh"
                ;;
            dots)
                echo "${INFO} Installing pre-configured KooL Hyprland dotfiles..." | tee -a "$log"
                execute_script "dotfiles-main.sh"
                ;;
            *)
                echo "Unknown option: $option" | tee -a "$log"
                ;;
        esac
    done
}
