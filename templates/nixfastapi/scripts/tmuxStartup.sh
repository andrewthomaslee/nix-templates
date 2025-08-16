#!/usr/bin/env bash

set -e  # Exit on any error
# Immediately exit if REPO_ROOT is not set
if [ -z "$REPO_ROOT" ]; then
    echo "Error: REPO_ROOT is not set. Run this script from the Nix devShell."
    exit 1
fi

SESSION_NAME="nixfastapi-dev"

# If a session with this name already exists, do nothing
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo "Tmux session 🚩'$SESSION_NAME'🚩 already exists."
    exit 0
fi

tmux new-session -d -s $SESSION_NAME -n "🌬️Tailwind" -c "$REPO_ROOT"
tmux send-keys -t $SESSION_NAME:0 "tailwindcss -i ./static/input.css -o ./static/output.css --watch" C-m

tmux new-window -t $SESSION_NAME -n "🐍FastAPI" -c "$REPO_ROOT"
tmux send-keys -t $SESSION_NAME:1 "uvicorn main:app --port 8000 --host 0.0.0.0 --reload" C-m

tmux new-window -t $SESSION_NAME -n "🌐Chromium" -c "$REPO_ROOT"
tmux send-keys -t $SESSION_NAME:2 "chromium http://0.0.0.0:8000" C-m

echo "Tmux created session ✨'$SESSION_NAME'✨"
tmux attach-session -t $SESSION_NAME