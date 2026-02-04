#!/bin/bash
# Host-side server that opens URLs sent from container

SOCKET_PATH="$(pwd)/browser.sock"
HANDLER="$(dirname "$0")/browser-handler.sh"

cleanup() {
    echo ""
    echo "Cleaning up..."
    rm -f "$SOCKET_PATH"
    # Kill any lingering socat processes
    pkill -P $$ socat 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# Clean up old socket and kill any process using it
rm -f "$SOCKET_PATH"
lsof "$SOCKET_PATH" 2>/dev/null | tail -n +2 | awk '{print $2}' | xargs -r kill 2>/dev/null || true

echo "Listening for browser requests on $SOCKET_PATH"
echo "Press Ctrl+C to stop"
echo ""

# Use external handler script
socat -v UNIX-LISTEN:"$SOCKET_PATH",fork,reuseaddr EXEC:"$HANDLER"
