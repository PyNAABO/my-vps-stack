#!/bin/bash

# Create authentication directory if it doesn't exist
mkdir -p apps/whatsapp-bot/auth_info_baileys

# Set ownership to node user (uid 1000)
# This is required because the bot runs as a non-root user in the container
chown -R 1000:1000 apps/whatsapp-bot/auth_info_baileys

echo "✓ WhatsApp Bot directory initialized and permissions set."
