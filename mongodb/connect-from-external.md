# Connecting to MongoDB from External Clients

Since MongoDB is secured and only accessible from the internal network (172.16.16.0/24), here are secure ways to connect from outside:

## 🔐 Option 1: SSH Tunnel (Most Secure)

### Using MongoDB Compass with SSH Tunnel:

1. **In MongoDB Compass, use this connection string:**
```
mongodb://appuser:<PASSWORD>@localhost:27017/myapp?authSource=myapp&sshTunnel=true&sshHostname=<SERVER_PUBLIC_IP>&sshUsername=your_ssh_user&sshPassword=your_ssh_password
```

2. **Or use SSH tunnel command first:**
```bash
# Create SSH tunnel (replace with your SSH credentials)
ssh -L 27017:<SERVER_INTERNAL_IP>:27017 your_ssh_user@<SERVER_PUBLIC_IP>

# Then connect to localhost:27017 in Compass
mongodb://appuser:<PASSWORD>@localhost:27017/myapp?authSource=admin&replicaSet=rs0
```

### Using mongosh with SSH tunnel:
```bash
# Create tunnel
ssh -L 27017:<SERVER_INTERNAL_IP>:27017 your_ssh_user@<SERVER_PUBLIC_IP>

# In another terminal, connect to MongoDB
mongosh "mongodb://appuser:<PASSWORD>@localhost:27017/myapp?authSource=admin&replicaSet=rs0"
```

## 🌐 Option 2: VPN Connection

If you have VPN access to the internal network:

1. **Connect to your VPN**
2. **Use the internal network connection:**
```
mongodb://appuser:<PASSWORD>@<SERVER_INTERNAL_IP>:27017/myapp?authSource=admin&replicaSet=rs0
```

## 🔧 Option 3: Reverse Proxy (Advanced)

Create a secure reverse proxy with authentication:

### Using nginx with basic auth:
```nginx
# /etc/nginx/sites-available/mongodb-proxy
server {
    listen 27018 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        auth_basic "MongoDB Access";
        auth_basic_user_file /etc/nginx/.htpasswd;
        
        proxy_pass http://<SERVER_INTERNAL_IP>:27017;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🚀 Option 4: Temporary Access (Development Only)

**⚠️ WARNING: Only for development/testing - NOT recommended for production**

If you need temporary external access for development:

```bash
# Temporarily allow your IP (replace with your actual IP)
ufw allow from YOUR_IP_ADDRESS to any port 27017

# Use connection string:
mongodb://appuser:<PASSWORD>@<SERVER_PUBLIC_IP>:27017/myapp?authSource=admin&replicaSet=rs0

# REMEMBER TO REMOVE ACCESS AFTER USE:
ufw delete allow from YOUR_IP_ADDRESS to any port 27017
```

## 📱 Option 5: Web-Based MongoDB Client

Deploy a web-based MongoDB client on your server:

### Using mongo-express (already running):
- Access: http://<SERVER_PUBLIC_IP>:8081
- Username: `admin`
- Password: `<ME_PASSWORD>` (from mongodb.env)

### Or deploy MongoDB Compass Web:
```bash
# Install MongoDB Compass Web
docker run -d \
  --name mongodb-compass-web \
  -p 8082:8080 \
  -e MONGODB_URL="mongodb://appuser:<PASSWORD>@<SERVER_INTERNAL_IP>:27017/myapp?authSource=myapp" \
  mongodb/compass-web
```

## 🔍 Connection Testing

### Test SSH tunnel:
```bash
# Test if tunnel works
ssh -L 27017:<SERVER_INTERNAL_IP>:27017 your_ssh_user@<SERVER_PUBLIC_IP> -N &
telnet localhost 27017
```

### Test direct connection (if using Option 4):
```bash
# From your external machine
telnet <SERVER_PUBLIC_IP> 27017
```

## 🛡️ Security Recommendations

1. **Always use SSH tunnel** for production access
2. **Never expose MongoDB directly** to the internet
3. **Use strong SSH keys** instead of passwords
4. **Limit access time** for temporary connections
5. **Monitor access logs** regularly

## 📋 Quick Reference

### For MongoDB Compass:
```
Connection String: mongodb://appuser:<PASSWORD>@localhost:27017/myapp?authSource=admin&replicaSet=rs0
SSH Tunnel: <SERVER_PUBLIC_IP>:22
SSH Username: your_ssh_user
```

### For mongosh:
```bash
ssh -L 27017:<SERVER_INTERNAL_IP>:27017 your_ssh_user@<SERVER_PUBLIC_IP>
mongosh "mongodb://appuser:<PASSWORD>@localhost:27017/myapp?authSource=admin&replicaSet=rs0"
```

### For web access:
```
URL: http://<SERVER_PUBLIC_IP>:8081
Username: admin
Password: <ME_PASSWORD> (from mongodb.env)
```

## 🔐 Getting Credentials

To get the actual passwords, run:
```bash
cat mongodb.env
```

**⚠️ IMPORTANT**: Keep the mongodb.env file secure and never commit it to version control! 