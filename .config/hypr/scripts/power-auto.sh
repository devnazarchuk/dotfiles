#!/usr/bin/env bash

# Отримуємо поточний статус батареї
BAT_STATUS=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
PREV_STATUS=""

check_and_apply() {
    local status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null)
    
    # Запобігаємо повторному спрацьовуванню, якщо статус не змінився
    if [ "$status" = "$PREV_STATUS" ]; then
        return
    fi

    if [ "$status" = "Discharging" ]; then
        powerprofilesctl set power-saver
        notify-send -u low -i preferences-system-power "Power Manager" "Battery mode: Power Saver 󰾆"
    elif [ "$status" = "Charging" ] || [ "$status" = "Full" ] || [ "$status" = "Not charging" ]; then
        powerprofilesctl set performance
        notify-send -u low -i preferences-system-power "Power Manager" "AC Power connected: Performance 󰓅"
    fi

    PREV_STATUS="$status"
}

# Первинна перевірка при старті
check_and_apply

# Моніторинг подій ядра в реальному часі
udevadm monitor --subsystem-match=power_supply | while read -r line; do
    sleep 0.5
    check_and_apply
done
