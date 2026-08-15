#!/bin/bash
# ============================================================
# Generate RSA key pair for Snowflake key-pair authentication
# ============================================================
set -e

KEY_DIR="$HOME/.ssh"
KEY_NAME="snowflake_dbt_rsa_key"
PRIVATE_KEY="$KEY_DIR/${KEY_NAME}.p8"
PUBLIC_KEY="$KEY_DIR/${KEY_NAME}.pub"

mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

if [ -f "$PRIVATE_KEY" ] || [ -f "$PUBLIC_KEY" ]; then
  echo "Existing Snowflake key pair found at $KEY_DIR"
  echo "Backing up current files to $KEY_DIR/${KEY_NAME}.bak.* before replacing them..."
  cp "$PRIVATE_KEY" "$KEY_DIR/${KEY_NAME}.bak.p8" 2>/dev/null || true
  cp "$PUBLIC_KEY" "$KEY_DIR/${KEY_NAME}.bak.pub" 2>/dev/null || true
  rm -f "$PRIVATE_KEY" "$PUBLIC_KEY"
fi

echo "Generating RSA private key (unencrypted .p8)..."
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -out "$PRIVATE_KEY" -nocrypt
chmod 400 "$PRIVATE_KEY"

echo "Extracting public key..."
openssl rsa -in "$PRIVATE_KEY" -pubout -out "$PUBLIC_KEY"

# Snowflake expects the public key in a specific raw format without the PEM wrapper
PUB_KEY=$(openssl pkey -pubin -in "$PUBLIC_KEY" -text -noout 2>/dev/null | sed -n '/modulus:/,$p' | tr -d ' :\n' | sed 's/^/MI/' )

if [ -z "$PUB_KEY" ]; then
  PUB_KEY=$(grep -v "PUBLIC KEY" "$PUBLIC_KEY" | tr -d '\n')
fi

echo ""
echo "✅ Keys generated:"
echo "   Private key : $PRIVATE_KEY"
echo "   Public key  : $PUBLIC_KEY"
echo ""
echo "══════════════════════════════════════════════════════"
echo "Copy the key below and run this SQL in Snowflake:"
echo "══════════════════════════════════════════════════════"
echo ""
echo "ALTER USER RRC1408 SET RSA_PUBLIC_KEY='${PUB_KEY}';"
echo ""
echo "Then verify with: DESC USER RRC1408;"
