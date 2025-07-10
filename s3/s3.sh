#!/bin/bash

# --- CONFIGURATION ---
S3_BUCKET="fr-s3-public"           # S3 bucket name
S3_PREFIX="macbook/"              # Path inside the bucket
BACKUP_DIR="./mongodump/"             # Local backup directory

# --- Ensure backup folder exists ---
mkdir -p "$BACKUP_DIR"

# --- Loop over all .txt files in current directory ---
for FILE in *.gz; do
    # Skip if no .txt files are found
    [ -e "$FILE" ] || { echo "No backup files found."; exit 0; }

    S3_KEY="${S3_PREFIX}${FILE}"

    echo "Uploading $FILE to s3://$S3_BUCKET/$S3_KEY"
    aws s3 cp "$FILE" "s3://$S3_BUCKET/$S3_KEY"

    if [ $? -eq 0 ]; then
        echo "$FILE uploaded successfully."
        mv "$FILE" "$BACKUP_DIR/"
        echo "Moved $FILE to $BACKUP_DIR/"
        echo "URL: https://$S3_BUCKET.s3.us-east-1.amazonaws.com/$S3_KEY"
    else
        echo "Failed to upload $FILE. Skipping move."
    fi

    echo "---------------------------------------------"
done
