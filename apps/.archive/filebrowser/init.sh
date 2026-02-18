#!/bin/bash
# FileBrowser first-time setup

# Base path relative to script (resolved to absolute path)
BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$BASE_DIR/../../config/fb"
# Resolve CONFIG_DIR to absolute path for Docker volumes
ABS_CONFIG_DIR="$(readlink -f "$CONFIG_DIR")"

# Initialize FileBrowser config directory
if [ ! -d "$ABS_CONFIG_DIR" ]; then
  mkdir -p "$ABS_CONFIG_DIR"
  # Set ownership to 1000:1000 so the container can create its own DB
  echo "🔒 Setting FileBrowser permissions..."
  chown -R 1000:1000 "$ABS_CONFIG_DIR"
  echo "✅ FileBrowser directory prepared."
fi

# Automate vps-data setup (prevent Docker from creating it as root)
# Resolve vps-data relative to this script (apps/filebrowser/init.sh -> ../../../vps-data)
DATA_DIR="$(readlink -f "$BASE_DIR/../../../vps-data")"

if [ ! -d "$DATA_DIR" ] || [ "$(stat -c '%u:%g' "$DATA_DIR" 2>/dev/null)" != "1000:1000" ]; then
  echo "📂 Creating/Fixing $DATA_DIR..."
  mkdir -p "$DATA_DIR/downloads"
  chown -R 1000:1000 "$DATA_DIR"
  echo "✅ $DATA_DIR created and ownership set to 1000:1000."
fi


