#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Build, Push, and Helm Deploy Pipeline ===${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Step 1: Build and push
echo -e "${GREEN}Starting build and push...${NC}"
bash ${SCRIPT_DIR}/build-and-push.sh "$@"
echo ""

# Step 2: Deploy with Helm
echo -e "${GREEN}Starting Helm deployment...${NC}"
bash ${SCRIPT_DIR}/helm-deploy.sh
echo ""

echo -e "${GREEN}=== Pipeline Complete ===${NC}"
