# wik-backup

Chart using Wikodit AIO Backup (based on restic)

## Installation

```bash
helm install wik-backup oci://ghcr.io/wikodit/charts/wik-backup --version 0.1.0
```

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 2.x.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| args | list | `[]` |  |
| backup.adapter | string | `"fs"` |  |
| backup.cron | bool | `true` |  |
| backup.enableDbLock | bool | `true` |  |
| backup.enabled | bool | `true` |  |
| backup.logLevel | int | `5` |  |
| backup.mode | string | `"files"` |  |
| backup.noClean | bool | `false` |  |
| backup.retentionPolicy | string | `"hourly=24 daily=7 weekly=5 monthly=12 yearly=5 last=10"` |  |
| backup.schedule | string | `"@daily"` |  |
| backup.tags | list | `[]` |  |
| command | list | `[]` |  |
| commonAnnotations | object | `{}` |  |
| commonLabels | object | `{}` |  |
| extraAdapterArgs | list | `[]` |  |
| extraArgs | list | `[]` |  |
| extraEnvVars | list | `[]` |  |
| extraEnvVarsCM | string | `""` |  |
| extraEnvVarsSecret | string | `""` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| image.digest | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `"registry.cluster.wik.cloud"` |  |
| image.repository | string | `"utils/wik-aio-backup"` |  |
| image.tag | string | `"latest"` |  |
| initContainers | list | `[]` |  |
| nameOverride | string | `""` |  |
| nodeAffinityPreset.key | string | `""` |  |
| nodeAffinityPreset.type | string | `""` |  |
| nodeAffinityPreset.values | list | `[]` |  |
| nodeSelector | object | `{}` |  |
| podAffinityPreset | string | `""` |  |
| podAnnotations | object | `{}` |  |
| podAntiAffinityPreset | string | `"soft"` |  |
| podLabels | object | `{}` |  |
| priorityClassName | string | `""` |  |
| repository.credentials.awsAccessKeyId | string | `""` |  |
| repository.credentials.awsSecretAccessKey | string | `""` |  |
| repository.existingSecretName | string | `""` |  |
| repository.password | string | `nil` |  |
| repository.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| repository.persistence.annotations | object | `{}` |  |
| repository.persistence.dataSource | object | `{}` |  |
| repository.persistence.enabled | bool | `false` |  |
| repository.persistence.existingClaim | string | `""` |  |
| repository.persistence.selector | object | `{}` |  |
| repository.persistence.size | string | `"5Gi"` |  |
| repository.persistence.storageClass | string | `""` |  |
| repository.persistence.subMountPath | string | `""` |  |
| repository.uri | string | `""` |  |
| resources.limits | object | `{}` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.memory | string | `"512Mi"` |  |
| restartPolicy | string | `"OnFailure"` |  |
| restoreJob.enabled | bool | `false` |  |
| restoreJob.snapshotId | string | `"latest"` |  |
| restoreJob.tags | list | `[]` |  |
| schedulerName | string | `""` |  |
| sidecars | list | `[]` |  |
| targetDatabase.auth.password | string | `""` |  |
| targetDatabase.auth.user | string | `""` |  |
| targetDatabase.connectionOptions | object | `{}` |  |
| targetDatabase.databaseName | string | `""` |  |
| targetDatabase.existingSecret.mongoUriKey | string | `"mongoUri"` |  |
| targetDatabase.existingSecret.name | string | `""` |  |
| targetDatabase.existingSecret.passwordKey | string | `"password"` |  |
| targetDatabase.existingSecret.userKey | string | `"user"` |  |
| targetDatabase.host | string | `""` |  |
| targetDatabase.port | string | `""` |  |
| targetVolume.existingClaim | string | `""` |  |
| targetVolume.mountPath | string | `""` |  |
| targetVolume.selector | object | `{}` |  |
| targetVolume.subPath | string | `""` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Wikodit |  | <https://github.com/wikodit> |
| Anthony Domingue | <anthony@wikodit.fr> |  |
| Jeremy Trufier | <jeremy@wikodit.fr> |  |
