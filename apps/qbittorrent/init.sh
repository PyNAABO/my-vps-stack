#!/bin/bash
# qBittorrent first-time setup

# Base path relative to script (resolved to absolute path)
BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$(readlink -f "$BASE_DIR/../../config/qbit")"

mkdir -p "$CONFIG_DIR/qBittorrent"

if [ ! -f "$CONFIG_DIR/qBittorrent/qBittorrent.conf" ]; then
  cat <<EOF > "$CONFIG_DIR/qBittorrent/qBittorrent.conf"
[LegalNotice]
Accepted=true
[Preferences]
WebUI\Address=*
WebUI\Port=8080
EOF
  chown -R 1000:1000 "$CONFIG_DIR"
  echo "✅ qBittorrent config initialized"
fi


