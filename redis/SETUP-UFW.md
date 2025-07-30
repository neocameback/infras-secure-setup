# UFW Setup Guide for Secure Redis Deployment

This guide will help you configure UFW (Uncomplicated Firewall) to secure your Redis server, allowing only internal network and localhost access, and (optionally) temporary external access for testing.

---

## 1️⃣ Install UFW (if not already installed)

```bash
sudo apt update
sudo apt install ufw
```

---

## 2️⃣ Default Policy: Deny All Incoming

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

---

## 3️⃣ Allow SSH (to avoid locking yourself out)

```bash
sudo ufw allow ssh
# Or specify port if not default (22):
sudo ufw allow 22/tcp
```

---

## 4️⃣ Allow Localhost and Internal Network Access to Redis

Replace `<SERVER_INTERNAL_IP>` and `<INTERNAL_NET_CIDR>` with your actual values (e.g., `192.168.1.10` and `192.168.1.0/24`).

```bash
# Allow localhost
sudo ufw allow from 127.0.0.1 to any port 6379
sudo ufw allow from ::1 to any port 6379

# Allow internal network (example: 192.168.1.0/24)
sudo ufw allow from <INTERNAL_NET_CIDR> to any port 6379
```

---


## 6️⃣ Deny All Other Access to Redis

```bash
sudo ufw deny 6379
```

---

## 7️⃣ Enable UFW

```bash
sudo ufw enable
```

Check status:
```bash
sudo ufw status numbered
```

---

## 8️⃣ (Optional) Allow Temporary External Access for Testing

Replace `<YOUR_PUBLIC_IP>` with your current public IP address.

```bash
sudo ufw allow from <YOUR_PUBLIC_IP> to any port 6379
```

**After testing, remove the rule:**
```bash
sudo ufw delete allow from <YOUR_PUBLIC_IP> to any port 6379
```

---

## 9️⃣ Review and Maintain

- Regularly review UFW rules:
  ```bash
  sudo ufw status numbered
  ```
- Remove any rules you no longer need:
  ```bash
  sudo ufw delete <RULE_NUMBER>
  ```
- Always keep SSH access open to avoid being locked out.

---

## 🔒 Best Practices
- Only allow trusted internal networks to access Redis.
- Never allow 0.0.0.0/0 (all IPs) to access port 6379.
- Use strong authentication in Redis.
- Monitor UFW logs: `/var/log/ufw.log`

---

**Your Redis server is now protected by UFW!** 