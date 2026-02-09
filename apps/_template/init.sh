#!/bin/bash
# Init script - runs automatically on first deploy
# Use this for:
# - Creating config directories
# - Setting permissions
# - Database initialization
# - One-time setup tasks

# Example: Create data directory
# mkdir -p "$(dirname "$0")/data"

# Example: Set ownership for non-root containers
# chown -R 1000:1000 "$(dirname "$0")/data"

echo "✓ MyApp initialized"
