#!/usr/bin/env bash
set -e  # Exit on any error

# Simple script to build, load, and run Docker image with Nix
# 1. Build → 2. Load → 3. Run (with auto-cleanup)

echo "🚀 Building Docker image with Nix..."
nix build .#docker

echo "📥 Loading image into Docker..."
IMAGE_TAG=$(docker load < result | grep -o 'nixfastapi-container:[^ ]*')

echo "🏃 Running container on port 8000 (auto-cleanup enabled)..."
docker run --rm -p 8000:8000 "$IMAGE_TAG"
