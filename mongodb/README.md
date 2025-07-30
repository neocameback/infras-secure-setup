# MongoDB Secure Replica Set Setup Guide (From Scratch)

This guide will walk you through setting up a secure, single-node MongoDB replica set using Docker Compose, with best practices for authentication, network security, and monitoring.

---

## 1️⃣ Prerequisites

- **Ubuntu 20.04+** (or compatible Linux)
- **Docker** and **Docker Compose** installed
- **OpenSSH** for remote access (optional, for SSH tunneling)
- **git** (optional, for version control)

---

## 2️⃣ Clone or Prepare Your Project Directory

```bash
git clone <your-repo> mongodb-secure-setup
cd mongodb-secure-setup
# Or create a new directory and copy the provided files
```

---

## 3️⃣ Create Environment File

Create a file named `mongodb.env` with strong, unique passwords:

```env
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=<STRONG_ROOT_PASSWORD>
MONGO_DATABASE=myapp
MONGO_APP_USERNAME=appuser
MONGO_APP_PASSWORD=<STRONG_APP_PASSWORD>
MONGO_MONITOR_USERNAME=monitor
MONGO_MONITOR_PASSWORD=<STRONG_MONITOR_PASSWORD>
MONGO_BACKUP_USERNAME=backup
MONGO_BACKUP_PASSWORD=<STRONG_BACKUP_PASSWORD>
ME_USERNAME=admin
ME_PASSWORD=<STRONG_ME_PASSWORD>
MONGO_REPLICA_SET_NAME=rs0
```

**Tip:** Use a password manager to generate and store these securely.

---

## 4️⃣ Generate Replica Set Keyfile

```bash
./generate-keyfile.sh
```

---

## 5️⃣ Prepare Docker Compose and Supporting Files

- Use the provided `docker-compose.yml` as your main Compose file.
- Ensure you have `mongodb-keyfile`, `mongodb.env`, and `mongodb-init/init-mongo.js` in your project directory.
- Use the provided `docker-entrypoint.sh` for keyfile permissions.

---

## 6️⃣ Start MongoDB and Mongo Express

```bash
make up
```

- MongoDB will be available on your internal network (e.g., `172.16.16.24:27017`)
- Mongo Express will be available on port 8081 (with authentication)

---

## 7️⃣ Initialize the Replica Set (if not automatic)

If the replica set is not initialized automatically, run:

```bash
docker exec mongodb mongosh -u admin -p <ROOT_PASSWORD> --eval "rs.initiate({_id: 'rs0', members: [{_id: 0, host: 'localhost:27017'}]})"
```

---

## 8️⃣ Create Application Users (if not automatic)

If your app user is not created, run:

```bash
docker exec mongodb mongosh -u admin -p <ROOT_PASSWORD> --eval "use admin; db.createUser({user: 'appuser', pwd: '<APP_PASSWORD>', roles: [{role: 'readWrite', db: 'myapp'}]})"
```

---

## 9️⃣ Test the Setup

- **Replica Set Status:**
  ```bash
  docker exec mongodb mongosh -u admin -p <ROOT_PASSWORD> --eval "rs.status()"
  ```
- **Application User Connection:**
  ```bash
  docker exec mongodb mongosh -u appuser -p <APP_PASSWORD> --authenticationDatabase admin --eval "db.adminCommand('ping')"
  ```
- **Web UI:**
  - Visit `http://<server-ip>:8081` (login with ME_USERNAME/ME_PASSWORD)

---

## 🔗 Connection Strings

- **Internal Network:**
  ```
  mongodb://appuser:<APP_PASSWORD>@172.16.16.24:27017/myapp?authSource=admin&replicaSet=rs0
  ```
- **SSH Tunnel (external):**
  ```bash
  ssh -L 27017:172.16.16.24:27017 your_ssh_user@<server-ip>
  # Then connect to:
  mongodb://appuser:<APP_PASSWORD>@localhost:27017/myapp?authSource=admin
  ```

---

## 🔒 Security Best Practices

- Never expose MongoDB to the public internet
- Use strong, unique passwords for all users
- Keep `mongodb.env` and `mongodb-keyfile` secure and out of version control
- Regularly rotate credentials
- Monitor logs and failed login attempts
- Use SSH tunnels or VPN for remote access
- For production, use at least 3 replica set nodes

---

## 🛠️ Maintenance

- **Backup:**
  ```bash
  ./backup-mongodb.sh
  ```
- **Monitor:**
  ```bash
  ./monitor-mongodb.sh
  ```
- **Get Credentials:**
  ```bash
  ./get-credentials.sh
  ```
- **Test Replica Set:**
  ```bash
  ./test-replica-set.sh
  ```

- **Set Up Automated Monitoring**
```bash
# Add to crontab for automated monitoring
*/5 * * * * /path/to/mongodb/monitor-mongodb.sh
0 2 * * * /path/to/mongodb/backup-mongodb.sh
```
---

## 📋 Troubleshooting

- Check logs: `docker logs mongodb`
- Check replica set: `docker exec mongodb mongosh -u admin -p <ROOT_PASSWORD> --eval "rs.status()"`
- Check user list: `docker exec mongodb mongosh -u admin -p <ROOT_PASSWORD> --eval "use admin; db.getUsers()"`

---

**Setup complete! Your MongoDB is now secure, running as a replica set, and ready for production or development.** 