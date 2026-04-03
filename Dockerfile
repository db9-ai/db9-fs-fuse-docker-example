FROM ubuntu:24.04

# Prevent interactive prompts during package install
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    fuse3 \
    jq \
    nodejs \
    npm \
    git \
  && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Allow non-root FUSE mounts (user_allow_other in fuse.conf)
RUN echo "user_allow_other" >> /etc/fuse.conf

# Install db9 CLI
RUN curl -fsSL https://db9.ai/install | sh

# Verify db9 is on PATH
RUN db9 --version

# Create non-root user and mount point
RUN useradd -m -s /bin/bash user && \
    mkdir -p /mnt/db9fs && \
    chown user:user /mnt/db9fs

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER user

ENTRYPOINT ["/entrypoint.sh"]
