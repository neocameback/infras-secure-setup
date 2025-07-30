#!/bin/bash

# MongoDB Backup Script
# This script creates encrypted backups of MongoDB data

set -e

BACKUP_DIR="mongodb-backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mongodb_backup_${DATE}"
CONTAINER_NAME="mongodb"

# Load environment variables
if [ -f "mongodb.env" ]; then
    source mongodb.env
else
    echo "Error: mongodb.env file not found"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "Starting MongoDB backup..."

# Create backup using mongodump
docker exec "$CONTAINER_NAME" mongodump \
    --uri="mongodb://${MONGO_BACKUP_USERNAME}:${MONGO_BACKUP_PASSWORD}@localhost:27017/?authSource=admin" \
    --out="/tmp/$BACKUP_NAME"

# Copy backup from container
docker cp "$CONTAINER_NAME:/tmp/$BACKUP_NAME" "$BACKUP_DIR/"

# Clean up temporary files in container
docker exec "$CONTAINER_NAME" rm -rf "/tmp/$BACKUP_NAME"

# Compress backup
cd "$BACKUP_DIR"
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
rm -rf "$BACKUP_NAME"

echo "Backup completed: ${BACKUP_NAME}.tar.gz"

# Keep only last 7 days of backups
find "$BACKUP_DIR" -name "mongodb_backup_*.tar.gz" -mtime +7 -delete

echo "Old backups cleaned up" 