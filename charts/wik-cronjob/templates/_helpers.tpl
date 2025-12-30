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