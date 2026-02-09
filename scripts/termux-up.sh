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

# 3. App Setup & Start
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# --- A. qBittorrent ---
echo "📥 Starting qBittorrent..."
pm2 start qbittorrent-nox --name torrent -- --webui-port=8082 --daemon=false

# --- B. File Browser ---
echo "📂 Starting File Browser..."
# Note: Root is set to phone's Download folder
pm2 start filebrowser --name files -- -p 8081 -a 0.0.0.0 -r /sdcard/Download

# --- C. Uptime Kuma ---
if [ ! -d "$HOME/uptime-kuma" ]; then
    echo "📈 Downloading Uptime Kuma..."
    git clone https://github.com/louislam/uptime-kuma.git ~/uptime-kuma
    cd ~/uptime-kuma
    
    echo "🔨 Building Uptime Kuma (This may take a while)..."
    # Fix for Termux/Android builds
    export CXX=clang++
    export CC=clang
    export PYTHON=python3
    npm run setup
    
    cd "$BASE_DIR"
fi
echo "📈 Starting Uptime Kuma..."
pm2 start "node server/server.js --port=3001" --name uptime --cwd ~/uptime-kuma

# --- D. Custom Apps (WhatsApp Bot, etc.) ---
for app_dir in "$BASE_DIR"/apps/*; do
    if [ -d "$app_dir" ] && [ -f "$app_dir/package.json" ]; then
        app_name=$(basename "$app_dir")
        if [[ "$app_name" != "uptime-kuma" ]]; then # Handled above
            echo "🤖 Starting $app_name..."
            (cd "$app_dir" && npm install)
            pm2 start "$app_dir/index.js" --name "$app_name" --cwd "$app_dir"
        fi
    fi
done

# --- E. Cloudflare Tunnel ---
if [ -f "$HOME/.cloudflared/config.yml" ]; then
    echo "☁️  Starting Cloudflare Tunnel..."
    pm2 start "cloudflared tunnel run" --name tunnel
else
    echo "⚠️  Cloudflare Tunnel not configured. Run 'cloudflared tunnel login' first."
fi

# 4. Finalize
pm2 save
echo "---------------------------------------------------"
echo "🎉 All services are UP!"
echo "👉 Type 'pm2 list' to see status."
echo "👉 Type 'pm2 logs' to see application logs."
echo "👉 Type 'pm2 stop all' to shut down everything."
echo "---------------------------------------------------"
