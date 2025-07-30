# RabbitMQ Connection Guide

This guide shows you how to connect to and test your secured RabbitMQ instance.

## 🔗 **Connection Information**

### **Basic Details**
- **Host:** `localhost` (or `172.16.16.24`)
- **AMQP Port:** `5672`
- **Management Port:** `15672`
- **Username:** `admin`
- **Password:** `<RABBITMQ_PASSWORD>`
- **Virtual Host:** `/`

## 🌐 **1. Web Management UI (Recommended)**

### **Access URL**
```
http://localhost:15672
```

### **Login Credentials**
- **Username:** `admin`
- **Password:** `<RABBITMQ_PASSWORD>`

### **Features Available**
- Queue monitoring and management
- Exchange management
- Connection monitoring
- User management
- Performance metrics
- Message tracing

## 🔧 **2. Command Line Tools**

### **Container Access**
```bash
# Access RabbitMQ container
docker-compose exec rabbitmq bash

# List users
rabbitmqctl list_users

# Check status
rabbitmqctl status

# List queues
rabbitmqctl list_queues

# List exchanges
rabbitmqctl list_exchanges

# List connections
rabbitmqctl list_connections
```

### **Direct Commands**
```bash
# Check RabbitMQ status
docker-compose exec rabbitmq rabbitmqctl status

# List all users
docker-compose exec rabbitmq rabbitmqctl list_users

# List all queues
docker-compose exec rabbitmq rabbitmqctl list_queues

# List all exchanges
docker-compose exec rabbitmq rabbitmqctl list_exchanges
```

## 📡 **3. HTTP API Testing**

### **Basic API Test**
```bash
# Get overview information
curl -u admin:<RABBITMQ_PASSWORD> \
  http://localhost:15672/api/overview

# List all queues
curl -u admin:<RABBITMQ_PASSWORD> \
  http://localhost:15672/api/queues

# List all exchanges
curl -u admin:<RABBITMQ_PASSWORD> \
  http://localhost:15672/api/exchanges

# List all connections
curl -u admin:<RABBITMQ_PASSWORD> \
  http://localhost:15672/api/connections
```

### **Health Check**
```bash
# Check if RabbitMQ is healthy
curl -u admin:<RABBITMQ_PASSWORD> \
  http://localhost:15672/api/healthchecks/node
```


## 🔌 **5. AMQP Client Testing**

### **Using amqp-tools (if available)**
```bash
# Send a message
amqp-publish --url="amqp://admin:<RABBITMQ_PASSWORD>@localhost:5672/" \
  --exchange="" --routing-key="test_queue" \
  --body="Hello from AMQP tools!"

# Receive messages
amqp-consume --url="amqp://admin:<RABBITMQ_PASSWORD>@localhost:5672/" \
  --queue="test_queue"
```

## 📊 **6. Monitoring and Metrics**

### **Prometheus Metrics**
```bash
# Get Prometheus metrics
curl http://localhost:15692/metrics
```

### **Management API Metrics**
```bash
# Get detailed metrics
curl -u admin:<RABBITMQ_PASSWORD> \
  http://localhost:15672/api/metrics
```

## 🛠️ **7. Troubleshooting**

### **Check Container Status**
```bash
# Check if container is running
docker-compose ps

# Check container logs
docker-compose logs rabbitmq

# Check container health
docker-compose exec rabbitmq rabbitmq-diagnostics ping
```

### **Common Issues**

1. **Connection Refused**
   ```bash
   # Check if ports are exposed
   netstat -tulpn | grep :5672
   netstat -tulpn | grep :15672
   ```

2. **Authentication Failed**
   ```bash
   # Verify user exists
   docker-compose exec rabbitmq rabbitmqctl list_users
   
   # Reset user password if needed
   docker-compose exec rabbitmq rabbitmqctl change_password admin new_password
   ```

3. **Container Not Starting**
   ```bash
   # Check logs
   docker-compose logs rabbitmq
   
   # Restart container
   docker-compose restart rabbitmq
   ```

## 🔒 **8. Security Notes**

- **Never expose** RabbitMQ ports to the internet without proper firewall rules
- **Use strong passwords** in production
- **Enable SSL/TLS** for production deployments
- **Regularly update** RabbitMQ and dependencies
- **Monitor access logs** for suspicious activity

## 📝 **9. Quick Commands Reference**

```bash
# Start RabbitMQ
docker-compose up -d

# Stop RabbitMQ
docker-compose down

# View logs
docker-compose logs -f rabbitmq

# Access container shell
docker-compose exec rabbitmq bash

# Check status
docker-compose exec rabbitmq rabbitmqctl status

# List users
docker-compose exec rabbitmq rabbitmqctl list_users

# Test HTTP API
curl -u admin:<RABBITMQ_PASSWORD> http://localhost:15672/api/overview
```

## ✅ **10. Connection Test Checklist**

- [ ] Container is running (`docker-compose ps`)
- [ ] Management UI accessible (`http://localhost:15672`)
- [ ] Admin user exists (`rabbitmqctl list_users`)
- [ ] HTTP API responds (`curl` test)
- [ ] AMQP port accessible (`telnet localhost 5672`)

Your RabbitMQ instance is now ready for use! 🎉 