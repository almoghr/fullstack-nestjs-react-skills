#!/usr/bin/env bash
set -e

# Script: set-repo-secrets.sh
# Purpose: Sets GitHub repository secrets via gh CLI securely.

REPO="$1"
KEY="$2"
VALUE="$3"

if [ -z "$REPO" ] || [ -z "$KEY" ]; then
  echo "Usage: $0 <owner/repo> <SECRET_KEY> [SECRET_VALUE]"
  exit 1
fi

GH_BIN="$(command -v gh || echo "")"
if [ -z "$GH_BIN" ] && [ -x "/opt/homebrew/bin/gh" ]; then
  GH_BIN="/opt/homebrew/bin/gh"
elif [ -z "$GH_BIN" ] && [ -x "/usr/local/bin/gh" ]; then
  GH_BIN="/usr/local/bin/gh"
fi

if [ -z "$GH_BIN" ]; then
  echo "Error: gh CLI is not installed or not in PATH."
  exit 1
fi

if [ -z "$VALUE" ]; then
  read -sp "Enter value for $KEY: " VALUE
  echo ""
fi

echo "$VALUE" | "$GH_BIN" secret set "$KEY" --repo "$REPO"
echo "==> Secret '$KEY' successfully set for repo '$REPO'. Value: [REDACTED]"
