#!/usr/bin/env bash
set -e

# Script: generate-cd-workflow.sh
# Purpose: Generates a fully generic GitHub Actions CD workflow (.github/workflows/cd.yml)
# for deploying to various hosting platforms (Vercel, Fly.io, Render, Railway, Docker).

TARGET_DIR="${1:-.}"
PLATFORM="${2:-vercel}" # Options: vercel, fly, render, railway, docker

WORKFLOW_DIR="${TARGET_DIR}/.github/workflows"
WORKFLOW_FILE="${WORKFLOW_DIR}/cd.yml"

mkdir -p "$WORKFLOW_DIR"

cat << 'EOF' > "$WORKFLOW_FILE"
name: CD Pipeline

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    name: Deploy Application
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v7.0.1
EOF

case "$PLATFORM" in
  vercel)
    cat << 'EOF' >> "$WORKFLOW_FILE"

      - name: Install Vercel CLI
        run: npm install --global vercel@latest

      - name: Pull Vercel Environment Information
        run: vercel pull --yes --environment=production --token=${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}

      - name: Build Project Artifacts
        run: vercel build --prod --token=${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}

      - name: Deploy Project Artifacts to Vercel
        run: vercel deploy --prebuilt --prod --token=${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
EOF
    ;;
  fly)
    cat << 'EOF' >> "$WORKFLOW_FILE"

      - name: Setup Flyctl
        uses: superfly/flyctl-actions/setup-flyctl@master

      - name: Deploy to Fly.io
        run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
EOF
    ;;
  render)
    cat << 'EOF' >> "$WORKFLOW_FILE"

      - name: Trigger Render Deploy Hook
        run: |
          if [ -z "${{ secrets.RENDER_DEPLOY_HOOK_URL }}" ]; then
            echo "Error: RENDER_DEPLOY_HOOK_URL secret is not set."
            exit 1
          fi
          curl -X POST "${{ secrets.RENDER_DEPLOY_HOOK_URL }}"
EOF
    ;;
  railway)
    cat << 'EOF' >> "$WORKFLOW_FILE"

      - name: Install Railway CLI
        run: npm i -g @railway/cli

      - name: Deploy to Railway
        run: railway up --detach
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
EOF
    ;;
  docker)
    cat << 'EOF' >> "$WORKFLOW_FILE"

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata for Docker
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ghcr.io/${{ github.repository }}
          tags: |
            type=sha
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and Push Docker image
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
EOF
    ;;
  *)
    echo "Unknown platform: $PLATFORM. Supported platforms: vercel, fly, render, railway, docker"
    exit 1
    ;;
esac

echo "==> Generic CD workflow for '$PLATFORM' generated at ${WORKFLOW_FILE}"
