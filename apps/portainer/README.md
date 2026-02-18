# Portainer

**Docker Management UI**

A lightweight management UI which allows you to easily manage your different Docker environments (Docker hosts or Swarm clusters).

## 🚀 Usage

- **URL:** `https://docker.your-domain.com`
- **Default Credentials:** Setup on first launch.

## ⚙️ Configuration

- **Security:** Runs with `no-new-privileges` security option to prevent privilege escalation.
- **Time:** Host timezone is mounted read-only (`/etc/localtime`).

## 💾 Volumes

- `portainer_data`: Stores Portainer configuration and DB.
- `/var/run/docker.sock`: Mounted read-only for Docker management.
