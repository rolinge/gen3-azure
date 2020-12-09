#!/bin/bash

# Use this script to generate new JWT Secrets

# generate private and public key for fence
yearMonth="$(date +%Y-%m)"
echo "Generating fence OAUTH key pairs to stdout"
#mkdir -p fenceJwtKeys
#mkdir -p fenceJwtKeys/${timestamp}
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out /tmp/jwt_private_key.pem

openssl rsa -pubout -in /tmp/jwt_private_key.pem \
-out /tmp/jwt_public_key.pem


echo "\
Paste into the values-{instance}.yaml file

data:
  jwt_private_key:"
cat  /tmp/jwt_private_key.pem | sed 's/^/    /'
echo "  jwt_public_key:"
cat /tmp/jwt_public_key.pem | sed 's/^/    /'

rm /tmp/jwt_public_key.pem  /tmp/jwt_private_key.pem
