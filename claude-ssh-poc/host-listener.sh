#!/bin/bash
# Host-side script that monitors shared volume for browser requests

SSH_HOST="${1:-localhost}"
SSH_PORT="${2:-2222}"
SSH_USER="${3:-root}"
SSH_KEY="${4:-ssh_key}"
WATCH_DIR="browser-requests"

echo "[$(date +%T)] SSH OAuth Port Forwarder Started"
echo "[$(date +%T)] Monitoring: $WATCH_DIR/"
echo "[$(date +%T)] SSH Target: $SSH_USER@$SSH_HOST:$SSH_PORT"
echo ""

# Track processed files to avoid duplicates (use simple list for bash 3.2 compatibility)
PROCESSED_FILES=""

# Function to check if file was processed
is_processed() {
    [[ "$PROCESSED_FILES" == *"|$1|"* ]]
}

# Function to mark file as processed
mark_processed() {
    PROCESSED_FILES="${PROCESSED_FILES}|$1|"
}

# Function to handle port forwarding and browser opening
handle_browser_request() {
    local port=$1
    local url=$2

    echo "[$(date +%T)] Browser request: port=$port url=$url"

    if [ -z "$port" ] || [ "$port" = "0" ]; then
        echo "[$(date +%T)]   → No port forwarding needed"
        open "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null
        return
    fi

    # Check if port forward already exists
    if lsof -i ":$port" -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "[$(date +%T)]   → Port $port already forwarded"
    else
        echo "[$(date +%T)]   → Creating SSH port forward: localhost:$port → container:$port"

        # Start SSH port forward in background
        # -L = Local forward: host:port → container:port
        SSH_OUTPUT=$(ssh -i "$SSH_KEY" -f -N \
            -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o ServerAliveInterval=60 \
            -o ExitOnForwardFailure=yes \
            -p "$SSH_PORT" \
            -L "$port:localhost:$port" \
            "$SSH_USER@$SSH_HOST" 2>&1)
        SSH_EXIT=$?

        if [ $SSH_EXIT -eq 0 ]; then
            sleep 1  # Give it time to establish
            echo "[$(date +%T)]   ✓ Port forward active"
        else
            echo "[$(date +%T)]   ✗ Port forward failed (exit code: $SSH_EXIT)"
            echo "[$(date +%T)]   Error output: $SSH_OUTPUT"
            return
        fi
    fi

    # Open browser
    echo "[$(date +%T)]   → Opening browser"
    open "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null
}

# Create watch directory if it doesn't exist
mkdir -p "$WATCH_DIR"

# Monitor directory for new request files
echo "[$(date +%T)] Ready. Waiting for browser requests..."
echo ""

while true; do
    for file in "$WATCH_DIR"/request-*.txt; do
        # Skip if no files match
        [ -e "$file" ] || continue

        # Skip if already processed
        is_processed "$file" && continue

        # Mark as processed
        mark_processed "$file"

        # Read and process request
        if [ -f "$file" ]; then
            REQUEST=$(cat "$file")
            PORT=$(echo "$REQUEST" | cut -d'|' -f1)
            URL=$(echo "$REQUEST" | cut -d'|' -f2)

            if [[ "$PORT" =~ ^[0-9]+$ ]]; then
                handle_browser_request "$PORT" "$URL"
            fi

            # Clean up request file
            rm -f "$file"
        fi
    done

    sleep 0.5
done
