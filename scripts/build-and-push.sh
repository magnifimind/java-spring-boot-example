#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="java-spring-boot-example"
REGISTRY_HOST="${KUBE_HOST:-t5810.webcentricds.net}"
IMAGE_TAG="${1:-latest}"
FULL_IMAGE_NAME="${REGISTRY_HOST}/${IMAGE_NAME}:${IMAGE_TAG}"

echo -e "${GREEN}=== Building and Pushing Spring Boot Example ===${NC}"
echo "Image: ${FULL_IMAGE_NAME}"
echo ""

# Check if required environment variables are set
if [ -z "$KUBE_HOST" ] || [ -z "$KUBE_USERNAME" ] || [ -z "$KUBE_PASSWORD" ]; then
    echo -e "${YELLOW}Warning: Environment variables not set. Using defaults.${NC}"
    echo "Expected: KUBE_HOST, KUBE_USERNAME, KUBE_PASSWORD"
    echo ""
fi

# Step 1: Login to registry
echo -e "${GREEN}Step 1: Logging in to registry...${NC}"
if [ -n "$KUBE_PASSWORD" ] && [ -n "$KUBE_USERNAME" ]; then
    echo "$KUBE_PASSWORD" | docker login $REGISTRY_HOST -u $KUBE_USERNAME --password-stdin
else
    echo -e "${YELLOW}Skipping login - environment variables not set${NC}"
fi
echo ""

# Step 2: Build and push image
echo -e "${GREEN}Step 2: Building and pushing image...${NC}"
docker buildx build --platform linux/amd64 \
    -t ${FULL_IMAGE_NAME} \
    --push \
    .

echo ""
echo -e "${GREEN}✓ Build and push completed successfully!${NC}"
echo "Image: ${FULL_IMAGE_NAME}"
