#!/bin/bash
# ============================================================
# Generate RSA key pair for Snowflake key-pair authentication
# ============================================================
set -e

KEY_DIR="$HOME/.ssh"
KEY_NAME="snowflake_dbt_rsa_key"

mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

echo "Generating RSA private key (unencrypted .p8)..."
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out "$KEY_DIR/${KEY_NAME}.p8" -nocrypt
chmod 400 "$KEY_DIR/${KEY_NAME}.p8"

echo "Extracting public key..."
openssl rsa -in "$KEY_DIR/${KEY_NAME}.p8" -pubout -out "$KEY_DIR/${KEY_NAME}.pub"

echo ""
echo "✅ Keys generated:"
echo "   Private key : $KEY_DIR/${KEY_NAME}.p8"
echo "   Public key  : $KEY_DIR/${KEY_NAME}.pub"
echo ""
echo "══════════════════════════════════════════════════════"
echo "Copy the key below and run this SQL in Snowflake:"
echo "══════════════════════════════════════════════════════"

# Strip header/footer lines — Snowflake wants raw base64 only
PUB_KEY=$(grep -v "PUBLIC KEY" "$KEY_DIR/${KEY_NAME}.pub" | tr -d '\n')
echo ""
echo "ALTER USER RRC1408 SET RSA_PUBLIC_KEY='${PUB_KEY}';"
echo ""
echo "Then verify with:  DESC USER RRC1408;"
