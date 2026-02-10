#!/bin/bash
# Jellyfin first-time setup

BASE_DIR="$(dirname "$0")"
CONFIG_DIR="$BASE_DIR/../../config/jellyfin"

mkdir -p "$CONFIG_DIR"
chown -R 1000:1000 "$CONFIG_DIR"

