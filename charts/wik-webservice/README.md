# wik-webservice

![Version: 0.7.6](https://img.shields.io/badge/Version-0.7.6-informational?style=flat-square)
![Chart](https://img.shields.io/badge/Chart-wik--webservice-blue?style=flat-square)

## Introduction

This chart simplifies the deployment of a webservice on Kubernetes.

It creates:

- **ConfigMap/Secret/SealedSecret** for environment variables
- **Secret/SealedSecret** for registry pull credentials
- **Deployment** with configurable containers, probes, and resources
- **Service** with optional metrics port and Prometheus annotations
- **Ingress** with configurable hosts and annotations
- **HTTPRoute** for Gateway API routing (alternative to Ingress)
- **ListenerSet** for automatic TLS listener provisioning (Gateway API)
- **PVC** for persistent storage

## Breaking Changes

### 0.7.0

- **`webservice.ingress.enabled` now defaults to `false`** (was `true`).
  If you rely on Ingress, explicitly set `webservice.ingress.enabled: true` in your values.
- **`webservice.httpRoute.tls` now defaults to `true`**.
  A ListenerSet is auto-created when Gateway API ListenerSet CRDs are available on the cluster.
  Silently skipped if the CRDs are absent.
- **`webservice.httpRoute.parentRefs` replaced by `webservice.httpRoute.gatewayRef`**.
  Single object instead of array. For multi-gateway routing, use `additionalHttpRoutes`.

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
| `webservice.hosts` | Hostnames (used by Ingress and/or HTTPRoute) | `[]` |
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

### HTTPRoute (Gateway API)

The chart supports [Gateway API](https://gateway-api.sigs.k8s.io/) HTTPRoute as an alternative to Ingress. Gateway API CRDs must be installed on the cluster.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.httpRoute.enabled` | Create an HTTPRoute | `false` |
| `webservice.httpRoute.gatewayRef` | Gateway reference (`name`, `namespace`). Omitted if empty | `{}` |
| `webservice.httpRoute.tls` | Auto-create a ListenerSet for TLS (like `ingress.tlsAcme`). Skipped if CRDs absent | `true` |
| `webservice.httpRoute.addGatewayParentRef` | When `tls: true`, also add the Gateway as a parentRef (in addition to the ListenerSet) | `false` |
| `webservice.httpRoute.annotations` | HTTPRoute annotations | `{}` |
| `webservice.httpRoute.labels` | HTTPRoute labels | `{}` |
| `webservice.httpRoute.filters` | Filters for the default rule | `[]` |
| `webservice.httpRoute.additionalRules` | Extra routing rules | `[]` |
| `webservice.additionalHttpRoutes` | Additional HTTPRoute resources with custom hosts | `[]` |

```yaml
# Simple HTTPRoute with TLS (default)
# The ListenerSet is the only parentRef, Gateway is referenced via the ListenerSet
webservice:
  image: myapp:latest
  hosts:
    - app.example.com
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
      namespace: gateway

# Also add the Gateway as a parentRef (if needed by your implementation)
webservice:
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
    addGatewayParentRef: true

# Without TLS — Gateway is the only parentRef
webservice:
  httpRoute:
    enabled: true
    tls: false
    gatewayRef:
      name: main-gateway

# Additional HTTPRoutes with custom hosts
webservice:
  httpRoute:
    enabled: true
    gatewayRef:
      name: public-gateway
  additionalHttpRoutes:
    - name: internal
      parentRefs:
        - name: internal-gateway
      hosts:
        - internal.example.com
```

### ListenerSet (Gateway API TLS)

When `httpRoute.tls: true`, the chart auto-creates a ListenerSet that adds HTTPS listeners to the referenced Gateway for each host in `webservice.hosts`. Advanced configuration is available via `webservice.listenerSet`.

> **Note**: ListenerSet uses `gateway.networking.k8s.io/v1` (ListenerSet) when available, falling back to `gateway.networking.x-k8s.io/v1alpha1` (XListenerSet) on older clusters.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `webservice.listenerSet.port` | Listener port | `443` |
| `webservice.listenerSet.protocol` | Listener protocol | `HTTPS` |
| `webservice.listenerSet.tls.mode` | TLS mode | `Terminate` |
| `webservice.listenerSet.tls.certificateRefs` | Certificate references (defaults to `Secret/<fullname>--tls`) | `[]` |
| `webservice.listenerSet.annotations` | ListenerSet annotations | `{}` |
| `webservice.listenerSet.labels` | ListenerSet labels | `{}` |

```yaml
# Minimal TLS (all defaults)
webservice:
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
    # tls: true is the default
  # Auto-creates ListenerSet:
  #   - uses httpRoute.gatewayRef as gateway target
  #   - certificateRef: Secret/<fullname>--tls

# With cert-manager auto-provisioning
webservice:
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
  listenerSet:
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod

# Custom TLS certificate
webservice:
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
  listenerSet:
    tls:
      certificateRefs:
        - kind: Secret
          name: my-custom-cert
```

### Migrating from Ingress to Gateway API

In Gateway API, cross-cutting concerns (timeouts, auth, rate limiting) move from per-route annotations to **Policy CRDs** managed alongside the Gateway infrastructure. TLS termination moves from per-Ingress config to **Gateway Listeners** (or **ListenerSet**).

#### Proxy settings (timeouts, body size, buffering)

**Before (Ingress + nginx annotations):**

```yaml
webservice:
  ingress:
    enabled: true
    className: nginx
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      nginx.ingress.kubernetes.io/proxy-connect-timeout: "3600"
      nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
      nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
      nginx.ingress.kubernetes.io/proxy-next-upstream: "off"
      nginx.ingress.kubernetes.io/proxy-request-buffering: "off"
```

**After (HTTPRoute + BackendTrafficPolicy):**

Chart values:
```yaml
webservice:
  ingress:
    enabled: false
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
```

Policy to create alongside (Envoy Gateway example):
```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: BackendTrafficPolicy
metadata:
  name: my-app-timeouts
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: my-app  # matches your release fullname
  timeout:
    http:
      connectionIdleTimeout: 3600s
      requestTimeout: 3600s
  proxyProtocol:
    requestBuffering:
      disabled: true
    maxRequestBodySize: 0  # unlimited
```

#### Basic authentication

**Before (Ingress + nginx annotations):**

```yaml
webservice:
  ingress:
    enabled: true
    annotations:
      nginx.ingress.kubernetes.io/auth-realm: Authentication Required
      nginx.ingress.kubernetes.io/auth-secret: basic-auth
      nginx.ingress.kubernetes.io/auth-type: basic
```

**After (HTTPRoute + SecurityPolicy):**

Chart values:
```yaml
webservice:
  ingress:
    enabled: false
  httpRoute:
    enabled: true
```

Policy to create alongside (Envoy Gateway example):
```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: my-app-basic-auth
spec:
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: my-app
  basicAuth:
    users:
      name: basic-auth  # reference to existing Secret
```

#### TLS (tlsAcme)

**Before (Ingress + tlsAcme):**

```yaml
webservice:
  ingress:
    enabled: true
    tlsAcme: true
```

**After (HTTPRoute + TLS):**

```yaml
webservice:
  ingress:
    enabled: false
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
    # tls: true is the default
  # Auto-creates a ListenerSet with HTTPS listeners for each host
  # certificateRefs defaults to Secret/<fullname>--tls
```

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
| `webservice.securityDefaults` | Apply hardened pod & container security defaults (merged with user overrides) | `true` |
| `webservice.securityContext` | Pod-level security context (merged on top of defaults) | `{}` |
| `webservice.containerSecurityContext` | Container-level security context (merged on top of defaults) | `{}` |
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

When `webservice.securityDefaults` is `true` (the default), the chart renders the following baseline:

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
```

`webservice.securityContext` and `webservice.containerSecurityContext` are merged **on top** of those defaults — user keys win, unset keys keep the default. So a partial override works as you'd expect:

```yaml
webservice:
  securityContext:
    runAsUser: 2000          # overrides the default 1000
    fsGroup: 2000            # overrides the default 1000
    # runAsNonRoot: true     # still applied from the defaults
  containerSecurityContext:
    readOnlyRootFilesystem: false
    seccompProfile:
      type: Localhost
      localhostProfile: "profiles/custom.json"
```

#### Disabling the defaults (root user, writable filesystem, …)

Setting `securityContext: {}` / `containerSecurityContext: {}` is **not enough** to opt out — they're already `{}` by default, and the defaults still render on top. Use `securityDefaults: false` to start from a clean slate (no `securityContext` block emitted at all → root user, writable rootfs, default caps):

```yaml
webservice:
  securityDefaults: false
```

You can still selectively add fields on top — e.g. run as root without forcing any other hardening:

```yaml
webservice:
  securityDefaults: false
  containerSecurityContext:
    runAsUser: 0
```

#### Pod-level vs container-level — why both?

Kubernetes lets several fields (`runAsUser`, `runAsGroup`, `runAsNonRoot`, `seccompProfile`, `seLinuxOptions`) live at **either** level. Container-level wins; pod-level acts as the default for every container in the pod (main, sidecars from `additionalContainers`, init containers). The other fields are scoped:

- **Pod-only** (volume/kernel attrs shared across the pod): `fsGroup`, `fsGroupChangePolicy`, `supplementalGroups`, `sysctls`
- **Container-only** (per-process kernel attrs): `allowPrivilegeEscalation`, `capabilities`, `privileged`, `readOnlyRootFilesystem`, `procMount`

The defaults set `runAsUser` / `runAsNonRoot` at both levels on purpose — pod-level covers any sidecar you add via `additionalContainers`, container-level locks the main container.

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

### With Gateway API (HTTPRoute)

```yaml
webservice:
  image: myapp:latest
  hosts:
    - app.example.com
  ingress:
    enabled: false
  httpRoute:
    enabled: true
    gatewayRef:
      name: main-gateway
      namespace: gateway-system
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
| webservice.additionalHttpRoutes | list | `[]` |  |
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
| webservice.httpRoute.addGatewayParentRef | bool | `false` |  |
| webservice.httpRoute.additionalRules | list | `[]` |  |
| webservice.httpRoute.annotations | object | `{}` |  |
| webservice.httpRoute.enabled | bool | `false` |  |
| webservice.httpRoute.filters | list | `[]` |  |
| webservice.httpRoute.gatewayRef | object | `{}` |  |
| webservice.httpRoute.labels | object | `{}` |  |
| webservice.httpRoute.tls | bool | `true` |  |
| webservice.image | string | `"nginx:latest"` |  |
| webservice.imagePullAuth.encrypted | string | `""` |  |
| webservice.imagePullAuth.password | string | `""` |  |
| webservice.imagePullAuth.registry | string | `""` |  |
| webservice.imagePullAuth.username | string | `""` |  |
| webservice.imagePullPolicy | string | `"Always"` |  |
| webservice.ingress.annotations | object | `{}` |  |
| webservice.ingress.className | string | `""` |  |
| webservice.ingress.enabled | bool | `false` |  |
| webservice.ingress.tlsAcme | bool | `true` |  |
| webservice.initContainers | list | `[]` |  |
| webservice.listenerSet.annotations | object | `{}` |  |
| webservice.listenerSet.labels | object | `{}` |  |
| webservice.listenerSet.port | int | `443` |  |
| webservice.listenerSet.protocol | string | `"HTTPS"` |  |
| webservice.listenerSet.tls.certificateRefs | list | `[]` |  |
| webservice.listenerSet.tls.mode | string | `"Terminate"` |  |
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
| webservice.securityDefaults | bool | `true` |  |
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
