#!/bin/bash

# --- Termux-Up: The "Docker-Compose" for Android ---
# This script automates everything to make your phone feel like a VPS.

# Global Variables
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

echo "🚀 Starting Termux-VPS Stack..."

# 1. Dependency Check
echo "📦 Checking dependencies..."

# A. Core Tools & Repos
# Ensure all necessary repos are enabled
pkg install root-repo x11-repo tur-repo -y
pkg update -y

# Install core packages
pkg install git nodejs-lts python make clang binutils -y

# B. qBittorrent (Attempt Install)
if ! command -v qbittorrent-nox &> /dev/null; then
    echo "   Installing qBittorrent..."
    # Try installing from main or TUR repo
    if pkg install qbittorrent-nox -y; then
        echo "✅ qBittorrent installed."
    else
        echo "⚠️  qBittorrent-nox package not found in default/TUR repos."
        echo "   You may need to install it manually or use proot-distro."
    fi
fi

# C. Filebrowser (Manual Install)
if ! command -v filebrowser &> /dev/null; then
    echo "   Installing Filebrowser..."
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash -s -- -b "$PREFIX/bin"
fi

# Initialize FileBrowser DB if missing
if [ ! -f "$HOME/.filebrowser.db" ]; then
    echo "   Initializing FileBrowser database..."
    # Create DB and add admin user
    filebrowser config init -d "$HOME/.filebrowser.db" > /dev/null 2>&1
    filebrowser users add admin adminadmin1234 --perm.admin -d "$HOME/.filebrowser.db" > /dev/null 2>&1
    echo "✅ FileBrowser initialized with default credentials (admin/adminadmin1234)"


# D. Uptime Kuma (Source Install)
if [ ! -d "$HOME/uptime-kuma" ]; then
    echo "   Setting up Uptime Kuma (this may take a while)..."
    git clone https://github.com/louislam/uptime-kuma.git "$HOME/uptime-kuma"
    cd "$HOME/uptime-kuma" || exit
    npm run setup
    cd - || exit
else
    echo "✅ Uptime Kuma directory found."
fi

# E. Global Environment Config (Docker-Compose style)
ENV_FILE="$BASE_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo "⚠️  Creating dummy .env in root directory..."
    echo "# Termux-VPS Stack Configuration" > "$ENV_FILE"
    echo "ALLOWED_GROUP_ID=123456789" >> "$ENV_FILE"
    echo "⚠️  PLEASE EDIT $ENV_FILE with your real settings!"
fi

# F. Cloudflared
pkg install cloudflared -y

# 2. PM2 Global Install (if missing)
if ! command -v pm2 &> /dev/null; then
    echo "🚀 Installing PM2 via npm..."
    npm install -g pm2
fi

# 3b. Install Python Dependencies (if any)
echo "🐍 Checking Python Dependencies..."
for app_dir in "$BASE_DIR"/apps/*; do
    if [ -d "$app_dir" ]; then
        if [ -f "$app_dir/requirements.txt" ]; then
            echo "   Installing requirements for $(basename "$app_dir")..."
            pip install -r "$app_dir/requirements.txt"
        fi
    fi
done

# 3. Create/Update PM2 Ecosystem Config
echo "⚙️  Generating PM2 Ecosystem Config..."

# Check for Cloudflared config
HAS_TUNNEL_CONFIG="false"
if [ -f "$HOME/.cloudflared/config.yml" ]; then
    HAS_TUNNEL_CONFIG="true"
fi

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
      args: "-p 8081 -a 0.0.0.0 -r /sdcard/Download -d $HOME/.filebrowser.db",
      interpreter: "none",
      exec_mode: "fork"
    },
    {
      name: "uptime",
      script: "server/server.js",
      args: "--port=3001",
      cwd: process.env.HOME + "/uptime-kuma",
      interpreter: "node",
      env: {
$(
    # Inject global .env variables into Uptime Kuma too (optional but consistant)
    if [ -f "$ENV_FILE" ]; then
        while IFS='=' read -r key val; do
            [[ \$key =~ ^#.* ]] && continue
            [[ -z \$key ]] && continue
            echo "        \"\$key\": \"\$val\","
        done < "$ENV_FILE"
    fi
)
      }
    },
    // Auto-detect custom apps in /apps/ folder
$(
    for app_dir in "$BASE_DIR"/apps/*; do
        if [ -d "$app_dir" ]; then
            app_name=$(basename "$app_dir")
            
            # Skip if explicitly excluded (e.g., uptime-kuma handled separately)
            if [[ "$app_name" == "uptime-kuma" ]]; then
                continue
            fi

            # --- NODE.JS APP ---
            if [ -f "$app_dir/package.json" ]; then
                echo "    {"
                echo "      name: \"$app_name\","
                echo "      script: \"index.js\","
                echo "      cwd: \"$app_dir\","
                echo "      interpreter: \"node\","
                echo "      env: {"
                
                # 1. Inject Global .env
                if [ -f "$ENV_FILE" ]; then
                    while IFS='=' read -r key val; do
                        [[ \$key =~ ^#.* ]] && continue
                        [[ -z \$key ]] && continue
                        echo "        \"\$key\": \"\$val\","
                    done < "$ENV_FILE"
                fi

                # 2. Inject Local .env (overrides global)
                if [ -f "$app_dir/.env" ]; then
                   while IFS='=' read -r key val; do
                       [[ \$key =~ ^#.* ]] && continue
                       [[ -z \$key ]] && continue
                       echo "        \"\$key\": \"\$val\","
                   done < "$app_dir/.env"
                fi
                
                echo "      },"
                echo "    },"

            # --- PYTHON APP ---
            elif [ -f "$app_dir/requirements.txt" ] || [ -f "$app_dir/bot.py" ] || [ -f "$app_dir/main.py" ]; then
                # Determine script entry point
                py_script="main.py"
                if [ -f "$app_dir/bot.py" ]; then
                    py_script="bot.py"
                fi

                # Install requirements if present (detected during generation, executed during start? No, do it now)
                # Wait, this is inside a subshell for string generation. We should NOT run commands here.
                # Only generate config.
                
                echo "    {"
                echo "      name: \"$app_name\","
                echo "      script: \"$py_script\","
                echo "      cwd: \"$app_dir\","
                echo "      interpreter: \"python3\","
                echo "      env: {"
                 # 1. Inject Global .env
                if [ -f "$ENV_FILE" ]; then
                    while IFS='=' read -r key val; do
                        [[ \$key =~ ^#.* ]] && continue
                        [[ -z \$key ]] && continue
                        echo "        \"\$key\": \"\$val\","
                    done < "$ENV_FILE"
                fi
                echo "      },"
                echo "    },"
                
            else
                # Unknown app type
                echo "    // ⚠️  Skipping $app_name: No package.json or python script found."
            fi
        fi
    done
)
    {
      name: "tunnel",
      script: "cloudflared",
      args: "tunnel run",
      interpreter: "none",
      enabled: $HAS_TUNNEL_CONFIG
    }
  ]
};
EOF

# 4. Start Everything
echo "🚀 Starting App Stack..."
echo "ℹ️  Note: If this is the first run, Uptime Kuma might take a moment to start."

pm2 start ecosystem.config.js
pm2 save

echo "---------------------------------------------------"
echo "🎉 All services are UP!"
echo "👉 Type 'pm2 list' to see status."
echo "👉 Type 'pm2 logs' to see application logs."
echo "👉 Type 'pm2 stop all' to shut down everything."
echo "---------------------------------------------------"
