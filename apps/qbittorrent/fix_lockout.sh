#!/bin/bash

# Base path relative to script
BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$(readlink -f "$BASE_DIR/../../config/qbit")"
CONF_FILE="$CONFIG_DIR/qBittorrent/qBittorrent.conf"

echo "🔧 Stopping qBittorrent container..."
docker stop qbittorrent

if [ -f "$CONF_FILE" ]; then
    echo "📂 Backing up config file..."
    cp "$CONF_FILE" "$CONF_FILE.bak"

    echo "🧹 Clearing IP bans and authentication failures..."
    sed -i '/WebUI\\BanList=/d' "$CONF_FILE"
    sed -i '/WebUI\\AuthFailCount=/d' "$CONF_FILE"
    
    echo "🔑 Clearing password to force reset..."
    # Removing the password field will force qBittorrent to generate a temporary password on startup
    sed -i '/WebUI\\Password_PBKDF2=/d' "$CONF_FILE"

    echo "✅ Configuration patched."
else
    echo "❌ Config file not found at $CONF_FILE"
    exit 1
fi

echo "🚀 Starting qBittorrent container..."
docker start qbittorrent

echo "⏳ Waiting for temporary password generation..."
sleep 5

echo "🔎 Searching logs for temporary password..."
docker logs qbittorrent 2>&1 | grep -A 1 "Temporary password"

echo "📝 Done! Use the password above to login."
