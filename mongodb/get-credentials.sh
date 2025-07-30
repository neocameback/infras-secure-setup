#!/bin/bash

# Secure Credentials Display Script
# This script safely displays MongoDB credentials

echo "=== MongoDB Credentials ==="
echo ""

# Check if mongodb.env exists
if [ ! -f "mongodb.env" ]; then
    echo "❌ Error: mongodb.env file not found!"
            echo "Please check if mongodb.env file exists and contains credentials"
    exit 1
fi

# Check file permissions
if [ "$(stat -c %a mongodb.env 2>/dev/null)" != "600" ]; then
    echo "⚠️  Warning: mongodb.env file permissions are not secure (should be 600)"
    echo "Fixing permissions..."
    chmod 600 mongodb.env
fi

echo "🔐 MongoDB Credentials (from mongodb.env):"
echo "=========================================="
echo ""

# Display credentials with clear labels
echo "Root User (Admin):"
echo "  Username: admin"
echo "  Password: $(grep MONGO_ROOT_PASSWORD mongodb.env | cut -d'=' -f2)"
echo ""

echo "Application User:"
echo "  Username: appuser"
echo "  Password: $(grep MONGO_APP_PASSWORD mongodb.env | cut -d'=' -f2)"
echo "  Database: myapp"
echo "  Auth Source: myapp"
echo ""

echo "Monitor User:"
echo "  Username: monitor"
echo "  Password: $(grep MONGO_MONITOR_PASSWORD mongodb.env | cut -d'=' -f2)"
echo ""

echo "Backup User:"
echo "  Username: backup"
echo "  Password: $(grep MONGO_BACKUP_PASSWORD mongodb.env | cut -d'=' -f2)"
echo ""

echo "Mongo Express:"
echo "  Username: admin"
echo "  Password: $(grep ME_PASSWORD mongodb.env | cut -d'=' -f2)"
echo "  URL: http://<SERVER_PUBLIC_IP>:8081"
echo ""

echo "🔗 Connection Strings"
echo "===================="
echo ""

APP_PASSWORD=$(grep MONGO_APP_PASSWORD mongodb.env | cut -d'=' -f2)

echo "Local Connection:"
echo "mongodb://appuser:${APP_PASSWORD}@localhost:27017/myapp?authSource=myapp"
echo ""

echo "Internal Network Connection:"
echo "mongodb://appuser:${APP_PASSWORD}@<SERVER_INTERNAL_IP>:27017/myapp?authSource=myapp"
echo ""

echo "SSH Tunnel Connection (after creating tunnel):"
echo "mongodb://appuser:${APP_PASSWORD}@localhost:27017/myapp?authSource=myapp"
echo ""

echo "🛡️ Security Reminders"
echo "===================="
echo "✅ Keep mongodb.env file secure (permissions: 600)"
echo "✅ Never commit mongodb.env to version control"
echo "✅ Use SSH tunnel for external access"
echo "✅ Regularly rotate passwords"
echo "✅ Monitor access logs"
echo ""

echo "📋 Quick Commands"
echo "================"
echo "View full env file: cat mongodb.env"
echo "Regenerate credentials: Manually update mongodb.env with new passwords"
echo "Test connection: docker exec mongodb mongosh --eval 'db.adminCommand(\"ping\")'"
echo "Monitor security: ./monitor-mongodb.sh"
echo "" 