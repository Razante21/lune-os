#!/bin/bash
# Lune OS Update Checker
# Checks if the local git branch is behind origin/main and notifies the user.

REPO_DIR="$HOME/Downloads/lune-os"
cd "$REPO_DIR" || exit 1

# Fetch the latest changes from remote
git fetch origin main

# Compare local HEAD with remote HEAD
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    notify-send "🌙 Lune OS Update" "A new version is available on the main branch. Run 'lune-update' to update." --app-name="Lune OS"
fi
