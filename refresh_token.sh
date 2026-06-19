#!/bin/bash
# ============================================================
# SafetyWatch - Auto Token Refresh Script
# Generates a fresh Sanctum token and updates docker-compose.yml
# Usage: bash refresh_token.sh
# ============================================================

set -e

BACKEND_URL="https://3.124.186.191.nip.io"
EMAIL="ahmed.3rfa11@gmail.com"
PASSWORD="Trashbag#69#69"
COMPOSE_FILE="$(dirname "$0")/ai/docker-compose.yml"

echo "🔄 Requesting fresh token from $BACKEND_URL..."

RESPONSE=$(curl -s -X POST "$BACKEND_URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")

TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['token'])" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  echo "❌ Failed to get token. Server response:"
  echo "$RESPONSE"
  exit 1
fi

echo "✅ Got new token: ${TOKEN:0:20}..."

# Update docker-compose.yml with the new token
sed -i.bak "s|LARAVEL_API_TOKEN:-[^}]*}|LARAVEL_API_TOKEN:-$TOKEN}|g" "$COMPOSE_FILE"

echo "✅ docker-compose.yml updated with fresh token."
echo ""
echo "👉 Now restart your containers:"
echo "   cd ai && docker-compose up --build"
