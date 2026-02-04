# Runtime Environment Requirements

Documentation of requirements for running Claude Code in containers.

## System Packages

| Package | Required | Purpose | Notes |
|---------|----------|---------|-------|
| python3 | ✅ | Claude Code runtime dependency | Used by Claude for tool execution |
| pip | ✅ | Python package installer | Required for MCP servers, Python tools |
| curl | ✅ | HTTP requests | Common for API interactions |
| git | ⚠️ | Version control | TBD - verify if Claude needs it |

## Environment Variables

### Bedrock Configuration

| Variable | Required | Example | Purpose |
|----------|----------|---------|---------|
| `CLAUDE_CODE_USE_BEDROCK` | ✅ | `1` | Enable Bedrock integration |
| `AWS_REGION` | ✅ | `us-east-1` | Bedrock region |
| `AWS_ACCESS_KEY_ID` | ✅ | `ASIA...` | AWS credentials |
| `AWS_SECRET_ACCESS_KEY` | ✅ | `...` | AWS credentials |
| `AWS_SESSION_TOKEN` | ⚠️ | `...` | For assumed roles |

### Optional Bedrock Variables

| Variable | Required | Example | Purpose |
|----------|----------|---------|---------|
| `ANTHROPIC_MODEL` | ❌ | `global.anthropic.claude-sonnet-4-5-...` | Override default model |
| `ANTHROPIC_SMALL_FAST_MODEL` | ❌ | `us.anthropic.claude-haiku-4-5-...` | Override Haiku model |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | ❌ | `4096` | Recommended for Bedrock |
| `MAX_THINKING_TOKENS` | ❌ | `1024` | Recommended for Bedrock |
| `DISABLE_PROMPT_CACHING` | ❌ | `1` | Disable caching if not available in region |

## Configuration Files

| Path | Purpose | Notes |
|------|---------|-------|
| `~/.claude/` | Claude Code config directory | Stores credentials, settings |
| `~/.claude.json` | Main config file | Contains `hasCompletedOnboarding`, etc. |
| `~/.claude/.credentials.json` | OAuth credentials | Only for OAuth, not Bedrock |

## Network Requirements

### Python Package Management

| Domain | Port | Purpose | Protocol |
|--------|------|---------|----------|
| `pypi.org` | 443 | Python package index | HTTPS |
| `files.pythonhosted.org` | 443 | Python package downloads | HTTPS |

### Claude Code (OAuth Mode Only)

| Domain | Port | Purpose | Protocol | Notes |
|--------|------|---------|----------|-------|
| `claude.ai` | 443 | OAuth authentication | HTTPS | Not used with Bedrock |
| `api.anthropic.com` | 443 | Claude API endpoint | HTTPS | Not used with Bedrock |

**Note:** When using Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), these domains are not accessed. All communication goes through AWS Bedrock endpoints via AWS credentials.

### Optional Domains

| Domain | Port | Purpose | Notes |
|--------|------|---------|-------|
| `registry.npmjs.org` | 443 | npm packages | If installing Node.js MCP servers |
| `github.com` | 443 | Git repositories | If MCP servers installed from GitHub |
| `raw.githubusercontent.com` | 443 | Raw file downloads | If downloading files from GitHub |

## Verification Commands

```bash
# Check Python and pip
python3 --version
pip --version

# Check curl
curl --version

# Test network connectivity
curl -I https://pypi.org
curl -I https://files.pythonhosted.org
curl -I https://claude.ai
curl -I https://api.anthropic.com
```

## TODO: Research Needed

- [ ] Verify if git is actually required by Claude
- [ ] Check if any Python packages need to be pre-installed
- [ ] Determine minimum Python version
- [ ] Test if Claude works without curl
- [ ] Document any additional system libraries needed
- [ ] Check if npm/node are required for MCP servers
- [ ] Verify Claude's behavior with minimal container

## Notes

- This document focuses on Bedrock setup; OAuth requirements tracked separately
- Requirements may vary based on tools/MCP servers used by Claude
- System package versions not yet documented (need testing)
