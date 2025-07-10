
#!/bin/bash

# Configuration
BACKUP_DIR=~/mongodb_backup/mongodump/
TIMESTAMP=$(date +"%F-%H-%M-%S")
DUMP_DIR="$BACKUP_DIR/backup-$TIMESTAMP"
ARCHIVE_NAME="mongo-backup-$TIMESTAMP.tar.gz"

# Create backup directory
mkdir -p "$DUMP_DIR"

# Run mongodump
echo "Dumping MongoDB..."
mongodump --out "$DUMP_DIR"

# Check success and compress
if [ $? -eq 0 ]; then
    echo "Compressing backup..."
    tar -czvf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$DUMP_DIR" .
    echo "Backup created at: $BACKUP_DIR/$ARCHIVE_NAME"
    
    # Optionally delete the raw dump
    rm -rf "$DUMP_DIR"
else
    echo "mongodump failed"
    exit 1
fi
