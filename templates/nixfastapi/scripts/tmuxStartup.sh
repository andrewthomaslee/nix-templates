#!/usr/bin/env bash

set -e  # Exit on any error
# Immediately exit if REPO_ROOT is not set
if [ -z "$REPO_ROOT" ]; then
    echo "Error: REPO_ROOT is not set. Run this script from the Nix devShell."
    exit 1
fi

SESSION_NAME="nixfastapi-dev"

# Function to handle user choice when session exists
handle_existing_session() {
    echo "Tmux session 🚩'$SESSION_NAME'🚩 already exists!"
    echo ""
    echo "What would you like to do?"
    echo "1) Kill existing session and create new one"
    echo "2) Attach to existing session"
    echo "3) Cancel operation"
    echo ""

    while true; do
        read -p "Enter choice (1/2/3): " choice
        case $choice in
            1)
                echo "Killing existing session..."
                if tmux kill-session -t $SESSION_NAME 2>/dev/null; then
                    echo "Session '$SESSION_NAME' killed successfully."
                    # Continue with script to create new session
                    return 0
                else
                    echo "Failed to kill session '$SESSION_NAME'."
                    exit 1
                fi
                ;;
            2)
                echo "Attaching to existing session..."
                tmux attach-session -t $SESSION_NAME
                exit 0
                ;;
            3)
                echo "Operation cancelled."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# If a session with this name already exists, ask user what to do
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    handle_existing_session
fi

tmux new-session -d -s $SESSION_NAME -n "🌬️Tailwind" -c "$REPO_ROOT"
tmux send-keys -t $SESSION_NAME:0 "tailwindcss -i ./static/input.css -o ./static/output.css --watch" C-m

tmux new-window -t $SESSION_NAME -n "🐍FastAPI" -c "$REPO_ROOT"
tmux send-keys -t $SESSION_NAME:1 "uvicorn main:app --port 8000 --host 0.0.0.0 --reload" C-m

tmux new-window -t $SESSION_NAME -n "🌐Chromium" -c "$REPO_ROOT"
tmux send-keys -t $SESSION_NAME:2 "chromium  --user-data-dir=/tmp/chromium-data --new-window http://0.0.0.0:8000" C-m

echo "Tmux created session ✨'$SESSION_NAME'✨"
tmux attach-session -t $SESSION_NAME
