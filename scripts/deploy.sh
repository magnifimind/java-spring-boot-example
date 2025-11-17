#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KUBECONFIG_PATH="${KUBE_KUBECONFIG:-$HOME/.kube/config-t5810}"
NAMESPACE="${1:-default}"

echo -e "${GREEN}=== Deploying Spring Boot Example to Kubernetes ===${NC}"
echo "Namespace: ${NAMESPACE}"
echo "Kubeconfig: ${KUBECONFIG_PATH}"
echo ""

# Check if kubeconfig exists
if [ ! -f "$KUBECONFIG_PATH" ]; then
    echo -e "${RED}Error: Kubeconfig not found at ${KUBECONFIG_PATH}${NC}"
    exit 1
fi

export KUBECONFIG=$KUBECONFIG_PATH

# Step 1: Apply Kubernetes manifests
echo -e "${GREEN}Step 1: Applying Kubernetes manifests...${NC}"
kubectl apply -f k8s/deployment.yaml -n $NAMESPACE
kubectl apply -f k8s/service.yaml -n $NAMESPACE
echo ""

# Step 2: Wait for deployment
echo -e "${GREEN}Step 2: Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s \
    deployment/java-spring-boot-example -n $NAMESPACE || {
    echo -e "${RED}Deployment failed or timed out${NC}"
    echo -e "${YELLOW}Checking pod status:${NC}"
    kubectl get pods -n $NAMESPACE -l app=java-spring-boot-example
    echo ""
    echo -e "${YELLOW}Pod logs:${NC}"
    kubectl logs -n $NAMESPACE -l app=java-spring-boot-example --tail=50
    exit 1
}
echo ""

# Step 3: Display status
echo -e "${GREEN}Step 3: Deployment status...${NC}"
kubectl get deployments -n $NAMESPACE -l app=java-spring-boot-example
echo ""
kubectl get pods -n $NAMESPACE -l app=java-spring-boot-example
echo ""
kubectl get services -n $NAMESPACE -l app=java-spring-boot-example
echo ""

# Step 4: Get service URL
echo -e "${GREEN}=== Deployment Complete ===${NC}"
NODE_PORT=$(kubectl get service java-spring-boot-example -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo -e "${BLUE}Service accessible at: http://${NODE_IP}:${NODE_PORT}${NC}"
echo ""
echo "API Endpoints:"
echo "  - Health: http://${NODE_IP}:${NODE_PORT}/api/health"
echo "  - Hello:  http://${NODE_IP}:${NODE_PORT}/api/hello"
echo "  - Actuator Health: http://${NODE_IP}:${NODE_PORT}/actuator/health"
