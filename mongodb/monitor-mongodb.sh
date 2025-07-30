#!/bin/bash

# MongoDB Monitoring Script
# This script monitors MongoDB health and security

set -e

CONTAINER_NAME="mongodb"
LOG_FILE="/tmp/mongodb-monitoring.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if container is running
if ! docker ps --format "table {{.Names}}" | grep -q "$CONTAINER_NAME"; then
    log_message "ERROR: MongoDB container is not running!"
    exit 1
fi

# Check MongoDB connectivity
if docker exec "$CONTAINER_NAME" mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    log_message "INFO: MongoDB is responding to ping"
else
    log_message "ERROR: MongoDB is not responding to ping"
fi

# Check for failed authentication attempts
FAILED_AUTH=$(docker logs "$CONTAINER_NAME" --since 1h 2>&1 | grep -c "Authentication failed" || true)
if [ "$FAILED_AUTH" -gt 0 ]; then
    log_message "WARNING: $FAILED_AUTH failed authentication attempts in the last hour"
fi

# Check for connection attempts from unauthorized IPs
UNAUTHORIZED_CONN=$(docker logs "$CONTAINER_NAME" --since 1h 2>&1 | grep -c "connection refused" || true)
if [ "$UNAUTHORIZED_CONN" -gt 0 ]; then
    log_message "WARNING: $UNAUTHORIZED_CONN unauthorized connection attempts in the last hour"
fi

# Check disk usage
DISK_USAGE=$(docker exec "$CONTAINER_NAME" df /data/db | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    log_message "WARNING: Disk usage is ${DISK_USAGE}%"
fi

log_message "INFO: Monitoring check completed" 