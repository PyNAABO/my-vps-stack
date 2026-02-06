#!/bin/bash

# Configuration
SOURCE_DIRS=("/root" "/opt/seedbox")
DEST_REMOTE="gdrive:VPS_Backup"
FILTER_FILE="/root/my-vps-stack/backup_filter.txt"
LOG_FILE="/var/log/rclone_backup.log"

echo "☁️ Starting Cloud Backup at $(date)..."

# Sync each source directory
for SRC in "${SOURCE_DIRS[@]}"; do
  BASENAME=$(basename "$SRC")
  echo "📁 Backing up $SRC -> $DEST_REMOTE/$BASENAME"
  rclone sync "$SRC" "$DEST_REMOTE/$BASENAME" \
    --filter-from "$FILTER_FILE" \
    --create-empty-src-dirs \
    -v \
    >> "$LOG_FILE" 2>&1
done

echo "✅ Backup Completed at $(date)."
