# Jellyfin

**Media Server**

A free software media system that lets you stream movies, TV shows, music, and more from your VPS.

## 🚀 Usage

- **URL:** `https://play.your-domain.com`
- **Default Credentials:** Setup on first launch (create admin account).

## 💾 Volumes

- `../../config/jellyfin`: Persistent configuration and metadata.
- `/opt/seedbox`: Shared media library (same as qBittorrent downloads).

## 📝 Notes

- Uses LinuxServer.io image for consistent PUID/PGID handling.
- Media directory is shared with qBittorrent — torrented content is instantly available.
