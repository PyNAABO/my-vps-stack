# **🚀 Modular VPS Stack**

A **modular, plug-and-play** Infrastructure as Code (IaC) configuration for deploying self-healing containerized applications on any Linux VPS.

**Add or remove apps by simply adding or deleting folders.** No need to edit docker-compose or deploy configs!

## **📦 Architecture**

```
my-vps-stack/
├── apps/                    # 👈 Each app = one folder
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

| App                   | Subdomain | Description                   | Default Credentials       |
| :-------------------- | :-------- | :---------------------------- | :------------------------ |
| **Homarr**            | home.\*   | Dashboard / Homepage          | _(Setup on first launch)_ |
| **Portainer**         | docker.\* | Docker management UI          | _(Setup on first launch)_ |
| **Uptime Kuma**       | status.\* | Service monitoring            | _(Setup on first launch)_ |
| **Dozzle**            | logs.\*   | Real-time container logs      | _(No auth needed)_        |
| **FileBrowser**       | drive.\*  | File manager / Streamer       | _(See init.sh)_           |
| **qBittorrent**       | seed.\*   | Torrent client                | _(Check docker logs)_     |
| **Telegram Bot**      | -         | VPS commands via Telegram     | _(Token in secrets)_      |
| **WhatsApp Bot**      | -         | Group commands via WhatsApp   | _(Scan QR once)_          |
| **Cloudflare Tunnel** | -         | Exposes all services securely | _(Auto-configured)_       |

> [!TIP]
> Apps in `apps/.archive/` are excluded from builds. Move folders out of `.archive/` to re-enable them.

> [!CAUTION]
> **Change default passwords immediately after first login!**

## **➕ Adding a New App**

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

> The deploy workflow auto-generates `docker-compose.yml` from all `apps/*/docker-compose.yml` files.

> [!IMPORTANT]
> **If your app needs secrets** (API keys, tokens, etc.), you must:
>
> 1. Add the secret to GitHub Repository Settings → Secrets
> 2. Edit `.github/workflows/deploy.yml` to inject it into `.env` (see Step 5 in the script)

## **➖ Removing an App**

1. Delete the app folder from `apps/`
2. Push to GitHub

## **📋 Prerequisites**

1. **OS:** Ubuntu 22.04 / 24.04 LTS
2. **Dependencies:** git, curl, docker & docker compose (v2.20+)
3. **Firewall:** SSH (22) must be open. Other ports are tunneled via Cloudflare.

## **⚡ Installation**

```bash
cd /root
git clone https://github.com/PyNAABO/my-vps-stack.git
cd my-vps-stack
docker compose up -d
```

## **🔐 Setup Automation (CI/CD)**

### **1. Generate a Deploy Key**

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_action -N ""
cat ~/.ssh/github_action.pub >> ~/.ssh/authorized_keys
cat ~/.ssh/github_action   # Copy this as VPS_SSH_KEY
```

### **2. Configure Cloudflare Tunnel**

```bash
cloudflared tunnel login
cloudflared tunnel create vps-cli-tunnel
```

Create a wildcard CNAME: `*` → `<UUID>.cfargotunnel.com`

### **3. GitHub Secrets**

| Secret                 | Description                          |
| :--------------------- | :----------------------------------- |
| **VPS_IP**             | Your VPS IP address                  |
| **VPS_SSH_KEY**        | Private key from step 1              |
| **DOMAIN**             | Your domain (e.g., example.com)      |
| **TUNNEL_ID**          | UUID from cloudflared                |
| **TUNNEL_CREDENTIALS** | JSON content from ~/.cloudflared/    |
| **TG_BOT_TOKEN**       | Telegram bot token from @BotFather   |
| **ALLOWED_GROUP_ID**   | WhatsApp Group ID (format: xxx@g.us) |

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

## **🐛 Troubleshooting**

```bash
# Check containers
docker ps

# View logs
docker logs filebrowser

# Hard reset
docker compose down
rm -rf config/fb
git pull
docker compose up -d
```

## **🛠️ Utility Scripts**

| Script                    | Description                   |
| :------------------------ | :---------------------------- |
| `scripts/run_once.sh`     | Sets up `update` alias        |
| `scripts/update.sh`       | System update script          |
| `scripts/cloud_backup.sh` | rclone backup to Google Drive |

> 📦 **Seedbox setup?** See [docs/Seedbox.md](docs/Seedbox.md)

## **📁 Environment Variables**

> [!NOTE]
> `.env` is **auto-generated by CI/CD**. GitHub Secrets are injected during deploy.

| Variable           | Source                     |
| :----------------- | :------------------------- |
| `DOMAIN_NAME`      | `secrets.DOMAIN`           |
| `TG_BOT_TOKEN`     | `secrets.TG_BOT_TOKEN`     |
| `ALLOWED_GROUP_ID` | `secrets.ALLOWED_GROUP_ID` |
