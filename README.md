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
| **Dashboard**         | home.\*   | Auto-generated app launcher   | _(No setup needed)_       |
| **Portainer**         | docker.\* | Docker management UI          | _(Setup on first launch)_ |
| **Uptime Kuma**       | status.\* | Service monitoring            | _(Setup on first launch)_ |
| **FileBrowser**       | drive.\*  | File manager / Streamer       | admin / adminadmin1234    |
| **qBittorrent**       | seed.\*   | Torrent client                | _(Check docker logs)_     |
| **Telegram Bot**      | -         | Basic Node Status (Ping/Time) | _(Token in secrets)_      |
| **WhatsApp Bot**      | -         | Group commands via WhatsApp   | _(Scan QR once)_          |
| **Cloudflare Tunnel** | -         | Exposes all services securely | _(Auto-configured)_       |

> [!TIP]
> **Archived Apps:** The following apps are in `apps/.archive/` and excluded from builds:
>
> - `n8n` - Workflow automation
> - `homarr` - Dashboard alternative
> - `it-tools` - Developer utilities
> - `changedetection` - Website change monitoring
>
> Move folders out of `.archive/` to re-enable them.

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

1. **OS:** Ubuntu 22.04 LTS or newer.
2. **Software:** `git`, `curl`, `docker` installed.
3. **Network:** Open port **22** (SSH). All other traffic is routed securely via Cloudflare Tunnel.

## **⚡ Quick Start**

Run these commands on your VPS as root:

```bash
cd /root
git clone https://github.com/PyNAABO/my-vps-stack.git
cd my-vps-stack
docker compose up -d
```

_The stack will start within seconds._

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

## **📱 Local & Android Setup**

Don't have a VPS? You can run this stack locally or on your phone!

| Platform              | Recommended Method  | Guide                                |
| :-------------------- | :------------------ | :----------------------------------- |
| **Android (Termux)**  | Native (Super Fast) | [Termux Guide](docs/Termux.md)       |
| **Windows/Mac/Linux** | Docker Desktop      | `docker compose up -d`               |
| **Android (Rooted)**  | Native Docker       | [Docker-VM Guide](docs/Docker-VM.md) |

### **Why Native Termux over Docker?**

Using Docker on a non-rooted Android device (via QEMU/Proot) is possible but **extremely resource-heavy**. It emulates hardware, drains battery, and is 5-10x slower.

**This stack uses a "Native" approach:**

- ✅ **Zero Overhead:** Apps run directly on your phone's processor.
- ✅ **Battery Friendly:** Sleep optimization works better.
- ✅ **Instant Start:** No VM boot times.
- ⚠️ **Trade-off:** You lose Docker's "run anything" compatibility. Only Node.js and Python apps are auto-detected by `termux-up.sh`.

> [!TIP]
> Use the [Termux Startup Script](scripts/termux-up.sh) for a one-command setup on Android.

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
