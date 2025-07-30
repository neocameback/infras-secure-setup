#!/bin/bash

# Test MongoDB Replica Set Configuration
echo "=== Testing MongoDB Replica Set ==="
echo ""

# Check if containers are running
echo "1. Checking container status..."
docker ps | grep mongodb
echo ""

# Check replica set status
echo "2. Checking replica set status..."
docker exec mongodb mongosh -u admin -p <MONGO_ROOT_PASSWORD> --eval "rs.status().ok" --quiet
echo ""

# Check replica set configuration
echo "3. Checking replica set configuration..."
docker exec mongodb mongosh -u admin -p <MONGO_ROOT_PASSWORD> --eval "rs.conf()" --quiet
echo ""

# Test basic operations
echo "4. Testing basic operations..."
docker exec mongodb mongosh -u admin -p <MONGO_ROOT_PASSWORD> --eval "
use myapp;
db.test.insertOne({test: 'replica set working', timestamp: new Date()});
db.test.find().pretty();
db.test.deleteOne({test: 'replica set working'});
print('Basic operations test completed successfully');
"
echo ""

# Check connection string format
echo "5. Connection string for applications:"
echo "mongodb://appuser:<PASSWORD>@<SERVER_INTERNAL_IP>:27017/myapp?authSource=admin&replicaSet=rs0"
echo ""

echo "=== Replica Set Test Complete ===" 