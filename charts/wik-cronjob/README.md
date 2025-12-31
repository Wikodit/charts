# wik-cronjob

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)
![Chart](https://img.shields.io/badge/Chart-wik--cronjob-blue?style=flat-square)

## Introduction

This charts aims to simplify the deployment of a cronjob.

It setups :

* ConfigMap/Secret/SealedSecret with environment variables
* Secret/SealedSecret with docker pull secret
* PVC...

## Installation

```bash
helm install my-cronjob ./wik-cronjob -f values.yaml
```

## Configuration

### General

| Parameter | Description | Default |
|-----------|-------------|---------|
| `general.sealedSecrets` | Use SealedSecrets instead of plain Secrets | `false` |

### Cronjob

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cronjob.schedule` | Cron schedule expression | `"0 1 * * *"` |
| `cronjob.image` | Container image configuration | `{}` |
| `cronjob.imagePullPolicy` | Image pull policy | `Always` |
| `cronjob.restartPolicy` | Pod restart policy | `OnFailure` |
| `cronjob.resources` | CPU/Memory requests and limits | `{}` |

### Environment Variables

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cronjob.env.plaintext` | Plain environment variables (stored in ConfigMap) | `{}` |
| `cronjob.env.secret` | Secret environment variables (stored in Secret/SealedSecret) | `{}` |

### Volumes

| Parameter | Description | Default |
|-----------|-------------|---------|
| `cronjob.storage` | PVC definitions | `{}` |
| `cronjob.volumes` | Volume mounts (PVC, ConfigMap, Secret) | `[]` |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cronjob.additionalContainers | list | `[]` |  |
| cronjob.env.plaintext | object | `{}` |  |
| cronjob.env.secret | object | `{}` |  |
| cronjob.image.pullPolicy | string | `"Always"` |  |
| cronjob.image.repository | string | `""` |  |
| cronjob.image.tag | string | `""` |  |
| cronjob.imagePullAuth.encrypted | string | `""` |  |
| cronjob.imagePullAuth.password | string | `""` |  |
| cronjob.imagePullAuth.registry | string | `""` |  |
| cronjob.imagePullAuth.username | string | `""` |  |
| cronjob.initContainers | list | `[]` |  |
| cronjob.nodeSelector | object | `{}` |  |
| cronjob.resources | object | `{}` |  |
| cronjob.restartPolicy | string | `"OnFailure"` |  |
| cronjob.schedule | string | `"0 1 * * *"` |  |
| cronjob.securityContext | object | `{}` |  |
| cronjob.storage | object | `{}` |  |
| cronjob.volumes | list | `[]` |  |
| general.sealedSecrets | bool | `false` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Wikodit |  | <https://github.com/wikodit> |
| Anthony Domingue | <anthony@wikodit.fr> |  |
| Jérémy Trufier | <jeremy@wikodit.fr> |  |
