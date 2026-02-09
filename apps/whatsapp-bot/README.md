# 🤖 WhatsApp Bot

A simple WhatsApp bot built with [Baileys](https://github.com/WhiskeySockets/Baileys) that listens to commands in a specific group.

## Features

- **Persistent session** — Scan QR once, stays logged in via Docker volume
- **Group-locked** — Only responds to commands in the configured group
- **Lightweight** — Runs on Node.js Alpine image (~55MB)

## Commands

| Command  | Description                  |
| -------- | ---------------------------- |
| `.ping`  | Check if bot is alive        |
| `.time`  | Get current India time (IST) |
| `.start` | Confirm bot is listening     |
| `.help`  | Show command menu            |

## Configuration

Set the target group via environment variable. The `ALLOWED_GROUP_ID` is set in GitHub Secrets and injected during deployment.

To test locally, create a `.env` file in the repository root:

```
ALLOWED_GROUP_ID=YOUR_GROUP_ID@g.us
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
| `Dockerfile`         | Node.js 20 Alpine container               |
| `.dockerignore`      | Excludes unnecessary files from build     |
| `auth_info_baileys/` | Session data (auto-generated, gitignored) |

## Initialization

> [!NOTE]
> This app includes an `init.sh` script that automatically sets correct permissions (`1000:1000`) for the `auth_info_baileys/` directory during deployment.

## First-Time Setup

1. Deploy the stack: `docker compose up -d`
2. View QR code: `docker logs -f whatsapp-bot`
3. Scan QR with your WhatsApp mobile app
4. Bot will confirm connection in the configured group

> [!NOTE]
> The session persists across restarts via the mounted `auth_info_baileys/` volume. You only need to scan QR once.
