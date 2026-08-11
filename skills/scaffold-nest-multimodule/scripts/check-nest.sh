#!/usr/bin/env bash
set -e

# Script to check Nest CLI availability and output schematics help for multi-module scaffolding

echo "=== Checking Nest CLI ==="

NEST_CMD=""

if command -v nest >/dev/null 2>&1; then
  NEST_CMD="nest"
elif [ -f "./node_modules/.bin/nest" ]; then
  NEST_CMD="./node_modules/.bin/nest"
elif command -v pnpm >/dev/null 2>&1 && pnpm exec nest --version >/dev/null 2>&1; then
  NEST_CMD="pnpm exec nest"
elif command -v npx >/dev/null 2>&1; then
  NEST_CMD="npx nest"
fi

if [ -z "$NEST_CMD" ]; then
  echo '{"status": "error", "message": "Nest CLI (nest) is not installed or found in PATH/node_modules."}'
  exit 1
fi

VERSION=$($NEST_CMD --version 2>/dev/null || echo "unknown")
echo "Nest CLI Version: $VERSION"
echo "Command executable: $NEST_CMD"

echo ""
echo "=== Nest Generate Schematics Help ==="
$NEST_CMD generate --help 2>&1 || true
