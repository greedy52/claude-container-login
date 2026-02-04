#!/bin/bash
# Host-side server that dynamically opens ports for OAuth callbacks

SOCKET_PATH="$(pwd)/browser.sock"
CONTAINER_PROXY="localhost:8080"

cleanup() {
    echo ""
    echo "Cleaning up..."
    rm -f "$SOCKET_PATH"
    pkill -f "socat.*TCP-LISTEN.*$CONTAINER_PROXY" 2>/dev/null || true
    exit 0
}

trap cleanup SIGINT SIGTERM EXIT

# Clean up old socket
rm -f "$SOCKET_PATH"

echo "Dynamic port forwarding server started"
echo "Socket: $SOCKET_PATH"
echo "Press Ctrl+C to stop"
echo ""

# Create handler inline
handle_request() {
    # Read two lines: PORT:xxxxx and URL
    IFS= read -r port_line
    IFS= read -r url

    timestamp=$(date +%H:%M:%S)

    if [[ "$port_line" =~ ^PORT:([0-9]+)$ ]]; then
        oauth_port="${BASH_REMATCH[1]}"
        echo "[$timestamp] Port forwarding request: $oauth_port"

        if lsof -Pi :$oauth_port -sTCP:LISTEN -t >/dev/null 2>&1; then
            echo "[$timestamp] ERROR: Port $oauth_port already in use!"
        else
            echo "[$timestamp] Opening port $oauth_port → $CONTAINER_PROXY"
            socat TCP-LISTEN:$oauth_port,fork,reuseaddr TCP:$CONTAINER_PROXY &
            sleep 0.3
            echo "[$timestamp] Opening browser"
            open "$url" 2>/dev/null
        fi
    fi
}

export -f handle_request
export CONTAINER_PROXY

# Keep socket open and handle requests
socat UNIX-LISTEN:"$SOCKET_PATH",fork EXEC:"/bin/bash -c handle_request"
