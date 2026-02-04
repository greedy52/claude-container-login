# Claude Code Docker - Amazon Bedrock

Run Claude Code using Amazon Bedrock with IAM role assumption.

## Prerequisites

- AWS account with Bedrock access
- IAM role: `steve-claude-bedrock` with `AmazonBedrockLimitedAccess`
- AWS CLI configured on host

## Setup

```bash
# 1. Build image
make build

# 2. Assume role and get credentials
make assume
# Copy and export the three values

# 3. Test credentials
make test
# Should show: "arn:aws:sts::123456789012:assumed-role/your-claude-bedrock-role/..."

# 4. Run Claude Code
make run
```

## How it works

1. **Assume role** - Gets temporary credentials (valid ~1 hour)
2. **Pass credentials** - Exports to container as environment variables
3. **Enable Bedrock** - `CLAUDE_CODE_USE_BEDROCK=1`
4. **Configure region** - `AWS_REGION=us-east-1`

## Environment Variables

- `AWS_ACCESS_KEY_ID` - Temporary access key
- `AWS_SECRET_ACCESS_KEY` - Temporary secret key
- `AWS_SESSION_TOKEN` - Session token for assumed role
- `AWS_REGION` - Bedrock region (us-east-1)
- `CLAUDE_CODE_USE_BEDROCK=1` - Enable Bedrock
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096` - Recommended for Bedrock
- `MAX_THINKING_TOKENS=1024` - Recommended for Bedrock

## Pros

- ✅ Uses IAM role (no long-term credentials)
- ✅ Pay-per-token pricing
- ✅ Works in corporate environments
- ✅ Credentials auto-expire (secure)

## Cons

- ⚠️ Need to re-assume role when credentials expire (~1 hour)
- ⚠️ Requires Bedrock access in your account
- ⚠️ Additional API costs (separate from claude.ai subscription)
