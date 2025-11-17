#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CHART_NAME="java-spring-boot-example"
RELEASE_NAME="${1:-java-spring-boot-example}"
NAMESPACE="${2:-default}"
KUBECONFIG_PATH="${KUBE_KUBECONFIG:-$HOME/.kube/config-t5810}"

echo -e "${GREEN}=== Deploying with Helm ===${NC}"
echo "Release Name: ${RELEASE_NAME}"
echo "Namespace: ${NAMESPACE}"
echo "Chart: helm/${CHART_NAME}"
echo "Kubeconfig: ${KUBECONFIG_PATH}"
echo ""

# Check if kubeconfig exists
if [ ! -f "$KUBECONFIG_PATH" ]; then
    echo -e "${RED}Error: Kubeconfig not found at ${KUBECONFIG_PATH}${NC}"
    exit 1
fi

export KUBECONFIG=$KUBECONFIG_PATH

# Check if Helm is installed
if ! command -v helm &> /dev/null; then
    echo -e "${RED}Error: Helm is not installed${NC}"
    echo "Install Helm from: https://helm.sh/docs/intro/install/"
    exit 1
fi

# Check if release already exists
if helm list -n $NAMESPACE | grep -q "^${RELEASE_NAME}"; then
    echo -e "${YELLOW}Release ${RELEASE_NAME} already exists. Upgrading...${NC}"
    ACTION="upgrade"
else
    echo -e "${GREEN}Installing new release ${RELEASE_NAME}...${NC}"
    ACTION="install"
fi
echo ""

# Lint the chart
echo -e "${GREEN}Step 1: Linting Helm chart...${NC}"
helm lint helm/${CHART_NAME}
echo ""

# Template preview (optional, commented out)
# echo -e "${GREEN}Step 2: Previewing templates...${NC}"
# helm template ${RELEASE_NAME} helm/${CHART_NAME} -n $NAMESPACE
# echo ""

# Install or upgrade the chart
echo -e "${GREEN}Step 2: ${ACTION^}ing Helm release...${NC}"
if [ "$ACTION" = "upgrade" ]; then
    helm upgrade ${RELEASE_NAME} helm/${CHART_NAME} \
        --namespace $NAMESPACE \
        --wait \
        --timeout 5m \
        --atomic
else
    helm install ${RELEASE_NAME} helm/${CHART_NAME} \
        --namespace $NAMESPACE \
        --create-namespace \
        --wait \
        --timeout 5m \
        --atomic
fi
echo ""

# Get release status
echo -e "${GREEN}Step 3: Release status...${NC}"
helm status ${RELEASE_NAME} -n $NAMESPACE
echo ""

# Display deployment info
echo -e "${GREEN}Step 4: Kubernetes resources...${NC}"
kubectl get deployments -n $NAMESPACE -l "app.kubernetes.io/instance=${RELEASE_NAME}"
echo ""
kubectl get pods -n $NAMESPACE -l "app.kubernetes.io/instance=${RELEASE_NAME}"
echo ""
kubectl get services -n $NAMESPACE -l "app.kubernetes.io/instance=${RELEASE_NAME}"
echo ""

# Get service URL
echo -e "${GREEN}=== Deployment Complete ===${NC}"
NODE_PORT=$(kubectl get service -n $NAMESPACE -l "app.kubernetes.io/instance=${RELEASE_NAME}" -o jsonpath='{.items[0].spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

if [ -n "$NODE_PORT" ] && [ -n "$NODE_IP" ]; then
    echo -e "${BLUE}Service accessible at: http://${NODE_IP}:${NODE_PORT}${NC}"
    echo ""
    echo "API Endpoints:"
    echo "  - Health: http://${NODE_IP}:${NODE_PORT}/api/health"
    echo "  - Hello:  http://${NODE_IP}:${NODE_PORT}/api/hello"
    echo "  - Actuator Health: http://${NODE_IP}:${NODE_PORT}/actuator/health"
    echo ""
    echo -e "${GREEN}Test the endpoints:${NC}"
    echo "  curl http://${NODE_IP}:${NODE_PORT}/api/health"
    echo "  curl http://${NODE_IP}:${NODE_PORT}/api/hello"
fi

echo ""
echo -e "${BLUE}View logs:${NC}"
echo "  kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/instance=${RELEASE_NAME} -f"
echo ""
echo -e "${BLUE}Uninstall:${NC}"
echo "  helm uninstall ${RELEASE_NAME} -n ${NAMESPACE}"
