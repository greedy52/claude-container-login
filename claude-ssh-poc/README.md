# Claude Code SSH POC - OAuth via SSH Port Forwarding

Proof of concept for OAuth authentication in containers using SSH port forwarding, similar to sprite.dev's approach.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Container (SSH Daemon)                                  │
│                                                          │
│  Claude Code → Opens OAuth on localhost:34567          │
│             → BROWSER env var calls wrapper             │
│             → Wrapper sends escape sequence             │
│                \033]9999;browser-open;34567;URL\033\\   │
└────────────────────────┬────────────────────────────────┘
                         │ Terminal / SSH
                         ↓
┌─────────────────────────────────────────────────────────┐
│ Host Machine                                            │
│                                                          │
│  Host Script:                                           │
│   1. Detects escape sequence                            │
│   2. Creates SSH port forward:                          │
│      ssh -R 34567:localhost:34567 container             │
│   3. Opens browser → http://localhost:34567             │
└─────────────────────────────────────────────────────────┘
         │
         └─→ Browser completes OAuth
         └─→ Callback flows through SSH tunnel to container
```

## Setup

```bash
# 1. Build
make build

# 2. Start container (auto-generates SSH key if needed)
make start

# 3. SSH in (uses generated ssh_key)
make ssh

# 4. BROWSER env var is already set, test it directly
/usr/local/bin/browser-wrapper "http://localhost:34567/test"
# You should see escape sequence in terminal
```

## How it works

### 1. Browser Wrapper (in container)
- Parses URL and extracts port
- Sends escape sequence: `\033]9999;browser-open;PORT;URL\033\\`
- Exits with success

### 2. Host Listener (simplified in POC)
- Detects escape sequence
- Creates SSH reverse port forward: `ssh -R PORT:localhost:PORT`
- Opens browser on host

### 3. OAuth Flow
- Browser connects to `localhost:PORT` on host
- SSH forwards to container's `localhost:PORT`
- Claude receives OAuth callback
- Authentication complete!

## Testing with Claude Code

```bash
# In container (BROWSER already set)
# Option 1: Use OAuth token
export CLAUDE_CODE_OAUTH_TOKEN=your-token
claude

# Option 2: Use OAuth flow (will trigger browser wrapper)
claude
# Follow onboarding, select OAuth when prompted
```

When Claude opens browser for OAuth:
1. Browser wrapper sends escape sequence
2. Host detects it (manual in this POC)
3. Host creates port forward
4. Browser opens
5. OAuth completes

## Limitations of this POC

1. **Manual escape sequence handling** - Production would integrate with terminal emulator
2. **Simple port forwarding** - Could be optimized with SSH ControlMaster
3. **No automatic cleanup** - Port forwards stay open
4. **Single session** - No multi-user support

## Production Improvements (sprite.dev style)

1. Custom terminal emulator that automatically handles escape sequences
2. SSH ControlMaster for efficient multiplexing
3. Automatic port forward creation/cleanup
4. Browser state synchronization
5. Multi-session support

## Files

- `Dockerfile` - SSH daemon + Claude Code
- `browser-wrapper.sh` - Sends escape sequences (runs in container)
- `host-listener.sh` - Handles forwarding (runs on host)
- `Makefile` - Build and run commands
