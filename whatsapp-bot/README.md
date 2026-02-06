# 🤖 WhatsApp Bot

A simple WhatsApp bot built with [Baileys](https://github.com/WhiskeySockets/Baileys) that listens to commands in a specific group.

## Features

- **Persistent session** — Scan QR once, stays logged in via Docker volume
- **Group-locked** — Only responds to commands in the configured group
- **Lightweight** — Runs on Node.js Alpine image

## Commands

| Command  | Description                  |
| -------- | ---------------------------- |
| `.ping`  | Check if bot is alive        |
| `.time`  | Get current India time (IST) |
| `.start` | Confirm bot is listening     |
| `.help`  | Show command menu            |

## Configuration

Set the target group via environment variable in `docker-compose.yml`:

```yaml
whatsapp-bot:
  build: ./whatsapp-bot
  environment:
    - ALLOWED_GROUP_ID=YOUR_GROUP_ID@g.us
```

## Getting Your Group ID

Use the helper script to discover group IDs:

```bash
node get_id.js
```

Send any message to a group while this is running, and the group ID will be printed to the console.

## Files

| File                 | Purpose                                   |
| -------------------- | ----------------------------------------- |
| `index.js`           | Main bot logic                            |
| `get_id.js`          | Helper to discover group IDs              |
| `Dockerfile`         | Container build config                    |
| `auth_info_baileys/` | Session data (auto-generated, gitignored) |
