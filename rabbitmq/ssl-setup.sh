#!/bin/bash

# RabbitMQ SSL Certificate Setup Script

set -e

echo "🔐 Setting up SSL certificates for RabbitMQ..."

# Create SSL directory
mkdir -p config/ssl
cd config/ssl

# Generate CA private key
echo "📝 Generating CA private key..."
openssl genrsa -out ca-key.pem 2048

# Generate CA certificate
echo "📝 Generating CA certificate..."
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem -subj "/C=US/ST=State/L=City/O=Organization/CN=RabbitMQ-CA"

# Generate server private key
echo "📝 Generating server private key..."
openssl genrsa -out server-key.pem 2048

# Generate server certificate signing request
echo "📝 Generating server certificate signing request..."
openssl req -subj "/CN=rabbitmq" -sha256 -new -key server-key.pem -out server.csr

# Create server certificate config
cat > server-extfile.cnf << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = rabbitmq
DNS.2 = localhost
IP.1 = 127.0.0.1
EOF

# Generate server certificate
echo "📝 Generating server certificate..."
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile server-extfile.cnf

# Generate client private key
echo "📝 Generating client private key..."
openssl genrsa -out client-key.pem 2048

# Generate client certificate signing request
echo "📝 Generating client certificate signing request..."
openssl req -subj "/CN=client" -new -key client-key.pem -out client.csr

# Create client certificate config
cat > client-extfile.cnf << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = clientAuth
EOF

# Generate client certificate
echo "📝 Generating client certificate..."
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -extfile client-extfile.cnf

# Set proper permissions
chmod 600 *.pem
chmod 644 *.pem

# Clean up temporary files
rm -f server.csr client.csr server-extfile.cnf client-extfile.cnf

echo "✅ SSL certificates generated successfully!"
echo ""
echo "📁 Certificates location: config/ssl/"
echo "🔑 Files created:"
echo "   - ca.pem (CA certificate)"
echo "   - server-cert.pem (Server certificate)"
echo "   - server-key.pem (Server private key)"
echo "   - client-cert.pem (Client certificate)"
echo "   - client-key.pem (Client private key)"
echo ""
echo "⚠️  Remember to update rabbitmq.conf to enable SSL!"
echo "   Uncomment the SSL configuration lines in config/rabbitmq.conf" 