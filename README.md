# **🚀 Automated VPS Stack**

This repository contains a **Infrastructure as Code (IaC)** configuration to deploy a self-healing, containerized application stack on any Linux VPS.

It utilizes **Docker Compose** for orchestration and **GitHub Actions** for CI/CD. Pushing to the main branch automatically updates the server, rebuilds containers, and applies configuration fixes.

## **🛠️ The Stack**

| Service               | Internal Port | Default Credentials                      |
| :-------------------- | :------------ | :--------------------------------------- |
| **Portainer**         | :9000         | _(Setup on first launch)_                |
| **Uptime Kuma**       | :3001         | _(Setup on first launch)_                |
| **FileBrowser**       | :8081         | admin / adminadmin1234                   |
| **qBittorrent**       | :8080         | admin / adminadmin1234 _(Auto-Injected)_ |
| **n8n**               | :5678         | _(Setup on first launch)_                |
| **WhatsApp Bot**      | -             | _(Scan QR once - Persistent Session)_    |
| **Cloudflare Tunnel** | -             | _(Exposes services via domain)_          |

> [!CAUTION]
> **Change the default passwords immediately after first login!** The credentials listed above are publicly known.

## **📋 Prerequisites**

Before cloning this repository, ensure your VPS meets the following requirements:

1. **Operating System:** Ubuntu 22.04 / 24.04 LTS (Recommended)
2. **Dependencies Installed:**
   - git
   - curl
   - docker & docker compose
3. **Firewall (UFW):** Ensure ports 8080, 8081, 5678, and 22 are open.

## **⚡ Installation**

### **1. Clone the Repository**

Since this repository is public, you can clone it directly via HTTPS without SSH authentication.

```bash
cd /root
git clone https://github.com/YOUR_USERNAME/my-vps-stack.git
cd my-vps-stack
```

_(Replace YOUR_USERNAME with your actual GitHub username)_

### **2. Manual First Run (Optional)**

You can start the stack manually to verify everything works before setting up automation.

```bash
docker compose up -d
```

## **🔐 Setup Automation (CI/CD)**

To enable **"Push-to-Deploy"**, GitHub Actions needs SSH access to your VPS.

### **1. Generate a Deploy Key**

Run the following commands **on your VPS** to generate a specific key pair for GitHub Actions:

```bash
# 1. Generate the key (Press Enter for empty passphrase)
ssh-keygen -t ed25519 -f ~/.ssh/github_action -N ""

# 2. Authorize the key (Allow it to log in)
cat ~/.ssh/github_action.pub >> ~/.ssh/authorized_keys

# 3. Display the Private Key
cat ~/.ssh/github_action
```

_Copy the entire output starting with -----BEGIN OPENSSH..._

### **2. Configure Cloudflare Tunnel (Hybrid Mode)**

_Skip this if you only want to use IP addresses. This enables https://drive.yourdomain.com, etc._

1. **Install cloudflared on your Local PC (Laptop)**.
2. Login: `cloudflared tunnel login`
3. Create a new tunnel: `cloudflared tunnel create vps-cli-tunnel`
4. This creates a JSON file (usually in `~/.cloudflared/<UUID>.json`). **Copy its content.**
5. **DNS Setup:** Go to your Cloudflare Dashboard ➔ DNS. Create a CNAME record:
   - **Name:** \* (Wildcard)
   - **Target:** `<UUID>.cfargotunnel.com`

### **3. Configure GitHub Secrets**

Go to your **GitHub Repository** ➔ **Settings** ➔ **Secrets and variables** ➔ **Actions**.

Add the following secrets to enable the full pipeline:

| Secret Name            | Value                 | Description                                      |
| :--------------------- | :-------------------- | :----------------------------------------------- |
| **VPS_IP**             | 123.45.67.89          | Your VPS Public IP Address.                      |
| **VPS_SSH_KEY**        | -----BEGIN...         | The Private Key you generated on the VPS.        |
| **DOMAIN**             | example.com           | Your domain name (Leave empty for IP-only mode). |
| **TUNNEL_ID**          | c2e3d4...             | The UUID of your Cloudflare Tunnel.              |
| **TUNNEL_CREDENTIALS** | { "AccountTag": ... } | The content of your JSON credentials file.       |
| **ALLOWED_GROUP_ID**   | 12345...@g.us         | WhatsApp Group ID for the bot (see bot README).  |

## **🚀 Usage**

Once the secrets are set, you no longer need to SSH into your server manually.

1. **Edit Code:** Make changes to your bot or config files locally.
2. **Push:** Commit and push changes to the main branch.
3. **Deploy:** Watch the **Actions** tab in GitHub. The workflow will automatically:
   - SSH into your VPS.
   - Pull the latest code.
   - **Auto-Heal:** Fix FileBrowser database issues & inject qBittorrent configs.
   - **Hybrid Config:** Generate the correct Cloudflare Tunnel map if a domain is present.
   - Rebuild and restart only the changed containers.

## **🐛 Troubleshooting**

If the automatic deployment fails or services behave unexpectedly, SSH into your VPS (`ssh root@YOUR_IP`) and run these diagnostic commands:

**Check Container Status:**

```bash
docker ps
```

**View Application Logs:**

```bash
docker logs filebrowser
docker logs qbittorrent
```

**Nuclear Option (Hard Reset):**

_Use this if the database is corrupted or containers are stuck._

```bash
cd /root/my-vps-stack
docker compose down
# WARNING: This resets FileBrowser users/settings (but keeps downloads)
rm -rf config/fb
git pull
docker compose up -d
```

## **🛠️ Utility Scripts**

| Script            | Description                                                 |
| :---------------- | :---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| `run_once.sh`     | Sets up the `update` alias in `.bashrc`                     |
| `update.sh`       | System update script (apt update/upgrade/autoremove)        |
| `cloud_backup.sh` | Syncs `/root` and `/opt/seedbox` to Google Drive via rclone | \r\n\r\n> 📦 **Setting up a seedbox?** See [Seedbox.md](Seedbox.md) for detailed qBittorrent + FileBrowser setup instructions. |

### Setting Up the Update Alias

```bash
chmod +x run_once.sh
./run_once.sh
source ~/.bashrc
# Now you can just type 'update' to update the system
```

### Setting Up Cloud Backup

1. **Install rclone:** `sudo apt install rclone`
2. **Configure Google Drive:** `rclone config` (follow prompts to add `gdrive` remote)
3. **Edit paths if needed:** Modify `SOURCE_DIRS` in `cloud_backup.sh`
4. **Run manually:** `./cloud_backup.sh`
5. **Schedule with cron (optional):**
   ```bash
   crontab -e
   # Add: 0 3 * * * /root/my-vps-stack/cloud_backup.sh
   ```

## **📁 Environment Variables**

> [!NOTE]
> The `.env` file is **auto-generated by CI/CD** during deployment. You don't need to create it manually. GitHub Secrets are injected into `.env` by the deploy workflow.

| Variable           | Source                     |
| :----------------- | :------------------------- |
| `DOMAIN_NAME`      | `secrets.DOMAIN`           |
| `ALLOWED_GROUP_ID` | `secrets.ALLOWED_GROUP_ID` |
