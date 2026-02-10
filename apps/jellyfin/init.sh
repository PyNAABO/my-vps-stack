#!/bin/bash
# Jellyfin first-time setup

BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$(readlink -f "$BASE_DIR/../../config/jellyfin")"

mkdir -p "$CONFIG_DIR"
chown -R 1000:1000 "$CONFIG_DIR"

# Standardize vps-data permissions
# Resolve vps-data relative to this script (apps/jellyfin/init.sh -> ../../../vps-data)
DATA_DIR="$(readlink -f "$BASE_DIR/../../../vps-data")"

echo "📂 Standardizing $DATA_DIR..."
# Create standard media directories
mkdir -p "$DATA_DIR/downloads"
mkdir -p "$DATA_DIR/media/movies"
mkdir -p "$DATA_DIR/media/shows"

# Enforce ownership
chown -R 1000:1000 "$DATA_DIR"
echo "✅ Permissions fixed for $DATA_DIR"


