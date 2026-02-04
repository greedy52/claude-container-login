# Claude Code Container Authentication

Proof-of-concept approaches for authenticating Claude Code in containerized environments.

## The Challenge

Claude Code requires OAuth authentication which opens a browser. In containers, this fails because:
- No browser available
- Container's `localhost` ≠ host's `localhost`
- OAuth callback can't reach the container

## Approaches

### 1. OAuth Token ([`oauth-token-poc/`](oauth-token-poc/))

Use a pre-generated OAuth token to bypass browser authentication.

**How it works:** Generate token once with `claude setup-token`, pass as `CLAUDE_CODE_OAUTH_TOKEN` environment variable. Token valid for 1 year.

**Alternative:** Use `ANTHROPIC_API_KEY` instead (not tested, but setup is identical).

[→ See detailed setup](oauth-token-poc/README.md)

---

### 2. Amazon Bedrock ([`bedrock-poc/`](bedrock-poc/))

Use AWS Bedrock instead of OAuth authentication.

**How it works:** Authenticate with AWS IAM credentials, set `CLAUDE_CODE_USE_BEDROCK=1`. No OAuth needed.

[→ See detailed setup](bedrock-poc/README.md)

---

### 3. OAuth Proxy ([`oauth-proxy-poc/`](oauth-proxy-poc/))

Dynamic port forwarding with socket-based browser launching.

**How it works:** OAuth proxy detects port, communicates with host via socket, host opens port and browser.

**Status:** ⚠️ Incomplete implementation

[→ See detailed setup](oauth-proxy-poc/README.md)

---

### 4. SSH Port Forwarding ([`ssh-poc/`](ssh-poc/))

SSH with dynamic port forwarding for OAuth callbacks.

**How it works:** Browser wrapper intercepts OAuth URL, extracts port from redirect_uri, host creates SSH tunnel dynamically, browser completes OAuth through tunnel.

[→ See detailed setup](ssh-poc/README.md)

---

## Quick Start

Each POC includes:
- `Dockerfile` - Container setup
- `Makefile` - Build and run commands
- `README.md` - Detailed instructions

```bash
# Example: SSH approach
cd ssh-poc/
make build
make start
make ssh
# Inside container: claude
```

## Files

```
claude-container-login/
├── README.md
├── oauth-token-poc/      # Token-based auth
├── bedrock-poc/          # AWS Bedrock auth
├── oauth-proxy-poc/      # Socket + port forwarding (incomplete)
└── ssh-poc/              # SSH + dynamic forwarding
```

## License

MIT
