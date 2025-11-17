# Java Spring Boot Example Microservice

A simple Spring Boot microservice demonstrating best practices with OpenAPI code generation, health checks, scheduled tasks, and Kubernetes deployment.

## Features

- **Health Check Endpoint** (`/api/health`) - Returns service health status
- **Hello Endpoint** (`/api/hello`) - Returns "world" message
- **OpenAPI Specification** - All endpoints and models generated from OpenAPI spec
- **Scheduled Polling** - Background task that logs every 30 seconds
- **Exception Handling** - All endpoints and scheduled methods wrapped in try-catch blocks
- **Spring Boot Actuator** - Additional health monitoring at `/actuator/health`
- **Comprehensive Unit Tests** - Using AssertJ for assertions

## Technology Stack

- Java 21
- Spring Boot 3.2.1
- Gradle 8.5 with Kotlin DSL
- OpenAPI Generator 7.2.0
- AssertJ for testing
- Docker & Kubernetes

## Project Structure

```
java-spring-boot-example/
├── src/
│   ├── main/
│   │   ├── java/com/example/springbootexample/
│   │   │   ├── Application.java                    # Main application
│   │   │   ├── controller/
│   │   │   │   ├── HealthController.java          # Health check implementation
│   │   │   │   └── HelloController.java           # Hello endpoint implementation
│   │   │   └── service/
│   │   │       └── ScheduledPollingService.java   # Scheduled polling task
│   │   └── resources/
│   │       ├── openapi/
│   │       │   └── api-spec.yaml                  # OpenAPI specification
│   │       └── application.properties              # Application configuration
│   └── test/
│       └── java/com/example/springbootexample/
│           ├── controller/
│           │   ├── HealthControllerTest.java
│           │   └── HelloControllerTest.java
│           └── service/
│               └── ScheduledPollingServiceTest.java
├── k8s/
│   ├── deployment.yaml                             # Kubernetes deployment
│   └── service.yaml                                # Kubernetes service
├── scripts/
│   ├── build-and-push.sh                          # Build and push Docker image
│   ├── deploy.sh                                   # Deploy to Kubernetes
│   └── build-and-deploy.sh                        # Complete pipeline
├── Dockerfile                                      # Multi-stage Docker build
├── build.gradle.kts                               # Gradle build configuration
└── .gitignore                                     # Git ignore rules

```

## Prerequisites

- Java 21
- Docker
- Access to t5810.webcentricds.net registry
- Kubectl configured for t5810 minikube cluster

### Environment Variables

Set these environment variables (typically via `init_exports.sh`):

```bash
export KUBE_HOST=t5810.webcentricds.net
export KUBE_USERNAME=denglish
export KUBE_PASSWORD=your_password
export KUBE_KUBECONFIG=~/.kube/config-t5810
```

## Building Locally

### Generate OpenAPI Code and Build

```bash
./gradlew clean build
```

This will:
1. Generate API interfaces and models from `src/main/resources/openapi/api-spec.yaml`
2. Compile the application
3. Check code formatting with Spotless
4. Run all unit tests
5. Create executable JAR in `build/libs/`

### Code Formatting with Spotless

