#!/bin/bash
# ─────────────────────────────────────────────
# build.sh — builds and pushes Docker image
# Called by Jenkins. Pass IMAGE_NAME as argument.
# Usage: ./build.sh yourname/dev:latest
# ─────────────────────────────────────────────

set -e  # stop on any error

IMAGE_NAME=$1

if [ -z "$IMAGE_NAME" ]; then
  echo "ERROR: No image name provided."
  echo "Usage: ./build.sh <image-name>"
  exit 1
fi

echo "================================================"
echo " Building Docker image: $IMAGE_NAME"
echo "================================================"
docker build -t "$IMAGE_NAME" .

echo "================================================"
echo " Pushing image to Docker Hub: $IMAGE_NAME"
echo "================================================"
docker push "$IMAGE_NAME"

echo "Build and push complete: $IMAGE_NAME"
