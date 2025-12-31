# wik-rbac

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square)
![Chart](https://img.shields.io/badge/Chart-wik--rbac-blue?style=flat-square)

Install rbac-manager and deal with users, roles and namespaces

## Introduction

This chart installs rbac-manager and provides a simplified way to manage Kubernetes RBAC resources including:
- Namespaces with quotas and roles
- ServiceAccounts
- ClusterRoles
- Role and ClusterRole bindings

## Installation

```bash
helm install my-rbac ./wik-rbac -f values.yaml
```

## Configuration

### Namespaces

Define namespaces with optional quotas and roles:

```yaml
namespaces:
  - name: dev
    labels:
      environment: dev
    quotas:
      pods: "10"
      requests.cpu: "1"
      requests.memory: 1Gi
      limits.cpu: "2"
      limits.memory: 2Gi
    roles:
      - name: developer-role
        rules:
          - apiGroups: [""]
            resources: ["pods", "services"]
            verbs: ["get", "list", "create", "delete"]
```

### ServiceAccounts

Create service accounts:

```yaml
serviceAccounts:
  - name: ci-service-account
```

### ClusterRoles

Define cluster-wide roles:

```yaml
clusterRoles:
  - name: secrets-reader
    labels:
      rbac-manager: "true"
    rules:
      - apiGroups: [""]
        resources: ["secrets"]
        verbs: ["get", "watch", "list"]
```

### Bindings

Create role and cluster role bindings:

```yaml
bindings:
  - name: developer-binding
    subjects:
      - kind: User
        name: developer@example.com
    roleBindings:
      - namespace: dev
        clusterRole: edit
      - namespace: staging
        clusterRole: view
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| bindings | list | `[]` |  |
| clusterRoles | list | `[]` |  |
| namespaces | list | `[]` |  |
| serviceAccounts | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Wikodit |  | <https://github.com/wikodit> |
| Anthony Domingue | <anthony@wikodit.fr> |  |
| Jeremy Trufier | <jeremy@wikodit.fr> |  |
