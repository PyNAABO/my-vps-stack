#!/bin/bash
# qBittorrent first-time setup

mkdir -p config/qbit/qBittorrent

if [ ! -f config/qbit/qBittorrent/qBittorrent.conf ]; then
  cat <<EOF > config/qbit/qBittorrent/qBittorrent.conf
[LegalNotice]
Accepted=true
[Preferences]
WebUI\Address=*
WebUI\Port=8080
EOF
  echo "✅ qBittorrent config initialized"
fi
