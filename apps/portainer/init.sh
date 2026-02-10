#!/bin/bash
# Portainer first-time setup

# Base path relative to script
BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$(readlink -f "$BASE_DIR/../../config/portainer")"

mkdir -p "$CONFIG_DIR"
chown -R 1000:1000 "$CONFIG_DIR"

echo "✓ Portainer configuration directory initialized."
