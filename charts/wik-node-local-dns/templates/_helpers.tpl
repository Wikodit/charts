{{/* vim: set filetype=mustache: */}}

{{/*
Return the proper image name
*/}}
{{- define "node-cache.image" -}}
{{- include "common.images.image" (dict "imageRoot" .Values.image "global" .Values.global) -}}
{{- end -}}