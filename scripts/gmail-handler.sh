#!/bin/bash

# Gmail Mailto Handler
# This script strips the 'mailto:' prefix and opens the Gmail compose window in Chromium.

# The input is the full mailto: URL
MAILTO_URL="$1"

# Strip the 'mailto:' prefix if it exists
CLEAN_URL="${MAILTO_URL#mailto:}"

# Construct the Gmail Compose URL
# We use view=cm (Compose) and to= for the recipient
GMAIL_URL="https://mail.google.com/mail/?view=cm&fs=1&tf=1&to=${CLEAN_URL}"

# Open in chromium
# We use --new-window or just open in a new tab
chromium "${GMAIL_URL}"
