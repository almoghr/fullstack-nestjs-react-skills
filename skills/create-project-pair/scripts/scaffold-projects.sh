#!/usr/bin/env bash
set -e

# Script: scaffold-projects.sh
# Purpose: Scaffolds backend (NestJS) and client (React + Vite) locally with chosen package manager.

TARGET_DIR="$1"
OWNER="$2"
PROJECT_NAME="$3"
PKG_MGR="${4:-pnpm}"

if [ -z "$TARGET_DIR" ] || [ -z "$OWNER" ] || [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <target_dir> <owner> <project_name> [package_manager]"
  exit 1
fi

CLIENT_DIR="${TARGET_DIR}/${PROJECT_NAME}-client"
BACKEND_DIR="${TARGET_DIR}/${PROJECT_NAME}-backend"

mkdir -p "$TARGET_DIR"

echo "==> Scaffolding Backend (NestJS)..."
if [ ! -d "$BACKEND_DIR" ]; then
  npx -y @nestjs/cli new "${OWNER}-${PROJECT_NAME}-backend" --package-manager "$PKG_MGR" --directory "$BACKEND_DIR" --skip-git
else
  echo "Backend directory $BACKEND_DIR already exists, skipping."
fi

echo "==> Scaffolding Client (React + Vite + TS)..."
if [ ! -d "$CLIENT_DIR" ]; then
  npx -y create-vite "$CLIENT_DIR" --template react-ts
  cd "$CLIENT_DIR"
  "$PKG_MGR" install
else
  echo "Client directory $CLIENT_DIR already exists, skipping."
fi

echo "==> Project scaffolding completed!"
