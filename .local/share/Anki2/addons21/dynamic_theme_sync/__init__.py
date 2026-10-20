import subprocess
import threading
import time
from aqt import mw, gui_hooks
from aqt.theme import theme_manager

def get_system_color_scheme():
    try:
        cmd = ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]
        res = subprocess.check_output(cmd, stderr=subprocess.DEVNULL).decode().strip()
        return "dark" in res.lower()
    except Exception:
        return False

def update_anki_theme(is_dark):
    if theme_manager.night_mode != is_dark:
        theme_manager.night_mode = is_dark
        theme_manager.apply_style()
        if mw:
            mw.reset()

def dbus_listener():
    last_state = get_system_color_scheme()
    while True:
        time.sleep(3)
        current_state = get_system_color_scheme()
        if current_state != last_state:
            last_state = current_state
            if mw and hasattr(mw, 'taskman'):
                mw.taskman.run_on_main(lambda: update_anki_theme(current_state))

def on_main_window_init():
    update_anki_theme(get_system_color_scheme())
    thread = threading.Thread(target=dbus_listener, daemon=True)
    thread.start()

gui_hooks.main_window_did_init.append(on_main_window_init)
