# App Template

Copy this folder to `apps/myapp/` and customize for your new app.

## Required Files

### docker-compose.yml
Define your service(s) here. This file is **auto-included** in the main compose.

```yaml
services:
  myapp:
    image: myapp/image:latest
    container_name: myapp
    restart: always
    ports:
      - "3000:3000"
    # Add volumes for persistence:
    volumes:
      - ./data:/app/data
```

## Optional Files

### ingress.yml
**Only needed if you want a web UI.**
Auto-configures Cloudflare Tunnel routing + Dashboard tile.

```yaml
hostname: myapp      # Results in: myapp.yourdomain.com
service: http://myapp:3000
```

### init.sh
**Optional first-time setup script.**
Auto-executed on deploy. Use for:
- Creating config directories
- Setting permissions
- Database initialization

```bash
#!/bin/bash

# Create persistent data directory
mkdir -p apps/myapp/data

# Set ownership (if running as non-root)
# chown -R 1000:1000 apps/myapp/data

echo "✓ MyApp initialized"
```

### README.md
Document your app's:
- Purpose
- Default credentials
- Configuration notes
- Customization options

## Dashboard Icons

Add your app name to `apps/dashboard/icons.conf` for a custom emoji:

```
myapp=🚀
```

If not specified, your app gets a generic 🔗 icon.

## File Structure

```
apps/myapp/
├── docker-compose.yml    # Required - service definition
├── ingress.yml           # Optional - web access via tunnel
├── init.sh               # Optional - first-time setup
└── README.md             # Optional - documentation
```

## Secrets/Environment Variables

If your app needs secrets:

1. Add secret to GitHub → Settings → Secrets and variables → Actions
2. Edit `.github/workflows/deploy.yml` Step 5 to inject it:
   ```bash
   echo "MYAPP_SECRET=${{ secrets.MYAPP_SECRET }}" >> .env
   ```
3. Reference in docker-compose.yml:
   ```yaml
   environment:
     - MYAPP_SECRET=${MYAPP_SECRET}
   ```

## Quick Start

```bash
# 1. Copy template
cp -r apps/.template apps/myapp

# 2. Edit files
cd apps/myapp
nano docker-compose.yml
nano ingress.yml

# 3. Add icon (optional)
echo "myapp=🚀" >> ../dashboard/icons.conf

# 4. Commit and push
git add ..
git commit -m "Add myapp"
git push
```

That's it! The deploy workflow will automatically:
- ✅ Include your app in docker-compose.yml
- ✅ Configure tunnel routing (if ingress.yml exists)
- ✅ Create dashboard tile (if ingress.yml exists)
- ✅ Run init.sh (if exists)
