#!/bin/bash

set -e

openssl rand -base64 756 > mongodb-keyfile
chmod 400 mongodb-keyfile

echo "Keyfile generated successfully in ./"
echo "Files created:"
echo "  - mongodb-keyfile"
echo ""