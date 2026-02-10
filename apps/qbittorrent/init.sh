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
[BitTorrent]
Session\DefaultSavePath=/downloads
Session\TempPath=/downloads/incomplete
EOF
  echo "✅ qBittorrent config created with correct paths."
else
  # Patch existing config if paths are missing or incorrect
  # Using sed to update or append settings. 
  # Note: qBittorrent.conf is INI-like but sometimes handled strictly. 
  # Safe approach: Check if key exists, if so replace, else append to [Preferences].
  
  # Correct configuration for qBittorrent v4.x+
  # Section: [BitTorrent], Key: Session\DefaultSavePath
  
  CONF_FILE="$CONFIG_DIR/qBittorrent/qBittorrent.conf"
  
  # Function to set config key in [BitTorrent] section
  set_bittorrent_config() {
    key=$1
    value=$2
    if grep -q "^$key=" "$CONF_FILE"; then
      sed -i "s|^$key=.*|$key=$value|" "$CONF_FILE"
    else
      if grep -q "\[BitTorrent\]" "$CONF_FILE"; then
        sed -i "/\[BitTorrent\]/a $key=$value" "$CONF_FILE"
      else
        echo -e "\n[BitTorrent]\n$key=$value" >> "$CONF_FILE"
      fi
    fi
  }

  set_bittorrent_config "Session\\\DefaultSavePath" "/downloads"
  set_bittorrent_config "Session\\\TempPath" "/downloads/incomplete"
  
  # Also set legacy keys just in case
  # Function to set config key in [Preferences] section
  set_pref_config() {
     key=$1
     value=$2
     if grep -q "^$key=" "$CONF_FILE"; then
       sed -i "s|^$key=.*|$key=$value|" "$CONF_FILE"
     else
       if grep -q "\[Preferences\]" "$CONF_FILE"; then
         sed -i "/\[Preferences\]/a $key=$value" "$CONF_FILE"
       else
         echo -e "\n[Preferences]\n$key=$value" >> "$CONF_FILE"
       fi
     fi
   }
   set_pref_config "Downloads\\\SavePath" "/downloads"
   set_pref_config "Downloads\\\TempPath" "/downloads/incomplete"
  
  echo "✅ qBittorrent config patched with correct paths (Session & Downloads)."
fi

# Ensure config permissions
chown -R 1000:1000 "$CONFIG_DIR"

# Ensure downloads directory exists and has correct permissions
# Resolve vps-data relative to this script (apps/qbittorrent/init.sh -> ../../../vps-data)
DATA_DIR="$(readlink -f "$BASE_DIR/../../../vps-data")"
DOWNLOADS_DIR="$DATA_DIR/downloads"

if [ ! -d "$DOWNLOADS_DIR" ]; then
  mkdir -p "$DOWNLOADS_DIR"
fi
chown -R 1000:1000 "$DATA_DIR"


