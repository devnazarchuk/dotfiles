#!/usr/bin/env bash

## Copyright (C) 2020-2025 Aditya Shakya <adi1090x@gmail.com>

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# Use ls as a more reliable way to find the backlight card
CARD="$(ls -1 /sys/class/backlight/ | head -n1)"
INTERFACE="$(ip link | awk '/state UP/ {print $2}' | tr -d :)"
BAT="$(ls -1 /sys/class/power_supply/ | grep BAT | head -n1)"
RFILE="$DIR/.module"

# Fix backlight and network modules
fix_modules() {
	if [[ -z "$CARD" ]]; then
		sed -i -e 's/brightness/bna/g' "$DIR"/config.ini
		sed -i -e 's/backlight/bna/g' "$DIR"/config.ini
	fi

	if [[ -z "$BAT" ]]; then
		sed -i -e 's/battery/btna/g' "$DIR"/config.ini
	fi

	if [[ "$INTERFACE" == e* ]]; then
		sed -i -e 's/network/ethernet/g' "$DIR"/config.ini
	fi
}

# Launch the bar
launch_bar() {
	# Terminate already running bar instances
	killall -q polybar

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

	# Launch the bar
	for mon in $(polybar --list-monitors | cut -d":" -f1); do
		MONITOR=$mon polybar -q main -c "$DIR"/config.ini &
	done
}

# Execute functions
if [[ ! -f "$RFILE" ]]; then
	fix_modules
	touch "$RFILE"
fi	
launch_bar
