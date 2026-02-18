# qBittorrent

**BitTorrent Client**

A free and reliable P2P BitTorrent client.

## 🚀 Usage

- **URL:** `https://seed.your-domain.com`
- **Default Credentials:** Randomized on first startup. Check logs:
  ```bash
  docker logs qbittorrent
  ```

## 💾 Volumes

- `config/qbit`: Configuration files (INI config, logs).
- `/downloads`: Mapped to `../vps-data/downloads` (shared with FileBrowser).

## 🔧 Troubleshooting

If locked out of the WebUI:

```bash
bash apps/qbittorrent/fix_lockout.sh
```

This resets the password and prints a temporary one from the logs.
