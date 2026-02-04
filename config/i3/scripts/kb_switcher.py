#!/usr/bin/env python3
import json
import time
import subprocess
import os
import sys

STATE_FILE = "/tmp/kb_switcher_state.json"
LAYOUTS = ["us", "ua", "de", "ru"]
TIMEOUT = 0.75  # Seconds to consider a "new session"

def load_state():
    if not os.path.exists(STATE_FILE):
        return {
            "order": LAYOUTS,
            "last_time": 0,
            "pending_index": 0
        }
    try:
        with open(STATE_FILE, 'r') as f:
            return json.load(f)
    except Exception:
        return {
            "order": LAYOUTS,
            "last_time": 0,
            "pending_index": 0
        }

def save_state(state):
    with open(STATE_FILE, 'w') as f:
        json.dump(state, f)

def set_layout(layout_order):
    # layout_order is a list like ['ua', 'us', 'ru']
    # The first one becomes the active group
    layouts_str = ",".join(layout_order)
    cmd = ["setxkbmap", "-layout", layouts_str, "-option", "grp:alt_shift_toggle"]
    subprocess.run(cmd)

    # Visual feedback
    active_layout = layout_order[0].upper()
    subprocess.run(["dunstify", "-r", "998877", "-t", "1000", f"Layout: {active_layout}"])

def main():
    state = load_state()
    current_time = time.time()
    
    order = state.get("order", LAYOUTS)
    last_time = state.get("last_time", 0)
    pending_index = state.get("pending_index", 0)
    
    # Sanity check: ensure order has same elements as LAYOUTS
    if set(order) != set(LAYOUTS):
        order = LAYOUTS
        pending_index = 0

    is_continuation = (current_time - last_time) < TIMEOUT
    
    if not is_continuation:
        # New session starts.
        # Commit the result of the strictly previous session if needed.
        if pending_index != 0 and pending_index < len(order):
            # Move the previously selected item to front
            item = order.pop(pending_index)
            order.insert(0, item)
        
        # Now start new session
        # Switch to index 1 (next layout)
        new_index = 1
    else:
        # Continuation
        new_index = (pending_index + 1) % len(order)
    
    # Apply
    target_item = order[new_index]
    others = [x for i, x in enumerate(order) if i != new_index]
    effective_order = [target_item] + others
    
    set_layout(effective_order)
    
    # Update state
    state["order"] = order
    state["last_time"] = current_time
    state["pending_index"] = new_index
    
    save_state(state)

if __name__ == "__main__":
    main()
