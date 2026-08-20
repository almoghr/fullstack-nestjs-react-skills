#!/usr/bin/env bash
set -e

# Script: create-github-repos.sh
# Purpose: Creates GitHub repos for backend and client using gh CLI.

TARGET_TYPE="$1" # "org" or "user"
OWNER="$2"       # Org name or GitHub username
PROJECT_NAME="$3" # Base project name
VISIBILITY="$4"  # "private" or "public"

if [ -z "$TARGET_TYPE" ] || [ -z "$OWNER" ] || [ -z "$PROJECT_NAME" ] || [ -z "$VISIBILITY" ]; then
  echo "Usage: $0 <org|user> <owner_name> <project_name> <private|public>"
  exit 1
fi

CLIENT_REPO="${PROJECT_NAME}-client"
BACKEND_REPO="${PROJECT_NAME}-backend"
VISIBILITY_FLAG="--${VISIBILITY}"

GH_BIN="$(command -v gh || echo "")"
if [ -z "$GH_BIN" ] && [ -x "/opt/homebrew/bin/gh" ]; then
  GH_BIN="/opt/homebrew/bin/gh"
elif [ -z "$GH_BIN" ] && [ -x "/usr/local/bin/gh" ]; then
  GH_BIN="/usr/local/bin/gh"
fi

if [ -z "$GH_BIN" ]; then
  echo "Error: GitHub CLI (gh) is not installed or not in PATH."
  echo "Please install gh (e.g. brew install gh) and authenticate with 'gh auth login'."
  exit 1
fi

echo "==> Creating GitHub repositories..."
echo "Client Repo: ${CLIENT_REPO} (${VISIBILITY})"
echo "Backend Repo: ${BACKEND_REPO} (${VISIBILITY})"

if [ "$TARGET_TYPE" = "org" ]; then
  "$GH_BIN" repo create "${OWNER}/${CLIENT_REPO}" ${VISIBILITY_FLAG} --clone=false || echo "Repo ${CLIENT_REPO} might already exist."
  "$GH_BIN" repo create "${OWNER}/${BACKEND_REPO}" ${VISIBILITY_FLAG} --clone=false || echo "Repo ${BACKEND_REPO} might already exist."
else
  "$GH_BIN" repo create "${CLIENT_REPO}" ${VISIBILITY_FLAG} --clone=false || echo "Repo ${CLIENT_REPO} might already exist."
  "$GH_BIN" repo create "${BACKEND_REPO}" ${VISIBILITY_FLAG} --clone=false || echo "Repo ${BACKEND_REPO} might already exist."
fi

echo "==> Repositories created successfully."
