#!/bin/bash

REPO_DIR=$(pwd)
LAST_HASH=""

echo "🔁 Starting auto-pull watcher in $REPO_DIR..."
echo "Polling every 5 seconds..."

while true; do
  cd "$REPO_DIR" || exit

  # Get current remote HEAD hash
  REMOTE_HASH=$(git ls-remote origin HEAD | awk '{print $1}')

  if [ "$REMOTE_HASH" != "$LAST_HASH" ]; then
    echo "🚨 Detected update. Pulling latest code..."
    git pull --rebase

    if git diff --name-only HEAD@{1} HEAD | grep -q "package.json"; then
      echo "📦 package.json changed. Running npm install..."
      npm install
    fi

    echo "🚀 Restarting Expo server..."
    # Kill any existing expo process
    pkill -f "expo" 2>/dev/null

    # Run dev server in background (tunnel enabled)
    npx expo start --tunnel &
    
    LAST_HASH="$REMOTE_HASH"
  fi

  sleep 5
done
