#!/usr/bin/env python3
"""Simple Telegram Bot for VPS Stack"""

import os
import logging
from datetime import datetime
import subprocess

from telegram import Update
from telegram.ext import Application, CommandHandler, ContextTypes

# Logging
logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO
)
logger = logging.getLogger(__name__)

TOKEN = os.environ.get("TG_BOT_TOKEN")

# Commands
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Send welcome message."""
    await update.message.reply_text(
        "👋 *VPS Bot Online!*\n\n"
        "Commands:\n"
        "/ping - Check if bot is alive\n"
        "/time - Current server time\n"
        "/uptime - Server uptime\n"
        "/containers - List running containers",
        parse_mode="Markdown"
    )

async def ping(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Simple ping response."""
    await update.message.reply_text("🏓 Pong!")

async def time_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Show current server time."""
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    await update.message.reply_text(f"🕐 Server Time: `{now}`", parse_mode="Markdown")

async def uptime(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Show server uptime."""
    try:
        result = subprocess.run(["uptime", "-p"], capture_output=True, text=True)
        uptime_str = result.stdout.strip() or "Unknown"
    except Exception:
        uptime_str = "Unable to fetch uptime"
    await update.message.reply_text(f"⏱️ {uptime_str}")

async def containers(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """List running Docker containers."""
    try:
        result = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}: {{.Status}}"],
            capture_output=True, text=True
        )
        container_list = result.stdout.strip() or "No containers running"
    except Exception:
        container_list = "Unable to fetch containers"
    await update.message.reply_text(f"📦 *Running Containers:*\n```\n{container_list}\n```", parse_mode="Markdown")

def main() -> None:
    """Start the bot."""
    if not TOKEN:
        logger.error("TG_BOT_TOKEN not set!")
        return

    app = Application.builder().token(TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", start))
    app.add_handler(CommandHandler("ping", ping))
    app.add_handler(CommandHandler("time", time_cmd))
    app.add_handler(CommandHandler("uptime", uptime))
    app.add_handler(CommandHandler("containers", containers))

    logger.info("Bot starting...")
    app.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
