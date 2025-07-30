#!/bin/bash

# Custom entrypoint script for MongoDB with replica set
# This script sets proper permissions for the keyfile before starting MongoDB

set -e

echo "Setting up MongoDB replica set..."

# Set proper permissions for keyfile
if [ -f "/etc/mongodb-keyfile" ]; then
    echo "Setting keyfile permissions..."
    chmod 400 /etc/mongodb-keyfile
    chown 999:999 /etc/mongodb-keyfile
fi

# Execute the original entrypoint
exec /usr/local/bin/docker-entrypoint.sh "$@" 