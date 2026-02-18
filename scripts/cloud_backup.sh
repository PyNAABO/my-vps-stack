#!/bin/bash

# Configuration
# Resolve vps-data relative to this script (scripts/ -> ../vps-data)
VPS_DATA="$(readlink -f "$(dirname "$0")/../../vps-data" 2>/dev/null || echo "$HOME/vps-data")"
SOURCE_DIRS=("$HOME" "$VPS_DATA")
DEST_REMOTE="gdrive:VPS_Backup"
FILTER_FILE="$(dirname "$0")/../config/backup_filter.txt"
LOG_FILE="/var/log/rclone_backup.log"

# Strict error handling with trap
set -e
trap 'echo "❌ Backup FAILED at $(date). Check $LOG_FILE for details." >&2; exit 1' ERR

# Validate filter file
if [ ! -f "$FILTER_FILE" ]; then
  echo "❌ Filter file not found: $FILTER_FILE"
  exit 1
fi

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
