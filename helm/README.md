# Helm Chart for Java Spring Boot Example

This directory contains the Helm chart for deploying the Java Spring Boot Example microservice to Kubernetes.

## Chart Structure

```
helm/java-spring-boot-example/
├── Chart.yaml              # Chart metadata
├── values.yaml            # Default configuration values
├── .helmignore           # Files to ignore when packaging
└── templates/
    ├── _helpers.tpl      # Template helpers
    ├── deployment.yaml   # Deployment template
    ├── service.yaml      # Service template
    └── NOTES.txt        # Post-install notes
```

## Prerequisites

- Helm 3.x installed
- kubectl configured for target cluster
- Docker image pushed to registry

## Configuration

The following table lists the configurable parameters of the chart and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.registry` | Docker registry | `t5810.webcentricds.net` |
| `image.repository` | Image repository | `java-spring-boot-example` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `service.type` | Service type | `NodePort` |
| `service.port` | Service port | `8080` |
| `service.nodePort` | NodePort value | `30080` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `250m` |
| `resources.requests.memory` | Memory request | `256Mi` |
| `javaOpts` | Java JVM options | `-Xms256m -Xmx512m` |
| `livenessProbe.initialDelaySeconds` | Liveness probe initial delay | `60` |
| `readinessProbe.initialDelaySeconds` | Readiness probe initial delay | `30` |

## Installation

### Using Default Values

```bash
# Source environment variables
source ~/gitDevelopment/github/davealexenglish/initScripts/davesMac/init_exports.sh

# Install the chart
helm install java-spring-boot-example helm/java-spring-boot-example \
  --namespace default
```

### Using Custom Values

Create a custom values file:

```yaml
# custom-values.yaml
replicaCount: 2

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

javaOpts: "-Xms512m -Xmx1024m"
```

Install with custom values:

```bash
helm install java-spring-boot-example helm/java-spring-boot-example \
  --namespace default \
  -f custom-values.yaml
```

### Installation to Different Namespace

```bash
helm install java-spring-boot-example helm/java-spring-boot-example \
  --namespace my-namespace \
  --create-namespace
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade java-spring-boot-example helm/java-spring-boot-example \
  --namespace default \
  --wait

# Upgrade with custom values file
helm upgrade java-spring-boot-example helm/java-spring-boot-example \
  --namespace default \
  -f custom-values.yaml \
  --wait
```

## Uninstalling

```bash
helm uninstall java-spring-boot-example --namespace default
```

## Verification

### Check Release Status

```bash
helm status java-spring-boot-example -n default
```

### List All Releases

```bash
helm list -n default
```

### Get Rendered Manifests

```bash
helm get manifest java-spring-boot-example -n default
```

### Get Values

```bash
# Get all values (including defaults)
helm get values java-spring-boot-example -n default --all

# Get only user-specified values
helm get values java-spring-boot-example -n default
```

## Testing After Deployment

### Get Service URL

```bash
export KUBECONFIG=$KUBE_KUBECONFIG
export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services java-spring-boot-example)
export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")

echo "Application URL: http://$NODE_IP:$NODE_PORT"
```

### Test Endpoints

```bash
# Health check
curl http://$NODE_IP:$NODE_PORT/api/health

# Hello endpoint
curl http://$NODE_IP:$NODE_PORT/api/hello

# Actuator health
curl http://$NODE_IP:$NODE_PORT/actuator/health
```

### View Logs

```bash
kubectl logs -n default -l app.kubernetes.io/name=java-spring-boot-example -f
```

### View Scheduled Polling

```bash
kubectl logs -n default -l app.kubernetes.io/name=java-spring-boot-example -f | grep "Scheduled polling"
```

## Linting

Validate the chart before installation:

```bash
helm lint helm/java-spring-boot-example
```

## Template Rendering

Preview rendered templates without installing:

```bash
helm template java-spring-boot-example helm/java-spring-boot-example \
  --namespace default
```

## Rollback

```bash
# List release history
helm history java-spring-boot-example -n default

# Rollback to previous revision
helm rollback java-spring-boot-example -n default

# Rollback to specific revision
helm rollback java-spring-boot-example 1 -n default
```

## Deployment Scripts

Convenience scripts are provided in the `scripts/` directory:

### Helm Deploy Only

```bash
./scripts/helm-deploy.sh [release-name] [namespace]
```

### Build and Helm Deploy

```bash
./scripts/build-and-helm-deploy.sh [image-tag]
```

This will:
1. Build the Docker image
2. Push to t5810 registry
3. Deploy with Helm

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl get pods -n default -l app.kubernetes.io/name=java-spring-boot-example

# Describe pod
kubectl describe pod -n default -l app.kubernetes.io/name=java-spring-boot-example

# Check events
kubectl get events -n default --sort-by='.lastTimestamp' | grep java-spring-boot
```

### Image Pull Issues

```bash
# Check image pull policy
kubectl get deployment java-spring-boot-example -n default -o yaml | grep -A 3 image

# Verify image exists in registry
docker images | grep java-spring-boot-example
```

### Service Not Accessible

```bash
# Check service endpoints
kubectl describe service java-spring-boot-example -n default

# Check network policies
kubectl get networkpolicies -n default
```

## Chart Development

### Updating the Chart

1. Modify templates or values.yaml
2. Update Chart.yaml version
3. Lint the chart: `helm lint helm/java-spring-boot-example`
4. Test locally: `helm template java-spring-boot-example helm/java-spring-boot-example`
5. Upgrade deployment: `helm upgrade java-spring-boot-example helm/java-spring-boot-example`

### Adding New Templates

Create new files in `templates/` directory. Use the naming convention:
- `deployment.yaml` - Deployments
- `service.yaml` - Services
- `configmap.yaml` - ConfigMaps
- `secret.yaml` - Secrets
- `ingress.yaml` - Ingress resources

Reference values using: `{{ .Values.parameterName }}`

Reference helper templates using: `{{ include "helper-name" . }}`

## Chart Version History

| Version | App Version | Description |
|---------|-------------|-------------|
| 0.1.0 | 1.0.0 | Initial chart release |
