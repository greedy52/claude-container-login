#!/bin/bash
# Extract OAuth port and send to host for dynamic forwarding

URL="$1"
LOGFILE="/workspace/oauth.log"
SOCKET="/tmp/browser.sock"

echo "[$(date +%H:%M:%S)] xdg-open called: $URL" >> "$LOGFILE"

# Extract the port from redirect_uri
OAUTH_PORT=$(echo "$URL" | grep -oE "redirect_uri=http%3A%2F%2Flocalhost%3A[0-9]+" | grep -oE "[0-9]+$")

if [ -z "$OAUTH_PORT" ]; then
  echo "[$(date +%H:%M:%S)] ERROR: Could not extract OAuth port" >> "$LOGFILE"
  exit 1
fi

echo "[$(date +%H:%M:%S)] Extracted OAuth port: $OAUTH_PORT" >> "$LOGFILE"

# Send port + URL to host (format: PORT:12345\nURL)
if [ -S "$SOCKET" ]; then
  {
    echo "PORT:$OAUTH_PORT"
    echo "$URL"
  } | socat - UNIX-CONNECT:"$SOCKET" 2>>"$LOGFILE"
  echo "[$(date +%H:%M:%S)] Sent port and URL to host" >> "$LOGFILE"
else
  echo "[$(date +%H:%M:%S)] ERROR: Socket not found" >> "$LOGFILE"
  exit 1
fi
