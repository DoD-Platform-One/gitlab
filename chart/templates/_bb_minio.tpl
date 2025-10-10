{{/* ######### Minio related templates */}}

{{/*
Return the minio credentials secret
*/}}
{{- define "minio.labels" -}}
app: minio
{{- end }}
