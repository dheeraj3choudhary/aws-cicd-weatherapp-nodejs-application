#!/bin/bash
set -e

echo "Stopping existing container if running..."
docker stop weather-app || true
docker rm weather-app || true

echo "Pruning old Docker images..."
docker image prune -f || true