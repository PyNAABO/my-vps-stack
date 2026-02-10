# Dockge

**Docker Compose Manager**

A fancy, reactive, self-hosted Docker Compose stack manager. Manage your `docker-compose.yml` files visually.

## 🚀 Usage

- **URL:** `https://dockge.your-domain.com`
- **Default Credentials:** Setup on first launch (create admin account).

## 💾 Volumes

- `/var/run/docker.sock`: Docker socket for container management.
- `../../config/dockge`: Persistent application data.
- `../../apps`: Mounted as `/stacks` — Dockge can see and manage all app stacks.

## ⚠️ Notes

- Dockge requires Docker socket access (similar to Portainer and Watchtower).
- Stacks created via Dockge use `compose.yaml` format — the deploy workflow supports both `docker-compose.yml` and `compose.yaml`.
- Uses pinned major version tag (`:1`) for stability.
