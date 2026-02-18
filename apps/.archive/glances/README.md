# Glances

**System Monitoring Tool**

A cross-platform system monitoring tool which provides a real-time overview of your server's resources.

## 🚀 Usage

- **URL:** `https://monitor.your-domain.com`
- **Default Credentials:** None (Open access by default configuration).

## 💾 Volumes

| Host Path | Container Path | Description |
| :-------- | :------------- | :---------- |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker socket (read-only) for container monitoring |

## 🔌 Network

- **Internal Port:** `61208` (Web UI)
- **External Access:** Via `monitor.*` subdomain through Cloudflare Tunnel

## 🐛 Troubleshooting

**Cannot access web interface:**
- Verify the container is running: `docker ps | grep glances`
- Check logs: `docker logs glances`
- Ensure port 61208 is not blocked by firewall

**No container data showing:**
- Verify Docker socket is mounted correctly
- Check permissions on `/var/run/docker.sock`
