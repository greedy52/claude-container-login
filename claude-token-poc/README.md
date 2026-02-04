# Claude Code Docker - OAuth Token Auth

Simple approach using `CLAUDE_CODE_OAUTH_TOKEN` environment variable.

## How it works

1. Get OAuth token from host using `claude setup-token`
2. Pass token to container via environment variable
3. No browser, no port forwarding, no sockets needed

## Setup

```bash
# Build image
make build

# Get your token (on host)
claude setup-token
# Copy the token output

# Set token and run
export CLAUDE_CODE_OAUTH_TOKEN=<your-token>
make run
```

## Pros
- ✅ Simple - just pass environment variable
- ✅ No browser launching needed
- ✅ No port forwarding complexity
- ✅ Works in headless environments

## Cons
- ⚠️ Token expires (need to refresh periodically)
- ⚠️ Manual token management
- ⚠️ Token stored in shell history (use carefully)

## Security Note

The token grants access to your Claude account. Keep it secure:
- Don't commit to git
- Don't share publicly
- Clear shell history after use: `history -c`
