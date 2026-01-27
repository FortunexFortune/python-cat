#!/bin/bash
set -e

echo "Creating 3 quotes..."
curl -s http://localhost:8000/quote | jq '.'
curl -s http://localhost:8000/quote | jq '.'
curl -s http://localhost:8000/quote | jq '.'

echo ""
echo "Verifying quote count..."
RESPONSE=$(curl -s http://localhost:8000/quotes)
echo "Response: $RESPONSE"

COUNT=$(echo "$RESPONSE" | jq '.quotes | length')
echo "Quote count: $COUNT"

if [ -z "$COUNT" ] || [ "$COUNT" != "3" ]; then
  echo "Expected 3 quotes, got '$COUNT'"
  docker compose logs
  exit 1
fi

echo "✅ Smoke test passed! Successfully created and retrieved 3 quotes."
