#!/bin/bash

# --- Termux-Up: The "Docker-Compose" for Android ---
# This script automates everything to make your phone feel like a VPS.

echo "🚀 Starting Termux-VPS Stack..."

# 1. Dependency Check
echo "📦 Checking dependencies..."

# A. Core Tools
pkg install git nodejs-lts python make clang binutils tur-repo -y
pkg update -y # Refresh after adding tur-repo

# B. qBittorrent (from TUR repo)
if ! command -v qbittorrent-nox &> /dev/null; then
    echo "   Installing qBittorrent..."
    pkg install qbittorrent-nox -y
fi

# C. Filebrowser (Manual Install)
if ! command -v filebrowser &> /dev/null; then
    echo "   Installing Filebrowser..."
    # Install to Termux bin folder
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash -s -- -b "$PREFIX/bin"
fi

# D. Cloudflared & PM2
pkg install cloudflared -y

# 2. PM2 Global Install (if missing)
if ! command -v pm2 &> /dev/null; then
    echo "🚀 Installing PM2 via npm..."
    npm install -g pm2
fi

# 3. Create/Update PM2 Ecosystem Config
echo "⚙️  Generating PM2 Ecosystem Config..."

cat <<EOF > ecosystem.config.js
module.exports = {
  apps: [
    {
      name: "torrent",
      script: "qbittorrent-nox",
      args: "--webui-port=8082",
      interpreter: "none", // Binary mode
      exec_mode: "fork"
    },
    {
      name: "files",
      script: "filebrowser",
      args: "-p 8081 -a 0.0.0.0 -r /sdcard/Download",
      interpreter: "none",
      exec_mode: "fork"
    },
    {
      name: "uptime",
      script: "server/server.js",
      args: "--port=3001",
      cwd: process.env.HOME + "/uptime-kuma",
      interpreter: "node"
    },
    // Auto-detect custom apps in /apps/ folder
$(
    BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
    for app_dir in "$BASE_DIR"/apps/*; do
        if [ -d "$app_dir" ] && [ -f "$app_dir/package.json" ]; then
            app_name=$(basename "$app_dir")
            if [[ "$app_name" != "uptime-kuma" ]]; then
                echo "    {"
                echo "      name: \"$app_name\","
                echo "      script: \"index.js\","
                echo "      cwd: \"$app_dir\","
                echo "      interpreter: \"node\""
                echo "    },"
            fi
        fi
    done
)
    {
      name: "tunnel",
      script: "cloudflared",
      args: "tunnel run",
      interpreter: "none",
      enabled: $(if [ -f "$HOME/.cloudflared/config.yml" ]; then echo "true"; else echo "false"; fi)
    }
  ]
};
EOF

# 4. Start Everything
echo "🚀 Starting App Stack..."
pm2 start ecosystem.config.js
pm2 save

# 4. Finalize
pm2 save
echo "---------------------------------------------------"
echo "🎉 All services are UP!"
echo "👉 Type 'pm2 list' to see status."
echo "👉 Type 'pm2 logs' to see application logs."
echo "👉 Type 'pm2 stop all' to shut down everything."
echo "---------------------------------------------------"
