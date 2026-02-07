# 🤖 Telegram Bot

A simple Telegram bot for VPS monitoring and quick commands.

## Commands

| Command       | Description                           |
| ------------- | ------------------------------------- |
| `/start`      | Show welcome message and command list |
| `/ping`       | Check if bot is alive                 |
| `/time`       | Get current server time               |
| `/uptime`     | Show server uptime                    |
| `/containers` | List running Docker containers        |

### BotFather Setup

Send this to [@BotFather](https://t.me/BotFather) via `/setcommands`:

```
start - Show welcome message and command list
ping - Check if bot is alive
time - Get current server time
uptime - Show server uptime
containers - List running Docker containers
```

## Configuration

The bot token is set via the `TG_BOT_TOKEN` environment variable, which is injected from GitHub Secrets during deployment.

To get a bot token:

1. Message [@BotFather](https://t.me/BotFather) on Telegram
2. Send `/newbot` and follow the prompts
3. Copy the token and add it to GitHub Secrets as `TG_BOT_TOKEN`

## Files

| File               | Purpose                            |
| ------------------ | ---------------------------------- |
| `bot.py`           | Main bot logic                     |
| `Dockerfile`       | Python 3.12 Alpine container       |
| `requirements.txt` | Dependencies (python-telegram-bot) |

## Adding New Commands

Edit `bot.py` and add a new handler:

```python
async def mycommand(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    await update.message.reply_text("Response here")

# In main():
app.add_handler(CommandHandler("mycommand", mycommand))
```
