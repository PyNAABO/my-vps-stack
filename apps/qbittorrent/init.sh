#!/bin/bash
# qBittorrent first-time setup

# Base path relative to script (resolved to absolute path)
BASE_DIR="$(dirname "$(readlink -f "$0")")"
CONFIG_DIR="$(readlink -f "$BASE_DIR/../../config/qbit")"

mkdir -p "$CONFIG_DIR/qBittorrent"

if [ ! -f "$CONFIG_DIR/qBittorrent/qBittorrent.conf" ]; then
  # Create new config with correct paths
  cat <<EOF > "$CONFIG_DIR/qBittorrent/qBittorrent.conf"
[LegalNotice]
Accepted=true
[Preferences]
WebUI\Address=*
WebUI\Port=8080
Downloads\SavePath=/downloads
Downloads\TempPath=/downloads/incomplete
EOF
  echo "✅ qBittorrent config created with correct paths."
else
  # Patch existing config if paths are missing or incorrect
  # Using sed to update or append settings. 
  # Note: qBittorrent.conf is INI-like but sometimes handled strictly. 
  # Safe approach: Check if key exists, if so replace, else append to [Preferences].
  
  CONF_FILE="$CONFIG_DIR/qBittorrent/qBittorrent.conf"
  
  # Function to ensure config key exists
  set_config() {
    key=$1
    value=$2
    if grep -q "^$key=" "$CONF_FILE"; then
      sed -i "s|^$key=.*|$key=$value|" "$CONF_FILE"
    else
      # Append to [Preferences] section if it exists, otherwise just append to end
      if grep -q "\[Preferences\]" "$CONF_FILE"; then
        sed -i "/\[Preferences\]/a $key=$value" "$CONF_FILE"
      else
        echo -e "\n[Preferences]\n$key=$value" >> "$CONF_FILE"
      fi
    fi
  }

  set_config "Downloads\\\SavePath" "/downloads"
  set_config "Downloads\\\TempPath" "/downloads/incomplete"
  
  echo "✅ qBittorrent config patched with correct paths."
fi

# Ensure permissions
chown -R 1000:1000 "$CONFIG_DIR"


