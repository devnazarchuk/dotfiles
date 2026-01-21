#!/bin/bash
# Lock the session by switching to the SDDM Greeter (MineSDDM)

# This will show the actual SDDM login screen with the Minecraft theme
dbus-send --system --print-reply --dest=org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToGreeter

exit 0
