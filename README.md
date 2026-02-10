# **🚀 Modular VPS Stack**

A **modular, plug-and-play** Infrastructure as Code (IaC) configuration for deploying self-healing containerized applications on any Linux VPS.

**Add or remove apps by simply adding or deleting folders.** No need to edit docker-compose or deploy configs!

## **📦 Architecture**

```
my-vps-stack/
├── apps/                    # 👈 Each app = one folder
│   ├── .template/           # 👈 Copy this to create new apps
│   │   ├── docker-compose.yml
│   │   ├── ingress.yml
│   │   ├── init.sh
│   │   └── README.md
│   ├── portainer/
│   │   ├── docker-compose.yml
│   │   └── ingress.yml      # Tunnel routing
│   ├── filebrowser/
│   │   ├── docker-compose.yml
│   │   ├── ingress.yml
│   │   └── init.sh          # First-time setup
│   ├── .archive/            # 👈 Disabled apps (excluded from builds)
│   │   └── n8n/
│   └── ...
├── docker-compose.yml       # Auto-generated on deploy
└── .github/workflows/
    └── deploy.yml           # Auto-generates everything
```

### **How It Works**

1. **Add app:** Create a folder in `apps/` with `docker-compose.yml`
2. **Expose via tunnel:** Add `ingress.yml` with subdomain + service
3. **First-time setup:** Optionally add `init.sh` for initialization
4. **Push to GitHub:** Deploy workflow auto-generates tunnel config!

## **🛠️ The Stack**

| App                   | Subdomain  | Description                   | Default Credentials        |
| :-------------------- | :--------- | :---------------------------- | :------------------------- |
| **Dashboard**         | home.\*    | Auto-generated app launcher   | _(No setup needed)_        |
| **Portainer**         | docker.\*  | Docker management UI          | _(Setup on first launch)_  |
| **Uptime Kuma**       | status.\*  | Service monitoring            | _(Setup on first launch)_  |
| **FileBrowser**       | drive.\*   | File manager / Streamer       | _(Check docker logs)_      |
| **qBittorrent**       | seed.\*    | Torrent client                | _(Check docker logs)_      |
| **Jellyfin**          | play.\*    | Media Server                  | _(Setup on first launch)_  |
| **Glances**           | monitor.\* | Real-time system monitor      | _(Open access by default)_ |
| **Telegram Bot**      | -          | Remote VPS management/status  | _(Token in secrets)_       |
| **WhatsApp Bot**      | -          | Group commands via WhatsApp   | _(Session scanned via QR)_ |
| **Watchtower**        | -          | Auto-updates containers       | _(No UI, runs at 4 AM)_    |
| **Cloudflare Tunnel** | -          | Exposes all services securely | _(Auto-configured)_        |

> [!TIP]
> **Archived Apps:** The following apps are in `apps/.archive/` and excluded from builds:
>
> - `changedetection` - Website change monitoring
> - `dockge` - Docker Compose Manager
> - `homarr` - Dashboard alternative
> - `it-tools` - Developer utilities
> - `n8n` - Workflow automation
> - `stirling-pdf` - PDF manipulation tools
>
> Move folders out of `.archive/` to re-enable them.

> [!CAUTION]
> **Change default passwords immediately after first login!**

## **➕ Adding a New App**

### Quick Method (Copy Template)

```bash
# 1. Copy template folder
cp -r apps/.template apps/myapp

# 2. Edit docker-compose.yml
cd apps/myapp
nano docker-compose.yml

# 3. Optional: Add web access
nano ingress.yml

# 4. Optional: Add custom dashboard icon
echo "myapp=🚀" >> ../dashboard/icons.conf

# 5. Commit and push
git add ..
git commit -m "Add myapp"
git push
```

### Manual Method

1. Create folder: `apps/myapp/`
2. Add `docker-compose.yml`:
   ```yaml
   services:
     myapp:
       image: myapp/image:latest
       restart: always
       ports: ["3000:3000"]
   ```
3. Add `ingress.yml` (if exposing via tunnel):
   ```yaml
   hostname: myapp
   service: http://myapp:3000
   ```
4. Push to GitHub. **That's it!** 🎉

### What Happens Automatically

The deploy workflow will:

- ✅ Include your app in `docker-compose.yml`
- ✅ Configure tunnel routing (if `ingress.yml` exists)
- ✅ Add dashboard tile (if `ingress.yml` exists)
- ✅ Run `init.sh` (if exists)

### Config Directories & Permissions

If your app needs persistent storage or config directories:

1. **Create in `init.sh`:**

   ```bash
   #!/bin/bash
   mkdir -p "$(dirname "$0")/data"
   chown -R 1000:1000 "$(dirname "$0")/data"
   ```

2. **Mount in `docker-compose.yml`:**
   ```yaml
   volumes:
     - ./data:/app/data
   ```

### Dashboard Icons

Apps get a default 🔗 icon. For custom icons:

1. Edit `apps/dashboard/icons.conf`:

   ```
   myapp=🚀
   database=🗄️
   ai=🤖
   ```

2. Or just use the default (works fine!)

### Environment Variables & Secrets

