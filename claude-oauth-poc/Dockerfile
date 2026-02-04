FROM node:20-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl socat iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Copy HTTP proxy script
COPY oauth-proxy.js /usr/local/bin/oauth-proxy.js
RUN chmod +x /usr/local/bin/oauth-proxy.js

# Create xdg-open that extracts port and sends to host
RUN echo '#!/bin/bash\n\
URL="$1"\n\
LOGFILE="/workspace/oauth.log"\n\
SOCKET="/tmp/browser.sock"\n\
\n\
echo "[$(date +%H:%M:%S)] xdg-open called: $URL" >> "$LOGFILE"\n\
\n\
# Extract port from redirect_uri\n\
OAUTH_PORT=$(echo "$URL" | grep -oE "redirect_uri=http%3A%2F%2Flocalhost%3A[0-9]+" | grep -oE "[0-9]+$")\n\
\n\
if [ -z "$OAUTH_PORT" ]; then\n\
  echo "[$(date +%H:%M:%S)] ERROR: Could not extract OAuth port" >> "$LOGFILE"\n\
  exit 1\n\
fi\n\
\n\
echo "[$(date +%H:%M:%S)] Extracted OAuth port: $OAUTH_PORT" >> "$LOGFILE"\n\
\n\
# Send port + URL to host (format: PORT:12345\\nURL)\n\
if [ -S "$SOCKET" ]; then\n\
  {\n\
    echo "PORT:$OAUTH_PORT"\n\
    echo "$URL"\n\
  } | socat - UNIX-CONNECT:"$SOCKET" 2>>"$LOGFILE"\n\
  echo "[$(date +%H:%M:%S)] Sent port $OAUTH_PORT and URL to host" >> "$LOGFILE"\n\
else\n\
  echo "[$(date +%H:%M:%S)] ERROR: Socket not found" >> "$LOGFILE"\n\
  exit 1\n\
fi' > /usr/local/bin/xdg-open && chmod +x /usr/local/bin/xdg-open

WORKDIR /workspace

# Start HTTP proxy and open shell
CMD node /usr/local/bin/oauth-proxy.js & exec /bin/bash
