#!/bin/sh
set -e

# Write Google Calendar credentials from env vars to disk
if [ -n "$GOOGLE_OAUTH_CREDENTIALS_JSON" ]; then
  mkdir -p /app/credentials
  echo "$GOOGLE_OAUTH_CREDENTIALS_JSON" > /app/credentials/client_secret.json
fi

if [ -n "$GOOGLE_CALENDAR_TOKENS_JSON" ]; then
  mkdir -p /root/.config/google-calendar-mcp
  echo "$GOOGLE_CALENDAR_TOKENS_JSON" > /root/.config/google-calendar-mcp/tokens.json
fi

# Clone or update the context repo (the-mistress)
if [ -n "$CONTEXT_REPO" ]; then
  # Inject GitHub token into HTTPS URL if provided
  if [ -n "$GITHUB_TOKEN" ]; then
    CLONE_URL=$(echo "$CONTEXT_REPO" | sed "s|https://|https://$GITHUB_TOKEN@|")
  else
    CLONE_URL="$CONTEXT_REPO"
  fi

  if [ -d /app/workspace/.git ]; then
    git -C /app/workspace pull --ff-only
  else
    git clone "$CLONE_URL" /app/workspace
  fi
fi

# Copy MCP config into place
cp /app/mcp-servers.example.json /app/mcp-servers.json

exec node dist/index.js
