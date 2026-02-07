#!/usr/bin/env python3
"""Simple Telegram Bot for VPS Stack"""

import os
import sys
import logging
from datetime import datetime

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
        "/time - Current server time",
        parse_mode="Markdown"
    )

async def ping(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Simple ping response."""
    await update.message.reply_text("🏓 Pong!")

async def time_cmd(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Show current server time."""
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    await update.message.reply_text(f"🕐 Server Time: `{now}`", parse_mode="Markdown")

def main() -> None:
    """Start the bot."""
    if not TOKEN:
        logger.error("TG_BOT_TOKEN not set!")
        sys.exit(1)

    app = Application.builder().token(TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("help", start))
    app.add_handler(CommandHandler("ping", ping))
    app.add_handler(CommandHandler("time", time_cmd))

    logger.info("Bot starting...")
    app.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
