#!/bin/bash

# Configuration
SOURCE_DIR="/root"
DEST_REMOTE="gdrive:VPS_Root_Backup"
FILTER_FILE="/root/my-vps-stack/backup_filter.txt"
LOG_FILE="/var/log/rclone_backup.log"

echo "☁️ Starting Cloud Backup at $(date)..."

# Sync Command
# -v: Verbose (logs what it's doing)
# --filter-from: Uses our rules file
# --delete-excluded: Deletes files on Drive if they match the exclude list (keeps it clean)
rclone sync $SOURCE_DIR $DEST_REMOTE \
  --filter-from $FILTER_FILE \
  --create-empty-src-dirs \
  -v \
  >> $LOG_FILE 2>&1

echo "✅ Backup Completed at $(date)."
