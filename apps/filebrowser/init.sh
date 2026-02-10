#!/bin/bash
# FileBrowser first-time setup

# Base path relative to script
BASE_DIR="$(dirname "$0")"
CONFIG_DIR="$BASE_DIR/../../config/fb"

mkdir -p "$CONFIG_DIR"

# Generate settings.json
cat <<EOF > "$CONFIG_DIR/settings.json"
{
  "port": 80,
  "address": "",
  "database": "/database.db",
  "root": "/srv"
}
EOF

# Initialize FileBrowser DB if missing
if [ ! -s "$CONFIG_DIR/filebrowser.db" ]; then
  touch "$CONFIG_DIR/filebrowser.db"
  chown 1000:1000 "$CONFIG_DIR/filebrowser.db" "$CONFIG_DIR/settings.json"
  chmod 644 "$CONFIG_DIR/filebrowser.db"
  
  docker run --rm \
    -u 1000:1000 \
    -v "$CONFIG_DIR/filebrowser.db":/database.db \
    -v "$CONFIG_DIR/settings.json":/config/settings.json \
    filebrowser/filebrowser config init
    
  docker run --rm \
    -u 1000:1000 \
    -v "$CONFIG_DIR/filebrowser.db":/database.db \
    -v "$CONFIG_DIR/settings.json":/config/settings.json \
    filebrowser/filebrowser users add admin adminadmin1234 --perm.admin
    
  echo "✅ FileBrowser DB initialized with admin user"
  echo "⚠️  WARNING: Default credentials are 'admin' / 'adminadmin1234'. Change them immediately!"
fi