**Option A: Use existing secrets** (if applicable)

- `DOMAIN_NAME` - Your domain
- `TG_BOT_TOKEN` - Telegram bot token

**Option B: Add new secrets** (for app-specific API keys, etc.):

1. Add to GitHub → Settings → Secrets and variables → Actions
2. Edit `.github/workflows/deploy.yml` Step 5:
   ```bash
   echo "MYAPP_API_KEY=${{ secrets.MYAPP_API_KEY }}" >> .env
   ```
3. Use in your `docker-compose.yml`:
   ```yaml
   environment:
     - API_KEY=${MYAPP_API_KEY}
   ```

## **➖ Removing an App**

1. Delete the app folder from `apps/`
2. Push to GitHub

## **📋 Prerequisites**

1. **OS:** Ubuntu 22.04 LTS or newer.
2. **Software:** `git`, `curl`, `docker` installed.
3. **Network:** Open port **22** (SSH). All other traffic is routed securely via Cloudflare Tunnel.

## **⚡ Quick Start**

Run these commands on your VPS as root (Manual Method):

```bash
cd /root
git clone https://github.com/PyNAABO/my-vps-stack.git
cd my-vps-stack
docker compose up -d
```

> [!TIP]
> **Better Way:** Check the "Setup Automation" section below for the **Zero-Config** setup!

_The stack will start within seconds._

## **🚀 Setup Automation (CI/CD)**

### **Option A: Cold Start (Brand New VPS)**

**You do NOT need to clone the repo manually!**

1. **Install Docker** on your VPS.
2. **Add Secrets** to GitHub (Settings → Secrets and variables → Actions):
   - `VPS_IP`: Your VPS IP
   - `VPS_SSH_KEY`: Root SSH private key
   - `DOMAIN`: Your domain
   - `TUNNEL_ID`: Cloudflare Tunnel ID
   - `TUNNEL_CREDENTIALS`: Cloudflare Tunnel JSON
   - `TG_BOT_TOKEN`, `ALLOWED_GROUP_ID`: Bot secrets
3. **Push to Main**: The deploy workflow will automatically:
   - SSH into your VPS
   - **Clone the repository** (if missing)
   - Setup directories & permissions
   - Deploy the stack

### **Option B: Manual Setup (Existing VPS)**

1. **Generate a Deploy Key**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_action -N ""
cat ~/.ssh/github_action.pub >> ~/.ssh/authorized_keys
cat ~/.ssh/github_action   # Copy this as VPS_SSH_KEY
```

2. **Configure Cloudflare Tunnel**

```bash
cloudflared tunnel login
cloudflared tunnel create vps-cli-tunnel
```

Create a wildcard CNAME: `*` → `<UUID>.cfargotunnel.com`

3. **Add GitHub Secrets** (Same as Option A)

## **🚀 Usage**

1. Make changes locally
2. Push to main branch
3. GitHub Actions:
   - Pulls latest code
   - **Auto-generates tunnel config** from `apps/*/ingress.yml`
   - Runs `apps/*/init.sh` scripts
   - Rebuilds changed containers

> [!WARNING]
> **The deploy workflow runs `git reset --hard`** on the VPS, which **wipes any local changes** (hot-fixes, manual config tweaks). Always commit changes back to the repo—never edit files directly on the VPS.

## **📂 File Structure & Permissions**

The stack enforces a standard directory structure using a shared `vps-data` folder located **next to** the repository (sibling directory).

```
/root/
├── my-vps-stack/      # This repository
└── vps-data/          # Shared data (Owned by 1000:1000)
    ├── downloads/     # qBittorrent downloads
    └── media/         # Jellyfin media library
        ├── movies/
        └── shows/
```

- **qBittorrent** writes to `/downloads` (mapped to `../vps-data/downloads`).
- **Jellyfin** reads from `/media` (mapped to `../vps-data`).
- **FileBrowser** manages `/srv` (mapped to `../vps-data`).

## **🐛 Troubleshooting**

```bash
# Check containers
docker ps

# View logs
docker logs filebrowser
docker logs qbittorrent

# Hard reset
docker compose down
rm -rf config/fb
git pull
docker compose up -d
```

## **🛠️ Utility Scripts**

| Script                       | Description                     |
| :--------------------------- | :------------------------------ |
| `scripts/run_once.sh`        | Sets up `update` alias          |
| `scripts/update.sh`          | System update script            |
| `scripts/cloud_backup.sh`    | rclone backup to Google Drive   |
| `scripts/list_subdomains.sh` | Lists all configured subdomains |

> 📦 **Seedbox setup?** See [docs/Seedbox.md](docs/Seedbox.md)

## **📁 Environment Variables**

> [!NOTE]
> `.env` is **auto-generated by CI/CD**. GitHub Secrets are injected during deploy.

| Variable           | Source                     |
| :----------------- | :------------------------- |
| `DOMAIN_NAME`      | `secrets.DOMAIN`           |
| `TG_BOT_TOKEN`     | `secrets.TG_BOT_TOKEN`     |
| `ALLOWED_GROUP_ID` | `secrets.ALLOWED_GROUP_ID` |
