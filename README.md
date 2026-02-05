# 🚀 Automated VPS Stack

This repository contains a Infrastructure as Code (IaC) configuration to deploy a self-healing,
containerized application stack on any Linux VPS.

It utilizes Docker Compose for orchestration and GitHub Actions for CI/CD. Pushing to the
main branch automatically updates the server, rebuilds containers, and applies configuration
fixes.

## 🛠 The Stack

| Service | Internal Port | Default Credentials |
| :--- | :--- | :--- |
| **FileBrowser** | `:8081` | `admin` / `adminadmin1234` |
| **qBittorrent** | `:8080` | `admin` / `adminadmin1234` *(Auto-Injected)* |
| **n8n** | `:5678` | *(Setup on first launch)* |
| **WhatsApp Bot** | `-` | *(Scan QR once - Persistent Session)* |

## 📋 Prerequisites

Before cloning this repository, ensure your VPS meets the following requirements:

1. Operating System: Ubuntu 22.04 / 24.04 LTS (Recommended)
2. Dependencies Installed:
    git
    curl
    docker & docker compose
3. Firewall (UFW): Ensure ports 8080 , 8081 , 5678 , and 22 are open.

## ⚡ Installation

1. Clone the Repository
Since this repository is public, you can clone it directly via HTTPS without SSH authentication.

```
cd /root
git clone https://github.com/YOUR_USERNAME/my-vps-stack.git
cd my-vps-stack
```

*(Replace* YOUR_USERNAME *with your actual GitHub username)*

1. Manual First Run (Optional)
You can start the stack manually to verify everything works before setting up automation.

```
docker compose up -d
```

## 🔐 Setup Automation (CI/CD)

To enable "Push-to-Deploy", GitHub Actions needs SSH access to your VPS.

1. Generate a Deploy Key
Run the following commands on your VPS to generate a specific key pair for GitHub Actions:

```
# 1. Generate the key (Press Enter for empty passphrase)
ssh-keygen -t ed25519 -f ~/.ssh/github_action -N ""
# 2. Authorize the key (Allow it to log in)
cat ~/.ssh/github_action.pub >> ~/.ssh/authorized_keys
# 3. Display the Private Key
cat ~/.ssh/github_action
```

1. Configure GitHub Secrets
Go to your GitHub Repository ➔ Settings ➔ Secrets and variables ➔ Actions.

Add the following two secrets:

```
Secret Name Value
VPS_IP Your VPS IP Address (e.g., 198.XX.XX.XXX)
VPS_SSH_KEY The entire output of the cat command above (starts with -----BEGIN
OPENSSH...)
```

## 🚀 Usage

Once the secrets are set, you no longer need to SSH into your server.

1. Edit Code: Make changes to your bot or config files locally.
2. Push: Commit and push changes to the main branch.
3. Deploy: Watch the Actions tab in GitHub. The workflow will automatically:
    SSH into your VPS.
    Pull the latest code.

```
Auto-fix configuration files (creating DBs if missing).
Rebuild and restart only the changed containers.
```

## 🐛 Troubleshooting

If the automatic deployment fails or services behave unexpectedly, SSH into your VPS (ssh
root@YOUR_IP) and run these diagnostic commands:

Check Container Status:

```
docker ps
```

View Application Logs:

```
docker logs my-vps-stack-filebrowser-
docker logs my-vps-stack-qbittorrent-
```

Nuclear Option (Hard Reset): *Use this if the database is corrupted or containers are stuck.*

```
cd /root/my-vps-stack
docker compose down
# WARNING: This resets FileBrowser users/settings (but keeps downloads)
rm -rf config/fb
git pull
docker compose up -d
```
