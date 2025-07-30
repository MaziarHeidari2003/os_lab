#!/bin/bash

# ------------------------------
# Backup Script with CLI Menu
# ------------------------------


CONFIG_FILE="backup.conf"
LOG_FILE="backup.log"
DAYS_TO_KEEP=7

show_menu() {
    echo "=============================="
    echo "         Backup Menu        "
    echo "=============================="
    echo "1. Set Source Directory"
    echo "2. Set File Extension"
    echo "3. Set Backup Destination"
    echo "4. Run Backup"
    echo "5. Dry-run"
    echo "6. View Log"
    echo "7. Clean old backups"
    echo "0. Exit"
    echo "=============================="
}


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


dry_run() {
    echo "🧪 Dry-run mode enabled."
    if [[ -z "$SOURCE_DIR" || -z "$FILE_EXT" ]]; then
        echo "❗ Please set source and file extension first!"
        return
    fi
    echo " Files to be backed up:"
    find "$SOURCE_DIR" -type f -name "*$FILE_EXT"
}

clean_old_backups() {
    echo "🧹 Removing backups older than $DAYS_TO_KEEP days..."
    find "$BACKUP_DIR" -type f -name "backup_*" -mtime +$DAYS_TO_KEEP -exec rm -f {} \;
    echo "✅ Cleanup completed."
}


view_log() {
    echo "📜 Backup Log:"
    cat "$LOG_FILE"
}


while true; do
    show_menu
    read -p "Select an option: " CHOICE
    case $CHOICE in
        1)
            read -p "Enter source directory: " SOURCE_DIR
            ;;
        2)
            read -p "Enter file extension (e.g. .txt): " FILE_EXT
            ;;
        3)
            read -p "Enter backup destination directory: " BACKUP_DIR
            ;;
        4)
            run_backup
            ;;
        5)
            dry_run
            ;;
        6)
            view_log
            ;;
        7)
            clean_old_backups
            ;;
        0)
            echo "👋 Goodbye!"
            break
            ;;
        *)
            echo "❗ Invalid option"
            ;;
    esac
    echo ""
done
