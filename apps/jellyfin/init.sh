#!/bin/bash
# Jellyfin first-time setup

BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$(readlink -f "$BASE_DIR/../../config/jellyfin")"

mkdir -p "$CONFIG_DIR"
chown -R 1000:1000 "$CONFIG_DIR"


