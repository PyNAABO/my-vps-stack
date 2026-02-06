# 📦 Ultimate Seedbox Guide

## The Battle-Tested, Error-Free VPS Setup

> [!IMPORTANT]
> **Save this guide.** This method sets up **qBittorrent** (Downloader) and **FileBrowser** (Manager/Streamer) in under 2 minutes. It includes a "Surgical Method" to avoid common permission pitfalls.

### 📋 Prerequisites

- A fresh VPS (Ubuntu/Debian recommended).
- **Docker** & **Docker Compose** installed.
- Root access.

---

### Phase 1: The Foundation 🏗️

We manually create the file structure and database first. This is the **"Surgical Method"** to prevent Docker permission errors before they happen.

**Run this entire block in your terminal:**

```bash
# 1. Create directory structure with proper ownership
sudo mkdir -p /opt/seedbox/downloads
sudo mkdir -p /opt/seedbox/config
sudo chown -R 1000:1000 /opt/seedbox

# 2. Create the FileBrowser database file
touch /opt/seedbox/filebrowser.db

# 3. CRITICAL: Grant wide permissions so the container can write to it
chmod 666 /opt/seedbox/filebrowser.db

# 4. Initialize the database schema
docker run --rm \
  -v /opt/seedbox/filebrowser.db:/database.db \
  filebrowser/filebrowser config init

# 5. Create the admin user (User: admin / Pass: adminadmin1234)
docker run --rm \
  -v /opt/seedbox/filebrowser.db:/database.db \
  filebrowser/filebrowser users add admin adminadmin1234 --perm.admin
```

> [!TIP]
> You can change `adminadmin1234` in the command above to your preferred password.

> [!CAUTION]
> **Change the default password immediately after first login!** The credentials shown here are publicly documented and must be updated to secure your seedbox.

---

### Phase 2: Deployment (Docker Compose) 🚀

We use `docker-compose` for a robust, restart-proof setup.

1. **Create the Compose file:**

   ```bash
   nano /opt/seedbox/docker-compose.yml
   ```

2. **Paste the following configuration:**

   ```yaml
   services:
     qbittorrent:
       image: lscr.io/linuxserver/qbittorrent:latest
       container_name: qbittorrent
       environment:
         - PUID=1000
         - PGID=1000
         - TZ=Etc/UTC
         - WEBUI_PORT=8080
       volumes:
         - /opt/seedbox/config:/config
         - /opt/seedbox/downloads:/downloads
       ports:
         - 8080:8080
         - 6881:6881
         - 6881:6881/udp
       restart: unless-stopped

     filebrowser:
       image: filebrowser/filebrowser
       container_name: filebrowser
       volumes:
         - /opt/seedbox/downloads:/srv # Mapped to match qBittorrent downloads
         - /opt/seedbox/filebrowser.db:/database.db # Connects to our pre-configured DB
       ports:
         - 8081:80
       restart: unless-stopped
   ```

3. **Launch the Stack:**
   ```bash
   cd /opt/seedbox
   docker compose up -d
   ```

---

### Phase 3: Network & Access 🌐

#### 🔓 Open Firewall Ports (UFW)

Ensure these ports are open on your VPS firewall:

```bash
sudo ufw allow 8080/tcp  # qBittorrent UI
sudo ufw allow 8081/tcp  # FileBrowser UI
sudo ufw allow 6881      # Torrent Traffic
```

#### �️ Dashboard Access

| Service         | URL                     | Default User | Default Password        |
| :-------------- | :---------------------- | :----------- | :---------------------- |
| **qBittorrent** | `http://<YOUR_IP>:8080` | `admin`      | _Check Logs (See Note)_ |
| **FileBrowser** | `http://<YOUR_IP>:8081` | `admin`      | `adminadmin1234`        |

> [!NOTE]
> **qBittorrent Password:** On first launch, qBittorrent generates a random password.
> Run `docker logs qbittorrent` to find it.
> Login, then immediately go to **Tools > Options > Web UI** to change it.

---

### 💡 How It Works

1. **Integration:** Both apps share the `/opt/seedbox/downloads` folder.
2. **Workflow:**
   - Add a torrent in **qBittorrent**.
   - It downloads to `/downloads` (inside container) → `/opt/seedbox/downloads` (on VPS).
   - **FileBrowser** sees `/srv` (inside container) ← `/opt/seedbox/downloads` (on VPS).
   - You can instantly stream or download the file via FileBrowser.

> [!WARNING]
> In qBittorrent settings, **keep the Default Save Path as `/downloads/`**. Do not change it to matched host paths like `/root/Seedbox/...`.
