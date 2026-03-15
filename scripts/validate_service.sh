#!/bin/bash
set -e

echo "Validating weather-app is running..."

sleep 5

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health)

if [ "$STATUS" -eq 200 ]; then
  echo "Health check passed — app is running"
  exit 0
else
  echo "Health check failed — status code: $STATUS"
  exit 1
fi