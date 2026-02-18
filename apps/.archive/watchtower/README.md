# Watchtower

**Automated Container Updates**

A process for automating Docker container base image updates. Watchtower will pull down your new image, gracefully shut down your existing container, and restart it with the same options that were used when it was deployed initially.

## 🚀 Usage

- **Status:** Runs in the background as a service.
- **Schedule:** Checks for updates daily at 4:00 AM.
- **Cleanup:** Automatically removes old images after update.

## ⚙️ Configuration

> [!IMPORTANT]
> This service uses `DOCKER_API_VERSION=1.45` to ensure compatibility with newer Docker daemons on the host.

## 💾 Volumes

- `/var/run/docker.sock`: Required to interact with the Docker daemon.
