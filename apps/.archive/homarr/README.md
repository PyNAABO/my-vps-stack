# Homarr

**Status:** Archived (Disabled) - Move out of `.archive/` to re-enable

## Overview

Homarr is a sleek, modern dashboard that puts all your apps and services at your fingertips. It integrates seamlessly with your Docker containers and provides real-time information through customizable widgets.

## Features

- **Docker Integration** - Manage containers directly from the dashboard (start, stop, restart)
- **Status Monitoring** - See which services are up or down at a glance
- **Customizable Widgets** - Add clocks, weather, system stats, and more
- **App Icons & Organization** - Beautiful icons and drag-and-drop organization
- **Search Functionality** - Quick search to find any app
- **Category Management** - Group apps by category

## Access

- **Subdomain:** `panel.*`
- **Port:** 7575
- **URL:** `https://panel.YOURDOMAIN.com`

## Configuration

### Docker Compose

```yaml
services:
  homarr:
    image: ghcr.io/homarr-labs/homarr:latest
    container_name: homarr
    restart: always
    environment:
      - SECRET_ENCRYPTION_KEY=CHANGE_ME_TO_RANDOM_64_CHAR_HEX_STRING
    volumes:
      - homarr_data:/appdata
      # Optional: Mount Docker socket for container management
      # - /var/run/docker.sock:/var/run/docker.sock
    ports:
      - "7575:7575"

volumes:
  homarr_data:
```

### ⚠️ IMPORTANT: Security Configuration

**You MUST change the SECRET_ENCRYPTION_KEY before deploying!**

The current configuration has a hardcoded encryption key for demonstration purposes only. To generate a secure key:

```bash
openssl rand -hex 32
```

Then update the `SECRET_ENCRYPTION_KEY` environment variable in `docker-compose.yml`.

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SECRET_ENCRYPTION_KEY` | 64-character hex string for encryption | Yes |

## Use Cases

- **Server Dashboard** - Central hub for all your self-hosted applications
- **Docker Management** - Control containers without SSH
- **Service Monitoring** - Visual status of all your services
- **Quick Access** - One-click access to all your tools

## First Time Setup

1. Navigate to `https://panel.YOURDOMAIN.com`
2. Create your admin account
3. Add your applications by clicking the "+" button
4. Configure app URLs, icons, and categories
5. (Optional) Mount Docker socket for container management

## Tips

- **Docker Integration:** Mount `/var/run/docker.sock` to enable container management widgets
- **Icons:** Homarr automatically fetches icons from Dashboard Icons or you can upload custom ones
- **Categories:** Organize apps by function (e.g., Media, Development, Monitoring)
- **Widgets:** Add useful widgets like clock, weather, or system stats
- **Ping:** Enable ping checks to see real-time service status

## Note on Subdomain

This app uses `panel.*` instead of `home.*` to avoid conflict with the main Dashboard app.

## Links

- [Official Documentation](https://homarr.dev)
- [GitHub Repository](https://github.com/homarr-labs/homarr)
