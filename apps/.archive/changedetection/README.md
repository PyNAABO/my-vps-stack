# ChangeDetection.io

**Status:** Archived (Disabled) - Move out of `.archive/` to re-enable

## Overview

ChangeDetection.io is a self-hosted, open-source website change detection and monitoring service. Track changes on any website and receive notifications when content is modified.

## Features

- **Visual Diff Comparisons** - See exactly what changed with side-by-side comparisons
- **CSS/XPath Selectors** - Monitor specific parts of a webpage, not the entire page
- **Notifications** - Get alerts via email, Slack, Discord, webhooks, and more
- **JavaScript Support** - Monitor dynamic content and single-page applications
- **PDF Monitoring** - Track changes in PDF documents
- **REST API** - Programmatic access for automation

## Access

- **Subdomain:** `watch.*`
- **Port:** 5000
- **URL:** `https://watch.YOURDOMAIN.com`

## Configuration

### Docker Compose

```yaml
services:
  changedetection:
    image: ghcr.io/dgtlmoon/changedetection.io:latest
    container_name: changedetection
    restart: always
    volumes:
      - changedetection_data:/datastore
    ports:
      - "5000:5000"
    environment:
      - BASE_URL=https://watch.${DOMAIN_NAME}

volumes:
  changedetection_data:
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `BASE_URL` | The base URL for the application | `https://watch.${DOMAIN}` |

## Use Cases

- **Price Monitoring** - Track product prices on e-commerce sites
- **Job Listings** - Get notified of new job postings
- **News & Updates** - Monitor news sites and blogs for new articles
- **Competitor Tracking** - Watch competitor websites for changes
- **Restock Alerts** - Get notified when out-of-stock items become available

## First Time Setup

1. Navigate to `https://watch.YOURDOMAIN.com`
2. No authentication by default (add via settings if needed)
3. Click "+ Watch" to add your first website to monitor
4. Configure check interval and notification preferences

## Tips

- Use CSS selectors to monitor specific elements (e.g., price, title)
- Set reasonable check intervals to avoid being rate-limited
- Enable visual diffs for easier change detection
- Use filters to ignore dynamic content (ads, timestamps, etc.)

## Links

- [GitHub Repository](https://github.com/dgtlmoon/changedetection.io)
- [Official Website](https://changedetection.io)
