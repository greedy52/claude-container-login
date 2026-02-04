#!/bin/bash
# Browser wrapper - sends requests to host via shared volume

# Extract URL from arguments
URL=""
for arg in "$@"; do
    if [[ "$arg" =~ ^https?:// ]] || [[ "$arg" =~ ^http://localhost:[0-9]+ ]]; then
        URL="$arg"
        break
    fi
done

# Default if no URL found
if [ -z "$URL" ]; then
    URL="about:blank"
fi

# Extract port - check both direct URL and redirect_uri parameter
PORT=""

# First check if URL itself has localhost
if [[ "$URL" =~ localhost:([0-9]+) ]]; then
    PORT="${BASH_REMATCH[1]}"
fi

# If not, check for redirect_uri parameter (URL encoded)
if [ -z "$PORT" ] && [[ "$URL" =~ redirect_uri=([^&]+) ]]; then
    REDIRECT_URI="${BASH_REMATCH[1]}"
    # URL decode the redirect_uri
    DECODED_URI=$(echo "$REDIRECT_URI" | sed 's/%3A/:/g' | sed 's/%2F/\//g')
    # Extract port from decoded URI
    if [[ "$DECODED_URI" =~ localhost:([0-9]+) ]]; then
        PORT="${BASH_REMATCH[1]}"
    fi
fi

# Log the request
echo "[$(date)] Browser open request: URL=$URL PORT=$PORT" >> /tmp/browser-requests.log

# Send escape sequence to terminal (for sprite.dev-like terminals)
if [ -n "$PORT" ]; then
    printf '\033]9999;browser-open;%s;%s\033\\' "$PORT" "$URL"
else
    printf '\033]9999;browser-open;0;%s\033\\' "$URL"
fi

# Write request to shared volume for host listener
# Always send request, even for external URLs (port=0 means no forwarding)
REQUEST_FILE="/browser-requests/request-$(date +%s)-$$.txt"
if [ -n "$PORT" ] && [ "$PORT" != "0" ]; then
    echo "$PORT|$URL" > "$REQUEST_FILE"
else
    echo "0|$URL" > "$REQUEST_FILE"
fi
echo "[$(date)] Wrote request to $REQUEST_FILE" >> /tmp/browser-requests.log

# Exit with success
exit 0
