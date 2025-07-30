# Connecting to Redis from External Clients

Since Redis is secured and only accessible from the internal network (172.16.16.0/24), here are secure ways to connect from outside:

## 🔐 SSH Tunnel (Most Secure)

### Using Redis Client with SSH Tunnel:

1. **In Redis Client, use this connection string:**
```
dis://:<REDIS_PASSWORD>>@localhost:6379
```

2. **Or use SSH tunnel command first:**
```bash
# Create SSH tunnel (replace with your SSH credentials)
ssh -L 6379:<SERVER_INTERNAL_IP>:6379 your_ssh_user@<SERVER_PUBLIC_IP>

# Then connect to localhost:6379 in Client
redis://:<PASSWORD>@localhost:6379/myapp?authSource=admin&replicaSet=rs0
```

**⚠️ IMPORTANT**: Keep the Redis.env file secure and never commit it to version control! 