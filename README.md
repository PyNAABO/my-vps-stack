# **🚀 Automated VPS Stack**

This repository contains a **Infrastructure as Code (IaC)** configuration to deploy a self-healing, containerized application stack on any Linux VPS.

It utilizes **Docker Compose** for orchestration and **GitHub Actions** for CI/CD. Pushing to the main branch automatically updates the server, rebuilds containers, and applies configuration fixes.

## **🛠️ The Stack**

| Service | Internal Port | Default Credentials |
| :---- | :---- | :---- |
| **FileBrowser** | :8081 | admin / adminadmin1234 |
| **qBittorrent** | :8080 | admin / adminadmin1234 *(Auto-Injected)* |
| **n8n** | :5678 | *(Setup on first launch)* |
| **WhatsApp Bot** | \- | *(Scan QR once \- Persistent Session)* |

## **📋 Prerequisites**

Before cloning this repository, ensure your VPS meets the following requirements:

1. **Operating System:** Ubuntu 22.04 / 24.04 LTS (Recommended)  
2. **Dependencies Installed:**  
   * git  
   * curl  
   * docker & docker compose  
3. **Firewall (UFW):** Ensure ports 8080, 8081, 5678, and 22 are open.

## **⚡ Installation**

### **1\. Clone the Repository**

Since this repository is public, you can clone it directly via HTTPS without SSH authentication.

``` bash
cd /root  
git clone \[<https://github.com/YOUR\_USERNAME/my-vps-stack.git\>](<https://github.com/YOUR\_USERNAME/my-vps-stack.git>)  
cd my-vps-stack
```

*(Replace YOUR\_USERNAME with your actual GitHub username)*

### **2\. Manual First Run (Optional)**

You can start the stack manually to verify everything works before setting up automation.

docker compose up \-d

## **🔐 Setup Automation (CI/CD)**

To enable **"Push-to-Deploy"**, GitHub Actions needs SSH access to your VPS.

### **1\. Generate a Deploy Key**

Run the following commands **on your VPS** to generate a specific key pair for GitHub Actions:

``` bash
\# 1\. Generate the key (Press Enter for empty passphrase)  
ssh-keygen \-t ed25519 \-f \~/.ssh/github\_action \-N ""

\# 2\. Authorize the key (Allow it to log in)  
cat \~/.ssh/github\_action.pub \>\> \~/.ssh/authorized\_keys

\# 3\. Display the Private Key  
cat \~/.ssh/github\_action
```

*Copy the entire output starting with \-----BEGIN OPENSSH...*

### **2\. Configure Cloudflare Tunnel (Hybrid Mode)**

*Skip this if you only want to use IP addresses. This enables <https://drive.yourdomain.com>, etc.*

1. **Install cloudflared on your Local PC (Laptop)**.  
2. Login: cloudflared tunnel login  
3. Create a new tunnel:  
   cloudflared tunnel create vps-cli-tunnel

4. This creates a JSON file (usually in \~/.cloudflared/\<UUID\>.json). **Copy its content.**  
5. **DNS Setup:** Go to your Cloudflare Dashboard ➔ DNS. Create a CNAME record:  
   * **Name:** \* (Wildcard)  
   * **Target:** \<UUID\>.cfargotunnel.com

### **3\. Configure GitHub Secrets**

Go to your **GitHub Repository** ➔ **Settings** ➔ **Secrets and variables** ➔ **Actions**.

Add the following secrets to enable the full pipeline:

| Secret Name | Value | Description |
| :---- | :---- | :---- |
| **VPS\_IP** | 123.45.67.89 | Your VPS Public IP Address. |
| **VPS\_SSH\_KEY** | \-----BEGIN... | The Private Key you generated on the VPS. |
| **DOMAIN** | example.com | Your domain name (Leave empty for IP-only mode). |
| **TUNNEL\_ID** | c2e3d4... | The UUID of your Cloudflare Tunnel. |
| **TUNNEL\_CREDENTIALS** | { "AccountTag": ... } | The content of your JSON credentials file. |

## **🚀 Usage**

Once the secrets are set, you no longer need to SSH into your server manually.

1. **Edit Code:** Make changes to your bot or config files locally.  
2. **Push:** Commit and push changes to the main branch.  
3. **Deploy:** Watch the **Actions** tab in GitHub. The workflow will automatically:  
   * SSH into your VPS.  
   * Pull the latest code.  
   * **Auto-Heal:** Fix FileBrowser database issues & inject qBittorrent configs.  
   * **Hybrid Config:** Generate the correct Cloudflare Tunnel map if a domain is present.  
   * Rebuild and restart only the changed containers.

## **🐛 Troubleshooting**

If the automatic deployment fails or services behave unexpectedly, SSH into your VPS (ssh root@YOUR\_IP) and run these diagnostic commands:

**Check Container Status:**

``` bash
docker ps
```

**View Application Logs:**

``` bash
docker logs my-vps-stack-filebrowser-1  
docker logs my-vps-stack-qbittorrent-1
```

**Nuclear Option (Hard Reset):**

*Use this if the database is corrupted or containers are stuck.*

``` bash
cd /root/my-vps-stack  
docker compose down  
\# WARNING: This resets FileBrowser users/settings (but keeps downloads)  
rm \-rf config/fb  
git pull  
docker compose up \-d  
```
