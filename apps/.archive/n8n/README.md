# n8n

**Status:** Archived (Disabled) - Move out of `.archive/` to re-enable

## Overview

n8n is a powerful workflow automation tool that lets you connect different services and automate tasks without writing code. Think of it as a self-hosted alternative to Zapier, Make (Integromat), or Microsoft Power Automate.

## Features

- **Visual Workflow Builder** - Drag-and-drop interface to create automations
- **400+ Integrations** - Connect to popular services (Slack, Gmail, Discord, GitHub, etc.)
- **Self-Hosted** - Full control over your data and workflows
- **JavaScript Support** - Add custom code when needed
- **Error Handling** - Built-in retry logic and error notifications
- **Webhook Triggers** - Start workflows from external events
- **Scheduling** - Run workflows on a schedule (cron-like)

## Access

- **Subdomain:** `n8n.*`
- **Port:** 5678
- **URL:** `https://n8n.YOURDOMAIN.com`

## Configuration

### Docker Compose

```yaml
services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: always
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    environment:
      - N8N_HOST=${DOMAIN_NAME}
      - TZ=Asia/Kolkata

volumes:
  n8n_data:
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `N8N_HOST` | Domain name for n8n instance | `${DOMAIN}` |
| `TZ` | Timezone for scheduled workflows | `Asia/Kolkata` |

**Optional Security Variables:**

```yaml
environment:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=admin
  - N8N_BASIC_AUTH_PASSWORD=securepassword123
  - N8N_ENCRYPTION_KEY=your-random-key-here
```

## Use Cases

### Common Automations

- **Social Media** - Auto-post from RSS feeds to Twitter/LinkedIn
- **Notifications** - Send Discord/Slack alerts from GitHub/GitLab webhooks
- **Data Processing** - Transform and move data between services
- **Email Processing** - Parse incoming emails and trigger actions
- **File Management** - Auto-organize files in cloud storage
- **Monitoring** - Check websites and alert on downtime

### Example Workflows

1. **New GitHub Star → Discord Notification**
   - Trigger: GitHub webhook (star event)
   - Action: Send message to Discord channel

2. **RSS Feed → Social Media Posts**
   - Trigger: RSS feed update
   - Action: Post to Twitter with article link

3. **Form Submission → Database + Email**
   - Trigger: Webhook from contact form
   - Action: Save to database + send confirmation email

## First Time Setup

1. Navigate to `https://n8n.YOURDOMAIN.com`
2. Create your owner account (first user becomes admin)
3. Click "Add Workflow" to create your first automation
4. Select a trigger (e.g., Webhook, Schedule, or Service)
5. Add actions and connect nodes
6. Activate the workflow

## Security Recommendations

**Enable Basic Authentication:**

Add to `docker-compose.yml`:
```yaml
environment:
  - N8N_BASIC_AUTH_ACTIVE=true
  - N8N_BASIC_AUTH_USER=your-username
  - N8N_BASIC_AUTH_PASSWORD=your-secure-password
```

**Set Encryption Key:**
```yaml
environment:
  - N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
```

## Tips

- **Start Simple:** Begin with basic workflows and add complexity gradually
- **Test Mode:** Use "Execute Workflow" to test before activating
- **Error Handling:** Add error workflows to handle failures gracefully
- **Credentials:** Store API keys securely in n8n's credential manager
- **Workflow Sharing:** Export/import workflows as JSON files
- **Community:** Check the n8n community for pre-built workflows

## Important Notes

- **First user** becomes the owner with admin privileges
- **Workflows run** on the server where n8n is installed
- **Data persistence** is handled via the Docker volume
- **Resource usage** depends on workflow complexity and frequency

## Links

- [Official Website](https://n8n.io)
- [Documentation](https://docs.n8n.io)
- [Workflow Library](https://n8n.io/workflows)
- [Community Forum](https://community.n8n.io)
