{{/*
Expand the name of the chart.
*/}}
{{- define "backup.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "default.volume.claimName" -}}
"{{ .Release.Name }}-backup-data"
{{-end }}

{{- define "common.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Return the proper Backup image name
*/}}
{{- define "backup.image" -}}
"{{ .Values.image.repository }}:{{ .Values.image.tag }}"
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "backup.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backup.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "backup.labels" -}}
helm.sh/chart: {{ include "backup.chart" . }}
{{ include "backup.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "backup.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backup.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "backup.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "backup.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the DB Auth Secret Name
*/}}
{{- define "backup.dbAuthSecret" -}}
{{- if .Values.backup.database.existingSecret }}
    {{- printf "%s" .Values.backup.database.existingSecret -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the repository credentials Secret Name
*/}}
{{- define "backup.repositorySecret" -}}
{{- if .Values.repository.existingSecretName }}
    {{- printf "%s" .Values.repository.existingSecretName -}}
{{- else -}}
    {{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return the Database Port
*/}}
{{- define "backup.databasePort" -}}
{{- if .Values.backup.database.host }}
    {{- printf "%d" ( .Values.backup.database.host | int ) -}}
{{- else if eq .Values.backup.adapter "mysql" -}}
    {{- printf "%d" 3306 -}}
{{- else if eq .Values.backup.adapter "pg" -}}
    {{- printf "%d" 5432 -}}
{{- else if eq .Values.backup.adapter "mongo" -}}
    {{- printf "%d" 27017 -}}
{{- else -}}
    {{- printf "%d" 0 -}}
{{- end -}}
{{ - end -}}