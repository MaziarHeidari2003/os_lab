#!/bin/bash

# ------------------------------
# Backup Script with CLI Menu
# ------------------------------

CONFIG_FILE="backup.conf"
LOG_FILE="backup.log"
DAYS_TO_KEEP=7




run_backup() {
    echo "📦 Starting full backup..."

    if [[ -z "$SOURCE_DIR" || -z "$FILE_EXT" || -z "$BACKUP_DIR" ]]; then
        echo "❗ Please set source, extension, and destination first!"
        return
    fi

    echo "🔍 Scanning for *$FILE_EXT files..."
    find "$SOURCE_DIR" -type f -name "*$FILE_EXT" > "$CONFIG_FILE"

    TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
    BACKUP_NAME="backup_$TIMESTAMP.tar.gz"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    mkdir -p "$BACKUP_DIR"
    START_TIME=$(date +%s)

    echo "🗜️  Creating compressed backup..."
    tar -czf "$BACKUP_PATH" -T "$CONFIG_FILE" 2>/dev/null

    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    SIZE=$(du -h "$BACKUP_PATH" | cut -f1)

    STATUS=$?
    if [[ $STATUS -eq 0 ]]; then
        echo "✅ Backup succeeded at $TIMESTAMP - Size: $SIZE - Duration: ${DURATION}s" >> "$LOG_FILE"
        echo "✔️  Backup completed: $BACKUP_PATH"
    else
        echo "❌ Backup failed at $TIMESTAMP - Duration: ${DURATION}s" >> "$LOG_FILE"
        echo "❌ Backup failed."
    fi
}
