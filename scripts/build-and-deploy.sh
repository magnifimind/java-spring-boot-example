#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Build, Push, and Deploy Pipeline ===${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Step 1: Build and push
echo -e "${GREEN}Starting build and push...${NC}"
bash ${SCRIPT_DIR}/build-and-push.sh "$@"
echo ""

# Step 2: Deploy
echo -e "${GREEN}Starting deployment...${NC}"
bash ${SCRIPT_DIR}/deploy.sh
echo ""

echo -e "${GREEN}=== Pipeline Complete ===${NC}"
