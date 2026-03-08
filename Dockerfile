FROM node:20-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Pre-create Claude config dir and mark onboarding complete so the CLI doesn't
# fail waiting for interactive input on first run in a non-TTY container.
RUN mkdir -p /root/.claude && \
    echo '{"hasCompletedOnboarding":true,"permissions":{"allow":[],"deny":[]}}' \
    > /root/.claude/settings.json

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build
RUN npm prune --omit=dev

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]
