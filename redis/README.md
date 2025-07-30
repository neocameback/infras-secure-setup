# Secure Redis Container Setup

This setup provides a secure Redis instance running in a Docker container with password authentication and disabled dangerous commands.

## Configuration

- **Password**: Loaded from `redis.env` file (default: `<REDIS_PASSWORD>`)
- **Port**: 6379 (configurable in `redis.env`)
- **Image**: Redis 7.2 Alpine (lightweight)

## Security Features

- ✅ Password authentication required
- ✅ Dangerous commands disabled (FLUSHALL, FLUSHDB, CONFIG, etc.)
- ✅ Protected mode enabled
- ✅ Memory limits configured
- ✅ Health checks enabled

## Quick Start

1. **Start the Redis container:**
   ```bash
   docker-compose up -d
   ```

2. **Check if Redis is running:**
   ```bash
   docker-compose ps
   ```

3. **Connect to Redis using redis-cli:**
   ```bash
   redis-cli -a <REDIS_PASSWORD>
   ```

4. **Or connect from within the container:**
   ```bash
   docker exec -it secure-redis redis-cli -a <REDIS_PASSWORD>
   ```

5. **Or use the password from env file:**
   ```bash
   source redis.env && redis-cli -a $REDIS_PASSWORD
   ```

## Connection Examples

### Using redis-cli
```bash
redis-cli -a <REDIS_PASSWORD>
```

### Using Python (redis-py)
```python
import redis
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv('redis.env')

r = redis.Redis(
    host='localhost',
    port=int(os.getenv('REDIS_PORT', 6379)),
    password=os.getenv('REDIS_PASSWORD'),
    decode_responses=True
)

# Test connection
print(r.ping())  # Should return True
```

### Using Node.js (ioredis)
```javascript
const Redis = require('ioredis');
require('dotenv').config({ path: './redis.env' });

const redis = new Redis({
  host: 'localhost',
  port: process.env.REDIS_PORT || 6379,
  password: process.env.REDIS_PASSWORD
});

redis.ping().then(result => {
  console.log('Connected:', result);
});
```

## Management Commands

- **View logs:**
  ```bash
  docker-compose logs redis
  ```

- **Stop Redis:**
  ```bash
  docker-compose down
  ```

- **Restart Redis:**
  ```bash
  docker-compose restart redis
  ```

- **Remove everything (including data):**
  ```bash
  docker-compose down -v
  ```

## Security Notes

⚠️ **Important Security Considerations:**

1. **Change the default password** in `redis.env` for production use
2. **Restrict network access** - only expose Redis to trusted applications
3. **Use Docker networks** to isolate Redis from other containers
4. **Consider using TLS** for additional encryption in production
5. **Regularly update** the Redis image for security patches

## Production Recommendations

For production environments, consider:

- ✅ Using environment variables for passwords (already implemented)
- Implementing TLS encryption
- Setting up Redis Sentinel for high availability
- Configuring proper backup strategies
- Monitoring Redis performance and security

## Troubleshooting

If you can't connect to Redis:

1. Check if the container is running: `docker-compose ps`
2. Verify the password is correct
3. Check logs: `docker-compose logs redis`
4. Ensure port 6379 is not blocked by firewall 