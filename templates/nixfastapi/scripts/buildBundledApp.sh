#!/usr/bin/env bash
set -e  # Exit on any error
# Immediately exit if REPO_ROOT is not set
if [ -z "$REPO_ROOT" ]; then
    echo "Error: REPO_ROOT is not set. Run this script from the Nix devShell."
    exit 1
fi
cd $REPO_ROOT

# Script to build and start the bundledApp
# 1. Build → 2. Run

echo "🚀 Building bundled app..."
nix build .#bundledApp

echo "🌬️ Applying TailwindCSS"
tailwindcss -i ./result/static/input.css -o ./result/static/output.css --minify

echo "🏃 Running bundled app..."
./result/main.py
