// MongoDB Initialization Script
// This script sets up users, roles, and security configurations

// Wait for MongoDB to be ready
print('Starting MongoDB initialization...');

// Initialize replica set if not already done
try {
    rs.initiate({
        _id: "rs0",
        members: [
            { _id: 0, host: "localhost:27017" }
        ]
    });
    print('Replica set initialized');
} catch (error) {
    print('Replica set already initialized or error:', error.message);
}

// Wait for replica set to be ready
while (rs.status().ok !== 1) {
    print('Waiting for replica set to be ready...');
    sleep(1000);
}

// Create application database
db = db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || 'myapp');

// Create application database
db = db.getSiblingDB(process.env.MONGO_INITDB_DATABASE || 'myapp');

// Create application user with limited privileges
db.createUser({
    user: process.env.MONGO_APP_USERNAME || 'appuser',
    pwd: process.env.MONGO_APP_PASSWORD || 'AppSecurePassword123!',
    roles: [
        {
            role: "readWrite",
            db: process.env.MONGO_INITDB_DATABASE || 'myapp'
        }
    ]
});

// Create read-only user for monitoring
db.createUser({
    user: process.env.MONGO_MONITOR_USERNAME || 'monitor',
    pwd: process.env.MONGO_MONITOR_PASSWORD || 'MonitorSecurePassword123!',
    roles: [
        {
            role: "read",
            db: process.env.MONGO_INITDB_DATABASE || 'myapp'
        }
    ]
});

// Switch to admin database to create admin user with proper roles
db = db.getSiblingDB('admin');

// Create admin user with proper roles (if not root user)
if (process.env.MONGO_ADMIN_USERNAME && process.env.MONGO_ADMIN_USERNAME !== process.env.MONGO_INITDB_ROOT_USERNAME) {
    db.createUser({
        user: process.env.MONGO_ADMIN_USERNAME,
        pwd: process.env.MONGO_ADMIN_PASSWORD,
        roles: [
            { role: "userAdminAnyDatabase", db: "admin" },
            { role: "readWriteAnyDatabase", db: "admin" },
            { role: "dbAdminAnyDatabase", db: "admin" },
            { role: "clusterAdmin", db: "admin" }
        ]
    });
    print('Admin user created');
}

// Create backup user with backup privileges
db.createUser({
    user: process.env.MONGO_BACKUP_USERNAME || 'backup',
    pwd: process.env.MONGO_BACKUP_PASSWORD || 'BackupSecurePassword123!',
    roles: [
        { role: "backup", db: "admin" },
        { role: "readAnyDatabase", db: "admin" }
    ]
});

print('MongoDB initialization completed successfully'); 