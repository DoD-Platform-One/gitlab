{{/* ######### GitLab related templates */}}

{{/*
Return the initial root password secret name
*/}}
{{- define "gitlab.migrations.initialRootPassword.secret" -}}
{{- default (printf "%s-gitlab-initial-root-password" .Release.Name) .Values.global.initialRootPassword.secret | quote -}}
{{- end -}}

{{/*
Return the initial root password secret key
*/}}
{{- define "gitlab.migrations.initialRootPassword.key" -}}
{{- coalesce .Values.global.initialRootPassword.key "password" | quote -}}
{{- end -}}

{{/*
Return the initial Enterprise license secret key
*/}}
{{- define "gitlab.migrations.license.key" -}}
{{- coalesce .Values.global.gitlab.license.key "license" | quote -}}
{{- end -}}

{{/*
Define the migration Job template
*/}}
{{- define "gitlab.migrations.job" -}}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ printf "%s-gitlab-migrations-%s" .Release.Name (randAlphaNum 6 | lower) }}
  labels:
    job-type: migration
spec:
  template:
    metadata:
      labels:
        app: gitlab-migrations
    spec:
      containers:
      - name: migrations
        image: {{ .Values.migrations.image }}
        command: ["/bin/sh", "-c", "run-migrations.sh"]
      restartPolicy: OnFailure
{{- end -}}