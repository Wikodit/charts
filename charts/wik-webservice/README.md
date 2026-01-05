# wik-webservice

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square)
![Chart](https://img.shields.io/badge/Chart-wik--webservice-blue?style=flat-square)

## Introduction

This chart simplifies the deployment of a webservice on Kubernetes.

It creates:

- **ConfigMap/Secret/SealedSecret** for environment variables
- **Secret/SealedSecret** for registry pull credentials
- **Deployment** with configurable containers, probes, and resources
- **Service** with optional metrics port and Prometheus annotations
- **Ingress** with configurable hosts and annotations
- **PVC** for persistent storage

## Installation

```bash
helm install my-app ./wik-webservice -f values.yaml
```

## Configuration

### General

| Parameter | Description | Default |
|-----------|-------------|---------|
| `general.sealedSecrets` | Use SealedSecrets instead of plain Secrets | `false` |

### Webservice

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.image` | Container image (required) | `""` |
| `webservice.imagePullPolicy` | Image pull policy | `Always` |
| `webservice.replicas` | Number of replicas | `1` |
| `webservice.port` | Container port | `80` |
| `webservice.hosts` | Ingress hostnames | `[]` |
| `webservice.command` | Override container command | `[]` |
| `webservice.args` | Override container args | `[]` |

### Service

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.service.enabled` | Create a Service | `true` |
| `webservice.service.annotations` | Service annotations | `{}` |

### Metrics

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.metrics.enabled` | Enable metrics port and Prometheus annotations | `false` |
| `webservice.metrics.port` | Metrics port | `9090` |
| `webservice.metrics.path` | Metrics path | `/metrics` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.ingress.enabled` | Create an Ingress | `true` |
| `webservice.ingress.annotations` | Ingress annotations | `{}` |

### Resources & Probes

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.resources` | CPU/Memory requests and limits | `{}` |
| `webservice.livenessProbe` | Liveness probe configuration | `{}` |
| `webservice.readinessProbe` | Readiness probe configuration | `{}` |
| `webservice.startupProbe` | Startup probe configuration | `{}` |

### Security

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create a dedicated ServiceAccount | `false` |
| `serviceAccount.name` | ServiceAccount name to use | `""` (default) |
| `serviceAccount.annotations` | ServiceAccount annotations | `{}` |
| `serviceAccount.automountServiceAccountToken` | Mount service account token (when creating SA) | `true` |
| `webservice.securityContext` | Pod-level security context | `{}` |
| `webservice.containerSecurityContext` | Container-level security context | `{}` |
| `webservice.enableServiceLinks` | Enable service links injection | `false` |
| `webservice.hostNetwork` | Access host network namespace | `false` |
| `webservice.hostPID` | Access host PID namespace | `false` |
| `webservice.hostIPC` | Access host IPC namespace | `false` |

#### ServiceAccount Configuration

By default, pods use the default ServiceAccount with `automountServiceAccountToken: false` for security. This prevents the token from being mounted in the pod unless explicitly needed.

```yaml
# Default behavior (no token mounted)
# Uses default ServiceAccount, token is not mounted

# Create dedicated ServiceAccount with token
serviceAccount:
  create: true
  automountServiceAccountToken: true

# Use existing ServiceAccount
serviceAccount:
  create: false
  name: "existing-sa"

# Create ServiceAccount with IAM role (EKS example)
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/my-role"
  automountServiceAccountToken: true
```

#### Service Links

Service links inject all cluster services as environment variables in the pod. This is disabled by default for security to reduce information leakage.

```yaml
# Default (service links disabled)
webservice:
  enableServiceLinks: false

# Enable service links if needed
webservice:
  enableServiceLinks: true
```

#### Host Protection

Host protection settings prevent pods from accessing host resources:

```yaml
# Default (all host protections disabled)
webservice:
  hostNetwork: false
  hostPID: false
  hostIPC: false

# Enable host network access (rarely needed)
webservice:
  hostNetwork: true
  # Note: This allows the pod to access the host's network interface
```

**Warning**: Enabling host access (hostNetwork, hostPID, hostIPC) significantly reduces isolation and should only be used when absolutely necessary.

### Image Security

For production deployments, follow these image security best practices:

```yaml
# Use specific image digests for immutability
webservice:
  image: "nginx@sha256:abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
  imagePullPolicy: IfNotPresent

# Use private registry with authentication
webservice:
  image: "private-registry.com/myapp:v1.2.3"
  imagePullAuth:
    registry: "private-registry.com"
    username: "deploy-user"
    password: "secure-password"

# Use SealedSecrets for encrypted credentials
general:
  sealedSecrets: true
webservice:
  imagePullAuth:
    registry: "private-registry.com"
    encrypted: "AgBy3i4OJSWK+PiTySYZZA9rO43cGDEQAx..."
```

**Image Security Recommendations:**
- Use specific image digests instead of tags for production
- Prefer `imagePullPolicy: IfNotPresent` for pinned images
- Store registry credentials in encrypted secrets
- Regularly scan images for vulnerabilities
- Use minimal base images to reduce attack surface

### Environment Variables

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.env.plaintext` | Plain environment variables (stored in ConfigMap) | `{}` |
| `webservice.env.secret` | Secret environment variables (stored in Secret/SealedSecret) | `{}` |

### Volumes

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.storage` | PVC definitions | `{}` |
| `webservice.volumes` | Volume mounts (PVC, ConfigMap, Secret) | `[]` |

### Observability

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.metrics.enabled` | Enable metrics endpoint | `false` |
| `webservice.metrics.port` | Metrics port | `9090` |
| `webservice.metrics.path` | Metrics path | `/metrics` |
| `serviceMonitor.enabled` | Enable ServiceMonitor | `false` |
| `serviceMonitor.interval` | Scrape interval | `30s` |
| `serviceMonitor.scrapeTimeout` | Scrape timeout | `10s` |
| `serviceMonitor.honorLabels` | Honor labels | `false` |
| `serviceMonitor.additionalLabels` | Additional labels | `{}` |
| `horizontalPodAutoscaler.enabled` | Enable HPA | `false` |
| `horizontalPodAutoscaler.minReplicas` | Minimum replicas | `1` |
| `horizontalPodAutoscaler.maxReplicas` | Maximum replicas | `5` |
| `horizontalPodAutoscaler.targetCPUUtilizationPercentage` | CPU target | `80` |
| `horizontalPodAutoscaler.targetMemoryUtilizationPercentage` | Memory target | `null` |
| `runtimeClassName` | Runtime class for isolation | `""` (default) |
| `podSecurityStandard.enabled` | Enable Pod Security Standards | `true` |
| `podSecurityStandard.level` | Security level | `restricted` |

#### Metrics and Monitoring

The chart supports Prometheus metrics collection through ServiceMonitor:

```yaml
# Enable metrics endpoint
webservice:
  metrics:
    enabled: true
    port: 9090
    path: /metrics

# Enable ServiceMonitor for Prometheus
serviceMonitor:
  enabled: true
  interval: 30s
  scrapeTimeout: 10s
  additionalLabels:
    release: prometheus

# Custom metric relabeling
serviceMonitor:
  enabled: true
  metricRelabelings:
    - sourceLabels: [__name__]
      regex: 'http_.*'
      action: drop
```

#### Horizontal Pod Autoscaling

The chart supports automatic scaling based on CPU and memory usage:

```yaml
# Enable HPA with CPU target
horizontalPodAutoscaler:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70

# Enable HPA with both CPU and memory targets
horizontalPodAutoscaler:
  enabled: true
  minReplicas: 1
  maxReplicas: 20
  targetCPUUtilizationPercentage: 60
  targetMemoryUtilizationPercentage: 70

# Custom scaling behavior
horizontalPodAutoscaler:
  enabled: true
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
```

#### Runtime Class

Runtime class allows using alternative container runtimes for stronger isolation:

```yaml
# Use gVisor for user-space kernel isolation
runtimeClassName: "gvisor"

# Use Kata Containers for VM-level isolation
runtimeClassName: "kata"

# Default (regular container runtime)
runtimeClassName: ""
```

**Note**: Runtime classes must be installed on the cluster before use. gVisor and Kata provide stronger isolation but may have performance overhead.

#### Pod Security Standards

Pod Security Standards (PSS) replace Pod Security Policies in Kubernetes 1.25+. They enforce security policies at the namespace level:

```yaml
# Enable restricted security level (default)
podSecurityStandard:
  enabled: true
  level: restricted

# Use baseline for less strict requirements
podSecurityStandard:
  enabled: true
  level: baseline

# Disable Pod Security Standards
podSecurityStandard:
  enabled: false
```

**Security Levels:**
- **restricted**: Most secure - non-root, read-only FS, no privileged, resource limits required
- **baseline**: Medium security - prevents obvious security issues
- **privileged**: No restrictions - not recommended for production

### Scheduling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podDisruptionBudget.enabled` | Enable PodDisruptionBudget | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1` |
| `podDisruptionBudget.maxUnavailable` | Maximum unavailable pods | `""` |
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |
| `networkPolicy.ingress` | Custom ingress rules | `[]` |
| `networkPolicy.egress` | Custom egress rules | `[]` |
| `webservice.topologySpreadConstraints` | Pod distribution constraints | `[]` |
| `webservice.nodeSelector` | Node selector | `{}` |
| `webservice.affinity` | Affinity rules | `{}` |
| `webservice.strategy` | Deployment strategy | `{}` |

#### PodDisruptionBudget

PodDisruptionBudget ensures application availability during voluntary disruptions (node maintenance, cluster upgrades):

```yaml
# Ensure at least 1 pod is always available
podDisruptionBudget:
  enabled: true
  minAvailable: 1

# Allow at most 1 pod to be unavailable (good for multi-replica deployments)
podDisruptionBudget:
  enabled: true
  maxUnavailable: 1

# Percentage-based availability
podDisruptionBudget:
  enabled: true
  minAvailable: "50%"
```

#### NetworkPolicy

NetworkPolicy restricts network traffic to/from pods. By default, it allows traffic from the ingress-nginx namespace:

```yaml
# Enable with default rules (allow ingress traffic only)
networkPolicy:
  enabled: true

# Custom ingress rules
networkPolicy:
  enabled: true
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 80

# Restrict egress to specific services
networkPolicy:
  enabled: true
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: database
      ports:
        - protocol: TCP
          port: 5432
```

#### TopologySpreadConstraints

TopologySpreadConstraints control how pods are spread across your cluster to improve high availability:

```yaml
# Spread pods across different nodes
webservice:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: DoNotSchedule
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: wik-webservice
          app.kubernetes.io/instance: release-name

# Spread pods across availability zones
webservice:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: ScheduleAnyway
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: wik-webservice
          app.kubernetes.io/instance: release-name

# Multiple constraints for better distribution
webservice:
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: kubernetes.io/hostname
      whenUnsatisfiable: DoNotSchedule
    - maxSkew: 1
      topologyKey: topology.kubernetes.io/zone
      whenUnsatisfiable: ScheduleAnyway
```

### Additional Containers

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.initContainers` | Init containers | `[]` |
| `webservice.additionalContainers` | Sidecar containers | `[]` |

## Security & Resource Defaults

This chart includes secure defaults that can be overridden as needed:

### Security Context Defaults

By default, pods run with the following security settings:

```yaml
# Pod Security Context
securityContext:
  fsGroup: 1000
  runAsNonRoot: true
  runAsUser: 1000

# Container Security Context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
  seccompProfile:
    type: RuntimeDefault

To override these defaults, set `webservice.securityContext` or `webservice.containerSecurityContext`:

```yaml
webservice:
  securityContext:
    runAsUser: 2000
    fsGroup: 2000
  containerSecurityContext:
    readOnlyRootFilesystem: false
    seccompProfile:
      type: Localhost
      localhostProfile: "profiles/custom.json"
```

### Resource Defaults

If no resources are specified, the following defaults are applied:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
    ephemeral-storage: 1Gi
  limits:
    cpu: 500m
    memory: 512Mi
    ephemeral-storage: 2Gi
```

To customize resources:

```yaml
webservice:
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 1000m
      memory: 1Gi
```

## Examples

### Basic deployment

```yaml
webservice:
  image: nginx:latest
  hosts:
    - www.example.com
  replicas: 2
  port: 80
```

### With resources and probes

```yaml
webservice:
  image: myapp:latest
  hosts:
    - api.example.com
  resources:
    requests:
      memory: "256Mi"
      cpu: "100m"
    limits:
      memory: "512Mi"
      cpu: "500m"
  livenessProbe:
    httpGet:
      path: /health
      port: 80
    initialDelaySeconds: 30
  readinessProbe:
    httpGet:
      path: /ready
      port: 80
  startupProbe:
    httpGet:
      path: /startup
      port: 80
    initialDelaySeconds: 10
    periodSeconds: 10
    failureThreshold: 30
```

### With metrics enabled

```yaml
webservice:
  image: myapp:latest
  hosts:
    - api.example.com
  metrics:
    enabled: true
    port: 9090
    path: /metrics
```

### With volumes

```yaml
webservice:
  image: myapp:latest
  hosts:
    - app.example.com

  # Define persistent storage
  storage:
    data:
      size: 10Gi
      storageClass: standard

  # Mount volumes
  volumes:
    # Mount PVC
    - name: data
      mountPath: /app/data
      storage: true

    # Mount ConfigMap
    - name: config
      mountPath: /app/config
      configMap:
        name: app-config

    # Mount Secret file
    - name: credentials
      mountPath: /app/credentials.json
      subPath: credentials.json
      secret:
        name: app-credentials
        optional: false
```

### With private registry

```yaml
webservice:
  image: registry.example.com/myapp:latest
  imagePullAuth:
    registry: registry.example.com
    username: myuser
    password: mypassword
```

### With init and sidecar containers

```yaml
webservice:
  image: myapp:latest
  hosts:
    - app.example.com

  initContainers:
    - name: init-db
      container:
        image: busybox
        command: ["sh", "-c", "echo waiting for db..."]

  additionalContainers:
    - name: log-shipper
      container:
        image: fluent/fluent-bit
        volumeMounts:
          - name: logs
            mountPath: /var/log
      env:
        plaintext:
          FLUENT_OUTPUT: stdout
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| general.sealedSecrets | bool | `false` |  |
| horizontalPodAutoscaler.annotations | object | `{}` |  |
| horizontalPodAutoscaler.behavior | object | `{}` |  |
| horizontalPodAutoscaler.customMetrics | list | `[]` |  |
| horizontalPodAutoscaler.enabled | bool | `false` |  |
| horizontalPodAutoscaler.maxReplicas | int | `5` |  |
| horizontalPodAutoscaler.minReplicas | int | `1` |  |
| horizontalPodAutoscaler.targetCPUUtilizationPercentage | int | `80` |  |
| horizontalPodAutoscaler.targetMemoryUtilizationPercentage | string | `nil` |  |
| networkPolicy.annotations | object | `{}` |  |
| networkPolicy.egress | list | `[]` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.ingress | list | `[]` |  |
| podDisruptionBudget.annotations | object | `{}` |  |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.minAvailable | int | `1` |  |
| podSecurityStandard.enabled | bool | `true` |  |
| podSecurityStandard.level | string | `"restricted"` |  |
| runtimeClassName | string | `""` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| serviceMonitor.additionalLabels | object | `{}` |  |
| serviceMonitor.annotations | object | `{}` |  |
| serviceMonitor.enabled | bool | `false` |  |
| serviceMonitor.honorLabels | bool | `false` |  |
| serviceMonitor.interval | string | `"30s"` |  |
| serviceMonitor.metricRelabelings | list | `[]` |  |
| serviceMonitor.relabelings | list | `[]` |  |
| serviceMonitor.scrapeTimeout | string | `"10s"` |  |
| webservice.additionalContainers | list | `[]` |  |
| webservice.additionalLabels | object | `{}` |  |
| webservice.additionalPaths | list | `[]` |  |
| webservice.affinity | object | `{}` |  |
| webservice.annotations | object | `{}` |  |
| webservice.containerSecurityContext | object | `{}` |  |
| webservice.dnsConfig | object | `{}` |  |
| webservice.enableServiceLinks | bool | `false` |  |
| webservice.env.plaintext | object | `{}` |  |
| webservice.env.secret | object | `{}` |  |
| webservice.hostAliases | list | `[]` |  |
| webservice.hostIPC | bool | `false` |  |
| webservice.hostNetwork | bool | `false` |  |
| webservice.hostPID | bool | `false` |  |
| webservice.hosts | list | `[]` |  |
| webservice.image | string | `"nginx:latest"` |  |
| webservice.imagePullAuth.encrypted | string | `""` |  |
| webservice.imagePullAuth.password | string | `""` |  |
| webservice.imagePullAuth.registry | string | `""` |  |
| webservice.imagePullAuth.username | string | `""` |  |
| webservice.imagePullPolicy | string | `"Always"` |  |
| webservice.ingress.annotations | object | `{}` |  |
| webservice.ingress.className | string | `""` |  |
| webservice.ingress.enabled | bool | `true` |  |
| webservice.ingress.tlsAcme | bool | `true` |  |
| webservice.initContainers | list | `[]` |  |
| webservice.livenessProbe | object | `{}` |  |
| webservice.metrics.enabled | bool | `false` |  |
| webservice.metrics.path | string | `"/metrics"` |  |
| webservice.metrics.port | int | `9090` |  |
| webservice.nodeSelector | object | `{}` |  |
| webservice.port | int | `80` |  |
| webservice.readinessProbe | object | `{}` |  |
| webservice.replicas | int | `1` |  |
| webservice.resources | object | `{}` |  |
| webservice.revisionHistoryLimit | string | `""` |  |
| webservice.securityContext | object | `{}` |  |
| webservice.service.annotations | object | `{}` |  |
| webservice.service.enabled | bool | `true` |  |
| webservice.service.port | int | `80` |  |
| webservice.startupProbe | object | `{}` |  |
| webservice.strategy | object | `{}` |  |
| webservice.terminationGracePeriodSeconds | string | `""` |  |
| webservice.topologySpreadConstraints | list | `[]` |  |
| webservice.volumes | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Wikodit |  | <https://github.com/wikodit> |
| Anthony Domingue | <anthony@wikodit.fr> |  |
| Jeremy Trufier | <jeremy@wikodit.fr> |  |
