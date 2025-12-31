{{/* vim: set filetype=mustache: */}}

{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "defaultname" -}}
{{- if .name }}
{{- $name := default .root.Chart.Name .root.Values.nameOverride -}}
{{- printf "%s-%s-%s" .root.Release.Name $name .name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- template "fullname" .root }}
{{- end }}
{{- end -}}

{{- define "serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "labels" -}}
helm.sh/chart: {{ include "chart" . }}
{{ include "selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "selectorLabels" -}}
app.kubernetes.io/name: {{ include "name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
