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
if [ -d "$BASE_DIR/apps/qbittorrent" ]; then
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
else
    echo "⏭️  Skipping qBittorrent (apps/qbittorrent not found)."
fi

# C. Filebrowser (Manual Install)
if [ -d "$BASE_DIR/apps/filebrowser" ]; then
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
    fi
else
    echo "⏭️  Skipping Filebrowser (apps/filebrowser not found)."
fi

# D. Uptime Kuma (Source Install)
if [ -d "$BASE_DIR/apps/uptime-kuma" ]; then
    # Clone if missing
    if [ ! -d "$HOME/uptime-kuma" ]; then
        echo "   Cloning Uptime Kuma..."
        git clone https://github.com/louislam/uptime-kuma.git "$HOME/uptime-kuma"
    else
        echo "✅ Uptime Kuma directory found."
    fi

    # Check for node_modules and install if missing
    if [ ! -d "$HOME/uptime-kuma/node_modules" ]; then
        echo "   Installing Uptime Kuma dependencies (this may take a while)..."
        cd "$HOME/uptime-kuma" || exit
        npm run setup
        cd - || exit
    fi
else
    echo "⏭️  Skipping Uptime Kuma (apps/uptime-kuma not found)."
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

cat <<EOF > ecosystem.config.js
module.exports = {
  apps: [
$(
    if [ -d "$BASE_DIR/apps/qbittorrent" ]; then
        echo "    {"
        echo "      name: \"torrent\","
        echo "      script: \"qbittorrent-nox\","
        echo "      args: \"--webui-port=8082\","
        echo "      interpreter: \"none\","
        echo "      exec_mode: \"fork\""
        echo "    },"
    fi
)
$(
    if [ -d "$BASE_DIR/apps/filebrowser" ]; then
        echo "    {"
        echo "      name: \"files\","
        echo "      script: \"filebrowser\","
        echo "      args: \"-p 8081 -a 0.0.0.0 -r /sdcard/Download -d $HOME/.filebrowser.db\","
        echo "      interpreter: \"none\","
        echo "      exec_mode: \"fork\""
        echo "    },"
    fi
)
$(
    if [ -d "$BASE_DIR/apps/uptime-kuma" ]; then
        echo "    {"
        echo "      name: \"uptime\","
        echo "      script: \"server/server.js\","
        echo "      args: \"--port=3001\","
        echo "      cwd: process.env.HOME + \"/uptime-kuma\","
        echo "      interpreter: \"node\","
        echo "      env: {"
        if [ -f "$ENV_FILE" ]; then
            while IFS='=' read -r key val; do
                [[ \$key =~ ^#.* ]] && continue
                [[ -z \$key ]] && continue
                # Strip carriage return and leading/trailing whitespace
                val=$(echo "$val" | tr -d '\r')
                echo "        \"\$key\": \"\$val\","
            done < "$ENV_FILE"
        fi
        echo "      }"
        echo "    },"
    fi
)
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
                        val=$(echo "$val" | tr -d '\r')
                        echo "        \"\$key\": \"\$val\","
                    done < "$ENV_FILE"
                fi

                # 2. Inject Local .env (overrides global)
                if [ -f "$app_dir/.env" ]; then
                   while IFS='=' read -r key val; do
                       [[ \$key =~ ^#.* ]] && continue
                       [[ -z \$key ]] && continue
                       val=$(echo "$val" | tr -d '\r')
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
                        val=$(echo "$val" | tr -d '\r')
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
$(
    # Check for tunnel configuration
    TUNNEL_ARGS="tunnel run"
    if [ -f "$ENV_FILE" ]; then
        # Check for TUNNEL_TOKEN/TUNNEL_NAME/CLOUDFLARED_TUNNEL_TOKEN in .env
        while IFS='=' read -r key val; do
             key=$(echo "$key" | tr -d '\r')
             val=$(echo "$val" | tr -d '\r')
             if [[ "$key" == "TUNNEL_TOKEN" || "$key" == "CLOUDFLARED_TUNNEL_TOKEN" ]]; then
                 TUNNEL_ARGS="tunnel run --token $val"
                 break
             elif [[ "$key" == "TUNNEL_NAME" ]]; then
                 TUNNEL_ARGS="tunnel run $val"
                 break
             fi
        done < "$ENV_FILE"
    fi

    echo "    {"
    echo "      name: \"tunnel\","
    echo "      script: \"cloudflared\","
    echo "      args: \"$TUNNEL_ARGS\","
    echo "      interpreter: \"none\","
    echo "      exec_mode: \"fork\""
    echo "    }"
)
  ]
};
EOF

# 4. Start Everything
echo "🚀 Starting App Stack..."
echo "ℹ️  Note: If this is the first run, Uptime Kuma might take a moment to start."

# Clear existing PM2 processes to ensure env vars are updated
echo "🧹 Cleaning up old PM2 processes..."
pm2 delete all > /dev/null 2>&1 || true

pm2 start ecosystem.config.js
pm2 save

echo "---------------------------------------------------"
echo "🎉 All services are UP!"
echo "👉 Type 'pm2 list' to see status."
echo "👉 Type 'pm2 logs' to see application logs."
echo "👉 Type 'pm2 stop all' to shut down everything."
echo "---------------------------------------------------"
