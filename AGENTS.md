# Agent Guidelines

This document provides guidelines for AI assistants working on the my-vps-stack repository.

## Quick Reference

```bash
# Validate docker-compose syntax
docker compose config

# Check for shell script errors
shellcheck scripts/*.sh

# List all app directories
ls -la apps/

# Check git status
git status
```

## Repository Structure

```
my-vps-stack/
├── apps/              # Application containers (active and archived)
├── config/            # Configuration files
├── docs/              # Additional documentation
├── scripts/           # Utility scripts
├── .github/workflows/ # CI/CD automation
├── CONVENTIONS.md     # Coding standards
└── README.md          # Main documentation
```

## Common Tasks

### Adding a New App

1. Copy template: `cp -r apps/.template apps/myapp`
2. Edit `docker-compose.yml` with proper image and configuration
3. Add `ingress.yml` if web-accessible
4. Add `init.sh` if setup needed
5. Write `README.md` following CONVENTIONS.md template
6. Add icon to `apps/dashboard/icons.conf`
7. Test: `docker compose -f apps/myapp/docker-compose.yml config`

### Modifying an Existing App

1. Read the app's `README.md` for context
2. Check `docker-compose.yml` for dependencies
3. Update `init.sh` if adding new directories
4. Update `README.md` if changing functionality
5. Validate: `docker compose -f apps/<app>/docker-compose.yml config`

### Troubleshooting Deployments

Common commands:
```bash
# View container logs
docker logs <container-name>

# Check container status
docker ps -a

# Restart a service
docker compose restart <service>

# View tunnel config
cat config/tunnel/config.yml
```

## Security Reminders

### NEVER
- Hardcode secrets in any file
- Expose ports directly (use Cloudflare Tunnel)
- Run containers as root unless necessary
- Commit sensitive configuration

### ALWAYS
- Use GitHub Secrets for sensitive data
- Run containers with `no-new-privileges:true`
- Use `1000:1000` ownership for data
- Validate YAML syntax before committing

## Docker Compose Validation

Before committing changes, validate syntax:

```bash
# Validate single app
docker compose -f apps/<app>/docker-compose.yml config

# Validate entire stack (from repo root)
docker compose config
```

## Shell Script Standards

All `init.sh` scripts should:

1. Use `#!/bin/bash` shebang
2. Resolve paths dynamically:
   ```bash
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   ```
3. Set ownership to `1000:1000`:
   ```bash
   chown -R 1000:1000 "$DATA_DIR"
   ```
4. Be executable: `chmod +x init.sh`

## Testing Checklist

Before suggesting commits:

- [ ] Docker compose files are valid YAML
- [ ] No hardcoded secrets or credentials
- [ ] Paths use relative references (`../vps-data/`)
- [ ] File permissions are set correctly (1000:1000)
- [ ] README.md updated if functionality changed
- [ ] Icons.conf updated if adding web app
- [ ] No port conflicts with existing apps
- [ ] Security options included (no-new-privileges)

## Common Patterns

### Volume Mounts

**App-specific data:**
```yaml
volumes:
  - ./data:/app/data
```

**Shared data:**
```yaml
volumes:
  - ../vps-data/downloads:/downloads
```

### Environment Variables

Reference from `.env`:
```yaml
environment:
  - DOMAIN_NAME=${DOMAIN_NAME}
```

### Health Checks

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### Cloudflare Tunnel Routing

```yaml
# ingress.yml
hostname: myapp
service: http://myapp:8080
```

## File Locations Reference

| File Type | Location | Example |
| :-------- | :------- | :-------- |
| App compose | `apps/<app>/docker-compose.yml` | `apps/portainer/docker-compose.yml` |
| App docs | `apps/<app>/README.md` | `apps/filebrowser/README.md` |
| Tunnel routing | `apps/<app>/ingress.yml` | `apps/dashboard/ingress.yml` |
| Init scripts | `apps/<app>/init.sh` | `apps/qbittorrent/init.sh` |
| Icons config | `apps/dashboard/icons.conf` | All icons defined here |
| Main compose | `docker-compose.yml` | Auto-generated |
| Deploy workflow | `.github/workflows/deploy.yml` | CI/CD pipeline |
| Shared scripts | `scripts/*.sh` | Utility scripts |

## Troubleshooting Guide

### "Container not starting"

1. Check logs: `docker logs <container>`
2. Verify image exists: `docker images | grep <app>`
3. Check volume permissions: `ls -la ../vps-data/`

### "Permission denied"

1. Check ownership: `ls -la apps/<app>/`
2. Ensure init.sh ran: `docker logs <app>`
3. Fix permissions: `chown -R 1000:1000 ../vps-data/`

### "Port already in use"

1. Find conflicting container: `docker ps --format "table {{.Names}}\t{{.Ports}}"`
2. Change port in app's docker-compose.yml
3. Update ingress.yml if needed

### "Tunnel not routing"

1. Check tunnel config: `cat config/tunnel/config.yml`
2. Verify credentials: `ls -la config/tunnel/`
3. Check tunnel logs: `docker logs cloudflare-tunnel`

## Communication Guidelines

When assisting users:

1. **Be concise** - Focus on the specific task
2. **Show commands** - Provide exact commands when possible
3. **Explain why** - Briefly explain the reasoning
4. **Verify safety** - Check for security issues
5. **Test when possible** - Validate docker-compose syntax

## Questions?

If uncertain about:
- **Standards** → Check `CONVENTIONS.md`
- **App specifics** → Read the app's `README.md`
- **Examples** → Look at existing apps in `apps/`
- **Security** → Refer to Security Guidelines section above
