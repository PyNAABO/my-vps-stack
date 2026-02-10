#!/bin/bash
# FileBrowser first-time setup

# Base path relative to script (resolved to absolute path)
BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$BASE_DIR/../../config/fb"
# Resolve CONFIG_DIR to absolute path for Docker volumes
ABS_CONFIG_DIR="$(readlink -f "$CONFIG_DIR")"

mkdir -p "$ABS_CONFIG_DIR"

# Generate settings.json
cat <<EOF > "$ABS_CONFIG_DIR/settings.json"
{
  "port": 80,
  "address": "",
  "database": "/database.db",
  "root": "/srv"
}
EOF

# Initialize FileBrowser DB if missing
if [ ! -s "$ABS_CONFIG_DIR/filebrowser.db" ]; then
  touch "$ABS_CONFIG_DIR/filebrowser.db"
  
  docker run --rm \
    -u 1000:1000 \
    -v "$ABS_CONFIG_DIR/filebrowser.db":/database.db \
    -v "$ABS_CONFIG_DIR/settings.json":/config/settings.json \
    filebrowser/filebrowser config init
    
  echo "🔄 Enforcing admin password (running as root)..."
  
  # Run setup as root to ensure write access
  docker run --rm \
    -v "$ABS_CONFIG_DIR/filebrowser.db":/database.db \
    -v "$ABS_CONFIG_DIR/settings.json":/config/settings.json \
    filebrowser/filebrowser config init
    
  docker run --rm \
    -v "$ABS_CONFIG_DIR/filebrowser.db":/database.db \
    -v "$ABS_CONFIG_DIR/settings.json":/config/settings.json \
    filebrowser/filebrowser users add admin adminadmin1234 --perm.admin || true
    
  docker run --rm \
    -v "$ABS_CONFIG_DIR/filebrowser.db":/database.db \
    -v "$ABS_CONFIG_DIR/settings.json":/config/settings.json \
    filebrowser/filebrowser users update admin --password adminadmin1234
    
  # Fix ownership back to 1000:1000 main container user
  echo "🔒 Securing FileBrowser database permissions..."
  chown -R 1000:1000 "$ABS_CONFIG_DIR"
  chmod 644 "$ABS_CONFIG_DIR/filebrowser.db"
    
  echo "✅ FileBrowser DB initialized with admin user"
  echo "⚠️  WARNING: Default credentials are 'admin' / 'adminadmin1234'. Change them immediately!"
fi


