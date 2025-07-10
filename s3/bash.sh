#!/bin/bash

# --- CONFIGURATION ---
BACKUP_DIR=~/mongodb_backup/mongodump           # Local backup directory
TIMESTAMP=$(date +"%F-%H-%M-%S")                 # Current timestamp
DUMP_DIR="$BACKUP_DIR/backup-$TIMESTAMP"        # Temporary dump folder
ARCHIVE_NAME="mongo-backup-$TIMESTAMP.tar.gz"   # Archive name
S3_BUCKET="fr-s3-public"                        # S3 bucket name
S3_PREFIX="mongodump/"                          # Path inside S3 bucket

# --- Ensure backup folder exists ---
mkdir -p "$DUMP_DIR"

# --- Run mongodump ---
echo "Dumping MongoDB..."
mongodump --out "$DUMP_DIR"

if [ $? -eq 0 ]; then
    echo "Compressing backup..."
    tar -czvf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$DUMP_DIR" .
    echo "Backup created at: $BACKUP_DIR/$ARCHIVE_NAME"

    # Optionally remove the raw dump
    rm -rf "$DUMP_DIR"
else
    echo "mongodump failed"
    exit 1
fi

# --- Upload to S3 ---
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
S3_KEY="${S3_PREFIX}${ARCHIVE_NAME}"

echo "Uploading $ARCHIVE_NAME to s3://$S3_BUCKET/$S3_KEY"
aws s3 cp "$ARCHIVE_PATH" "s3://$S3_BUCKET/$S3_KEY"

if [ $? -eq 0 ]; then
    echo "$ARCHIVE_NAME uploaded successfully."
    
    # Rename the uploaded file
    mv "$ARCHIVE_PATH" "$BACKUP_DIR/${ARCHIVE_NAME%.tar.gz}-uploaded.tar.gz"
    echo "Backup file renamed to: ${ARCHIVE_NAME%.tar.gz}-uploaded.tar.gz"
    
    echo "URL: https://$S3_BUCKET.s3.us-east-1.amazonaws.com/$S3_KEY"
else
    echo "Failed to upload $ARCHIVE_NAME to S3."
    exit 1
fi