The project uses [Spotless](https://github.com/diffplug/spotless) with Google Java Format for consistent code formatting.

#### Check Formatting

```bash
./gradlew spotlessCheck
```

#### Apply Formatting

```bash
./gradlew spotlessApply
```

#### Spotless Configuration

- **Google Java Format** - Enforces Google's Java style guide
- **No Wildcard Imports** - Wildcard imports (e.g., `import java.util.*`) are not allowed
- **Import Ordering** - Imports are automatically sorted
- **Remove Unused Imports** - Unused imports are removed
- **Trailing Whitespace** - Removed automatically
- **End with Newline** - All files end with a newline

Note: Generated code in `build/generated/**` is excluded from formatting checks.

### Run Locally

```bash
./gradlew bootRun
```

The application will start on `http://localhost:8080`

### Test Endpoints Locally

```bash
# Health check
curl http://localhost:8080/api/health

# Hello endpoint
curl http://localhost:8080/api/hello

# Actuator health
curl http://localhost:8080/actuator/health
```

## Running Tests

```bash
# Run all tests
./gradlew test

# Run with detailed output
./gradlew test --info

# Run specific test class
./gradlew test --tests HealthControllerTest
```

## Docker Build and Push

### Option 1: Using the Script

```bash
./scripts/build-and-push.sh [tag]
```

This will:
1. Login to t5810.webcentricds.net registry
2. Build Docker image for linux/amd64 platform
3. Push to registry

### Option 2: Manual Docker Build

```bash
# Login to registry
echo "$KUBE_PASSWORD" | docker login $KUBE_HOST -u $KUBE_USERNAME --password-stdin

# Build and push
docker buildx build --platform linux/amd64 \
  -t t5810.webcentricds.net/java-spring-boot-example:latest \
  --push \
  .
```

## Kubernetes Deployment

### Helm Deployment (Recommended)

The application includes a Helm chart for production-ready deployments.

#### Quick Helm Deploy

```bash
# Build, push, and deploy with Helm
./scripts/build-and-helm-deploy.sh
```

#### Helm Deploy Only

If image is already pushed:

```bash
./scripts/helm-deploy.sh [release-name] [namespace]
```

#### Manual Helm Deployment

```bash
# Source environment variables
source ~/gitDevelopment/github/davealexenglish/initScripts/davesMac/init_exports.sh

# Install with Helm
helm install java-spring-boot-example helm/java-spring-boot-example \
  --namespace default \
  --wait
```

See [Helm Chart Documentation](helm/README.md) for detailed configuration options.

### Standard Kubernetes Deployment

#### Option 1: Complete Pipeline

Build, push, and deploy in one command:

```bash
./scripts/build-and-deploy.sh
```

#### Option 2: Deploy Only

If image is already pushed:

```bash
./scripts/deploy.sh [namespace]
```

#### Option 3: Manual Deployment

```bash
# Set kubeconfig
export KUBECONFIG=$HOME/.kube/config-t5810

# Apply manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Check status
kubectl get pods -l app=java-spring-boot-example
kubectl get services java-spring-boot-example
```

## Accessing the Service in Kubernetes

After deployment, the service is exposed via NodePort 30080:

```bash
# Get node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Test endpoints
curl http://${NODE_IP}:30080/api/health
curl http://${NODE_IP}:30080/api/hello
curl http://${NODE_IP}:30080/actuator/health
```

## OpenAPI Code Generation

The project uses the OpenAPI Generator Gradle plugin to generate:

- **API Interfaces**: `com.example.springbootexample.api.*`
- **Model Classes**: `com.example.springbootexample.model.*`

Generated code location: `build/generated/src/main/java/`

To regenerate code after modifying `api-spec.yaml`:

```bash
./gradlew openApiGenerate
```

## Scheduled Polling

The `ScheduledPollingService` runs every 30 seconds and logs to the console. Configure the interval in the service class:

```java
@Scheduled(fixedRate = 30000, initialDelay = 10000)
```

## Configuration

Edit `src/main/resources/application.properties` to configure:

- Server port
- Logging levels
- Actuator endpoints
- Jackson serialization

## Monitoring and Logs

### View Logs in Kubernetes

```bash
# Follow logs
kubectl logs -f deployment/java-spring-boot-example

# View recent logs
kubectl logs deployment/java-spring-boot-example --tail=100

# View scheduled polling logs
kubectl logs deployment/java-spring-boot-example | grep "Scheduled polling"
```

### Health Checks

The application includes multiple health check mechanisms:

1. **Application Health**: `/api/health` - Custom health endpoint
2. **Actuator Health**: `/actuator/health` - Spring Boot Actuator
3. **Kubernetes Probes**: Liveness and readiness probes configured

## Troubleshooting

### Build Issues

```bash
# Clean and rebuild
./gradlew clean build --refresh-dependencies

# View generated code
ls -la build/generated/src/main/java/com/example/springbootexample/
```

### Docker Issues

```bash
# Check if image exists
docker images | grep java-spring-boot-example

# Test image locally
docker run -p 8080:8080 t5810.webcentricds.net/java-spring-boot-example:latest
```

### Kubernetes Issues

```bash
# Check pod status
kubectl describe pod -l app=java-spring-boot-example

# Check deployment events
kubectl describe deployment java-spring-boot-example

# Force pod restart
kubectl rollout restart deployment/java-spring-boot-example

# Check image pull status
kubectl get events --sort-by='.lastTimestamp' | grep java-spring-boot-example
```

### Common Errors

1. **ImagePullBackOff**: Ensure image was pushed successfully and registry is accessible
2. **CrashLoopBackOff**: Check pod logs for startup errors
3. **Build failures**: Ensure Java 21 is installed and JAVA_HOME is set

## Development

### Adding New Endpoints

1. Update `src/main/resources/openapi/api-spec.yaml`
2. Run `./gradlew openApiGenerate`
3. Implement the generated interface in a new controller
4. Add unit tests
5. Build and test

### Modifying the Scheduled Task

Edit `src/main/java/com/example/springbootexample/service/ScheduledPollingService.java`

## Testing in Kubernetes

After deployment, verify all features:

```bash
# Get service URL
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
SERVICE_URL="http://${NODE_IP}:30080"

# Test health endpoint
curl -s ${SERVICE_URL}/api/health | jq

# Test hello endpoint
curl -s ${SERVICE_URL}/api/hello | jq

# View scheduled polling logs
kubectl logs -f deployment/java-spring-boot-example | grep "Scheduled polling"
```

## License

This is an example project for demonstration purposes.
