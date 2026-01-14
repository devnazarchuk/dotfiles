#!/bin/bash
# Lock screen by redirecting to LightDM Greeter (Blocking version for xss-lock)
# Dependencies: lightdm, dbus-monitor

# 1. Trigger the lock (switch to greeter)
dm-tool lock

# 2. Identify current session
SESSION_ID=${XDG_SESSION_ID:-$(loginctl | grep "$USER" | awk '{print $1}' | head -n 1)}

# 3. Wait until the session becomes active again
# We listen for PropertiesChanged on our session and check the 'Active' property
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',path='/org/freedesktop/login1/session/_${SESSION_ID}'" | while read -r line; do
    if loginctl show-session "$SESSION_ID" -p Active --value | grep -q "yes"; then
        break
    fi
done

# If session is active, exit script so xss-lock knows we are done
exit 0
