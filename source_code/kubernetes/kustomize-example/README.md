# Kustomize Example

This directory contains a complete example of using Kustomize to manage Kubernetes configurations across different environments.

## Why Kustomize?

Kustomize solves several common problems in Kubernetes configuration management:

1. **Configuration Drift**: Different environments (dev, staging, prod) need different configurations
2. **DRY Principle**: Avoid duplicating YAML across environments
3. **Template Complexity**: No need to learn complex templating languages
4. **Native Integration**: Built into kubectl, no additional tools required

## Project Structure

```
kustomize-example/
├── base/                           # Base configuration (common to all environments)
│   ├── kustomization.yaml         # Base kustomization file
│   ├── deployment.yaml            # Base deployment
│   ├── service.yaml               # Base service
│   └── configmap.yaml             # Base configuration
└── overlays/                      # Environment-specific customizations
    ├── development/               # Development environment
    │   ├── kustomization.yaml     # Dev-specific kustomization
    │   └── patches/               # Dev-specific patches
    │       ├── configmap-patch.yaml
    │       └── resources-patch.yaml
    └── production/                # Production environment
        ├── kustomization.yaml     # Prod-specific kustomization
        ├── production-configmap.yaml
        └── production-deployment.yaml
```

## Base Configuration

The `base/` directory contains the common configuration that all environments inherit:

- **Deployment**: Basic web application deployment with nginx
- **Service**: ClusterIP service exposing the application
- **ConfigMap**: Common configuration values

## Environment Overlays

### Development Environment

The development overlay (`overlays/development/`) customizes the base for development:

- Adds `dev-` prefix to resource names
- Uses debug logging level
- Reduces resource requirements
- Enables developer mode features
- Uses development database

### Production Environment  

The production overlay (`overlays/production/`) customizes for production:

- Adds `prod-` prefix to resource names
- Uses 3 replicas for high availability
- Implements proper resource limits and requests
- Includes production secrets
- Uses production database cluster
- Enables SSL and monitoring

## Usage Examples

### Apply Base Configuration
```bash
kubectl apply -k base/
```

### Apply Development Environment
```bash
kubectl apply -k overlays/development/
```

### Apply Production Environment
```bash
kubectl apply -k overlays/production/
```

### Preview Changes (Dry Run)
```bash
# See what would be applied to development
kubectl kustomize overlays/development/

# See what would be applied to production
kubectl kustomize overlays/production/
```

### Build and Save
```bash
# Build development configuration and save to file
kubectl kustomize overlays/development/ > dev-manifests.yaml

# Build production configuration and save to file
kubectl kustomize overlays/production/ > prod-manifests.yaml
```

## Key Features Demonstrated

### 1. Inheritance
- Both environments inherit from the same base configuration
- No duplication of common elements

### 2. Customization Strategies
- **Strategic Merge Patches**: Modify specific parts of resources
- **Image Tag Override**: Different image versions per environment
- **Replica Count**: Different scaling per environment
- **Name Prefixes**: Unique resource names per environment

### 3. Configuration Management
- **ConfigMap Patches**: Environment-specific configuration values
- **Secret Generation**: Production secrets generation
- **Additional Resources**: Environment-specific additional resources

### 4. Resource Management
- **Resource Limits**: Different resource allocations per environment
- **Health Checks**: Enhanced health checks for production
- **Deployment Strategy**: Production-ready rolling update strategy

## Comparison with Other Tools

| Feature | Kustomize | Helm | Plain YAML |
|---------|-----------|------|------------|
| Learning Curve | Low | Medium | Low |
| Templates | None | Go Templates | None |
| Environment Management | Excellent | Good | Poor |
| Native Integration | Yes | No | Yes |
| Package Management | No | Yes | No |

## Best Practices Demonstrated

1. **Separation of Concerns**: Base vs overlay configuration
2. **Environment Isolation**: Clear separation between environments
3. **Security**: Secrets in production only
4. **Resource Management**: Appropriate limits per environment
5. **Naming Conventions**: Clear prefixes for environment identification
6. **Configuration as Code**: All configuration versioned and reviewable

## Next Steps

To extend this example:

1. Add staging environment overlay
2. Add monitoring configurations
3. Include ingress resources
4. Add security policies
5. Integrate with CI/CD pipelines

## Commands Reference

```bash
# Validate kustomization
kubectl kustomize overlays/development/ --dry-run

# Apply with server-side apply
kubectl apply -k overlays/production/ --server-side

# Delete resources
kubectl delete -k overlays/development/

# Watch changes
kubectl apply -k overlays/production/ && kubectl rollout status deployment/prod-webapp
```
