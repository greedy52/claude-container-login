# Claude Code Docker OAuth POC

Run Claude Code in Docker with OAuth support using **only one forwarded port** (8080).

## How It Works

1. **Fake xdg-open**: Intercepts browser open requests from Claude Code
2. **URL Rewriting**: Rewrites `localhost:RANDOM_PORT` → `localhost:8080`
3. **Socket Forward**: Sends rewritten URL to host via Unix socket
4. **Dynamic Proxy**: Auto-detects Claude's OAuth server and proxies port 8080 to it
5. **Single Port**: Only port 8080 forwarded from host to container

## Architecture

```
Container                           Host
┌─────────────────────────────┐    ┌──────────────┐
│ Claude Code                 │    │              │
│   ├─ OAuth server :33197    │    │              │
│   └─ calls xdg-open         │    │              │
│         ↓                    │    │              │
│ xdg-open (fake)             │    │              │
│   - Rewrite :33197→:8080    │    │              │
│   - Send via socket ────────┼───→│ host-server  │
│                              │    │   ↓          │
│ OAuth Proxy                 │    │ open browser │
│   :8080 → :33197 ←──────────┼────┤ :8080        │
│                              │    │              │
└─────────────────────────────┘    └──────────────┘
         ↑ Port 8080 forwarded ↓
```

## Quick Start

```bash
# Terminal 1: Start host server
./run.sh server

# Terminal 2: Build and run
./run.sh build
./run.sh run

# Inside container
claude
```

## Files

- `Dockerfile` - Container with fake xdg-open and OAuth proxy
- `host-server.sh` - Host-side server that opens browser
- `run.sh` - Build and run commands

## How OAuth Flow Works

1. Claude Code starts OAuth server on random port (e.g., 33197)
2. OAuth proxy detects this and starts forwarding 8080 → 33197
3. Claude Code calls `xdg-open https://...redirect_uri=localhost:33197...`
4. Fake xdg-open rewrites URL to use :8080
5. Rewritten URL sent to host via socket
6. Host opens browser with localhost:8080
7. Browser connects → Docker forwards to container:8080
8. Container proxy forwards to Claude's server on :33197
9. OAuth completes successfully

## Requirements

- Docker
- socat (`brew install socat` on macOS)
- macOS (uses `open` command)

## Credits

Inspired by Sprites.dev's OAuth handling in sandboxed environments.
