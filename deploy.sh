#!/bin/bash
# ─────────────────────────────────────────────
# deploy.sh — pulls image and restarts container
# Called by Jenkins via SSH on the target EC2.
# Usage: ./deploy.sh yourname/dev:latest
# ─────────────────────────────────────────────

set -e

IMAGE_NAME=$1

if [ -z "$IMAGE_NAME" ]; then
  echo "ERROR: No image name provided."
  echo "Usage: ./deploy.sh <image-name>"
  exit 1
fi

echo "================================================"
echo " Deploying: $IMAGE_NAME"
echo "================================================"

# Export for docker-compose to pick up
export DOCKER_IMAGE="$IMAGE_NAME"

echo "Pulling latest image..."
docker pull "$IMAGE_NAME"

echo "Stopping existing container (if any)..."
docker compose down || true

echo "Starting new container..."
docker compose up -d

echo "Running containers:"
docker ps

echo "Deploy complete: $IMAGE_NAME"
