FROM node:20-slim

# Install SSH server and xdg-utils
RUN apt-get update && apt-get install -y \
    openssh-server \
    xdg-utils \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Copy SSH public key (will be mounted or copied at build time)
# For now, we'll mount at runtime
RUN touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Create config directory
RUN mkdir -p /root/.claude

# Browser wrapper script
RUN mkdir -p /usr/local/bin
COPY browser-wrapper.sh /usr/local/bin/browser-wrapper
RUN chmod +x /usr/local/bin/browser-wrapper

# Set BROWSER env var by default
ENV BROWSER=/usr/local/bin/browser-wrapper

# Add to shell profile
RUN echo 'export BROWSER=/usr/local/bin/browser-wrapper' >> /root/.bashrc && \
    echo 'export BROWSER=/usr/local/bin/browser-wrapper' >> /root/.profile

# Create workspace
RUN mkdir -p /workspace
WORKDIR /workspace

# Expose SSH port
EXPOSE 2222

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D", "-p", "2222"]
