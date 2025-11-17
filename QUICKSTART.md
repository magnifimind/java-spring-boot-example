# Quick Start Guide

## 1. Test Locally (Optional)

```bash
# Build and run tests
./gradlew clean build

# Run the application locally
./gradlew bootRun
```

Test locally at `http://localhost:8080`:
```bash
curl http://localhost:8080/api/health
curl http://localhost:8080/api/hello
```

## 2. Deploy to t5810 Minikube

### Prerequisites

Environment variables are automatically loaded from:
```bash
~/gitDevelopment/github/davealexenglish/initScripts/davesMac/init_exports.sh
```

### Option A: Helm Deployment (Recommended)

```bash
./scripts/build-and-helm-deploy.sh
```

This will:
1. Login to the t5810 registry
2. Build Docker image for linux/amd64
3. Push to registry
4. Deploy with Helm
5. Wait for deployment to be ready
6. Display service URL and helpful commands

### Option B: Standard Kubernetes Deployment

```bash
./scripts/build-and-deploy.sh
```

This will:
1. Login to the t5810 registry
2. Build Docker image for linux/amd64
3. Push to registry
4. Deploy to Kubernetes using kubectl
5. Wait for deployment to be ready
6. Display service URL

### Access the Service

After deployment completes, the script will show the service URL. Typically:

```bash
# Get the node IP and port
NODE_IP=$(KUBECONFIG=$HOME/.kube/config-t5810 kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Test endpoints (service is on NodePort 30080)
curl http://${NODE_IP}:30080/api/health
curl http://${NODE_IP}:30080/api/hello
curl http://${NODE_IP}:30080/actuator/health
```

## 3. Monitor the Service

```bash
# View logs
KUBECONFIG=$HOME/.kube/config-t5810 kubectl logs -f deployment/java-spring-boot-example

# Check status
KUBECONFIG=$HOME/.kube/config-t5810 kubectl get pods -l app=java-spring-boot-example

# View scheduled polling logs
KUBECONFIG=$HOME/.kube/config-t5810 kubectl logs deployment/java-spring-boot-example | grep "Scheduled polling"
```

## 4. Managing the Deployment

### Helm Commands

```bash
# Source environment variables
source ~/gitDevelopment/github/davealexenglish/initScripts/davesMac/init_exports.sh
export KUBECONFIG=$KUBE_KUBECONFIG

# Check Helm release status
helm status java-spring-boot-example -n default

# List all Helm releases
helm list -n default

# Upgrade the release
helm upgrade java-spring-boot-example helm/java-spring-boot-example --wait

# View release history
helm history java-spring-boot-example -n default

# Rollback to previous version
helm rollback java-spring-boot-example -n default
```

## 5. Cleanup

### Helm Uninstall

```bash
source ~/gitDevelopment/github/davealexenglish/initScripts/davesMac/init_exports.sh
export KUBECONFIG=$KUBE_KUBECONFIG
helm uninstall java-spring-boot-example -n default
```

### Standard Kubernetes Delete

```bash
KUBECONFIG=$HOME/.kube/config-t5810 kubectl delete -f k8s/
```

## API Endpoints

- `GET /api/health` - Returns service health status with timestamp
- `GET /api/hello` - Returns `{"message": "world"}`
- `GET /actuator/health` - Spring Boot Actuator health check

## Scheduled Task

The service includes a scheduled polling task that runs every 30 seconds and logs to the console. View it with:

```bash
KUBECONFIG=$HOME/.kube/config-t5810 kubectl logs -f deployment/java-spring-boot-example | grep "Scheduled polling"
```

## What's Included

✅ Health check endpoint
✅ Hello world endpoint
✅ OpenAPI specification with code generation
✅ Scheduled polling (every 30 seconds)
✅ Exception handling on all endpoints and scheduled methods
✅ Unit tests with AssertJ assertions
✅ Java 21, Gradle with Kotlin DSL, Gradle wrapper
✅ Dockerfile optimized for production
✅ Kubernetes deployment and service manifests
✅ Build and deploy automation scripts
✅ .gitignore configured

## Troubleshooting

If the deployment fails, check:
```bash
# Pod status
KUBECONFIG=$HOME/.kube/config-t5810 kubectl describe pod -l app=java-spring-boot-example

# Recent events
KUBECONFIG=$HOME/.kube/config-t5810 kubectl get events --sort-by='.lastTimestamp' | tail -20
```

For more details, see [README.md](README.md).
