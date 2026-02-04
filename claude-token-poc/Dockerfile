FROM node:20-slim

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Skip onboarding by creating config file
RUN mkdir -p /root/.claude && \
    echo '{"hasCompletedOnboarding": true}' > /root/.claude.json

# Create workspace
RUN mkdir -p /workspace
WORKDIR /workspace

# No browser needed since we're using token auth
ENV CLAUDE_CODE_SKIP_BROWSER=true

CMD ["/bin/bash"]
