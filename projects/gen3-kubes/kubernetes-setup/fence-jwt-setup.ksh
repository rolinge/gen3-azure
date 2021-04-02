#!/bin/bash
# Script to jwt keys for fence

# make directories for temporary credentials
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# generate private and public key for fence
yearMonth="$(date +%Y-%m)"
if [[ ! -d ./fenceJwtKeys ]] || ! (ls ./fenceJwtKeys | grep "$yearMonth" > /dev/null 2>&1); then
    echo "Generating fence OAUTH key pairs under fenceJwtKeys"
    mkdir -p fenceJwtKeys
    mkdir -p fenceJwtKeys/${timestamp}

    openssl genpkey -algorithm RSA -out fenceJwtKeys/${timestamp}/jwt_private_key.pem \
        -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in fenceJwtKeys/${timestamp}/jwt_private_key.pem \
        -out fenceJwtKeys/${timestamp}/jwt_public_key.pem
    chmod -R a+rx fenceJwtKeys
fi
