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


