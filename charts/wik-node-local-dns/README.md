# wik-node-local-dns

node-local-dns for ovh cluster

## Introduction

**WARNING**: NOT READY FOR ANYTHING OTHERS THAN OVH MANAGED KUBERNETES

This chart deploys NodeLocal DNS to improve DNS resolution performance and reliability in your Kubernetes cluster. NodeLocal DNS runs as a DaemonSet that creates a DNS cache on each node, reducing DNS lookup latency and avoiding DNS timeouts.

## Installation

```bash
helm install my-nodelocaldns ./wik-node-local-dns -f values.yaml
```

## Configuration

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Container registry | `registry.k8s.io` |
| `image.repository` | Image repository | `dns/k8s-dns-node-cache` |
| `image.tag` | Image tag | `1.22.11` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Update Strategy

| Parameter | Description | Default |
|-----------|-------------|---------|
| `updateStrategy.rollingUpdate.maxUnavailable` | Maximum unavailable pods during update | `10%` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.cpu` | CPU request | `25m` |
| `resources.requests.memory` | Memory request | `5Mi` |
| `resources.limits` | Resource limits | `{}` |

### Upstream DNS

| Parameter | Description | Default |
|-----------|-------------|---------|
| `upstream.selector` | Selector for upstream DNS servers | `{k8s-app: kube-dns}` |

## How it Works

NodeLocal DNS creates a DNS cache on each node by:
1. Deploying a DaemonSet with a DNS cache pod on every node
2. Configuring nodes to use the local cache (typically at 169.254.20.10)
3. Forwarding cache misses to the cluster's upstream DNS servers

## Benefits

- **Reduced DNS latency**: Local cache eliminates network round-trips
- **Improved reliability**: Less susceptible to network connectivity issues
- **Better scalability**: Reduces load on upstream DNS servers
- **Consistent performance**: Avoids DNS timeouts during cluster load

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.digest | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `"registry.k8s.io"` |  |
| image.repository | string | `"dns/k8s-dns-node-cache"` |  |
| image.tag | string | `"1.22.11"` |  |
| resources.limits | object | `{}` |  |
| resources.requests.cpu | string | `"25m"` |  |
| resources.requests.memory | string | `"5Mi"` |  |
| updateStrategy.rollingUpdate.maxUnavailable | string | `"10%"` |  |
| upstream.selector.k8s-app | string | `"kube-dns"` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Wikodit |  | <https://github.com/wikodit> |
| Anthony Domingue | <anthony@wikodit.fr> |  |
| Jeremy Trufier | <jeremy@wikodit.fr> |  |
