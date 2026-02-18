# 📦 Ultimate Seedbox Guide

> [!NOTE]
> **qBittorrent** and **FileBrowser** are currently archived. To use this guide, first move them from `apps/.archive/` to `apps/`:
> ```bash
> mv apps/.archive/qbittorrent apps/
> mv apps/.archive/filebrowser apps/
> ```

## The Modern, Automated Setup

> [!IMPORTANT]
> This guide sets up **qBittorrent** (Downloader) and **FileBrowser** (Manager/Streamer) using the **GitOps workflow**, ensuring alignment with the rest of your stack.

### 📋 Prerequisites

- **Docker** & **Docker Compose** installed.
- Root access.
- The `my-vps-stack` repository cloned to `/root/my-vps-stack`.

---

### Phase 1: One-Time Setup 🏗️

```bash
# 1. Create the admin user (User: admin / Pass: adminadmin1234)
# Note: Directory structure (vps-data/) is auto-created by the deploy script.
docker run --rm \
  -v /root/my-vps-stack/config/fb/filebrowser.db:/database.db \
  filebrowser/filebrowser users add admin adminadmin1234 --perm.admin
```

> [!CAUTION]
> **Change the default password regarding filebrowser immediately after first login!**

---

### Phase 2: Deployment 🚀

1. **Verify Apps are Active:**
   Ensure `qbittorrent` and `filebrowser` folders exist in `apps/`. If they are in `apps/.archive/`, move them to `apps/`.

   ```bash
   mv apps/.archive/qbittorrent apps/ 2>/dev/null
   mv apps/.archive/filebrowser apps/ 2>/dev/null
   ```

2. **Push to GitHub:**
   Commit and push your changes. The GitHub Action will automatically:
   - Generate the master `docker-compose.yml` including these apps.
   - Configure the Cloudflare Tunnel ingress for `seed.*` and `drive.*` (or whatever is defined in `ingress.yml`).
   - Deploy the stack.

---

### Phase 3: Access 🌐

| Service         | Subdomain | Default User | Default Password        |
| :-------------- | :-------- | :----------- | :---------------------- |
| **qBittorrent** | `seed.*`  | `admin`      | _Check Logs (See Note)_ |
| **FileBrowser** | `drive.*` | `admin`      | `adminadmin1234`        |

> [!NOTE]
> **qBittorrent Password:** On first launch, check logs:
> `docker logs qbittorrent`

---

### 💡 How It Works

1. **Shared Storage:** Both apps are "mounted" to the same `vps-data` folder on your VPS (sibling to the repository).
2. **The Flow:**
   - **qBittorrent** downloads a file to `/downloads` (inside the container).
   - This appears instantly in `../vps-data/downloads` (on your VPS).
   - **FileBrowser** reads this same folder, allowing you to stream or download the file immediately.
