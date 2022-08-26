{{/*
Helper for Sentinels as a string

Expectation: input contents has .sentinels, which is a List of Dict
    in the format of [{host: , port:}, ...]
*/}}
{{- define "registry.redis.host.sentinels" -}}
{{- $sentinels := list -}}
{{- range .sentinels -}}
{{-   $sentinels = append $sentinels (printf "%s:%d" .host (default 26379 .port | int)) -}}
{{- end -}}
{{ join "," $sentinels }}
{{- end -}}


{{- define "gitlab.registry.redisCacheSecret.mount" -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- if .redisMergedConfig.password.enabled }}
- secret:
    name: {{ template "gitlab.redis.password.secret" . }}
    items:
      - key: {{ template "gitlab.redis.password.key" . }}
        path: registry/{{ printf "%s-password" (default "redis" .redisConfigName) }}
{{- end }}
{{- end -}}


{{/*
Return migration configuration.
*/}}
{{- define "registry.redis.config" -}}
{{- include "gitlab.redis.selectedMergedConfig" . -}}
redis:
  cache:
    enabled: {{ .Values.redis.cache.enabled | eq true }}
    {{- /*TODO: Refactor once https://gitlab.com/gitlab-org/container-registry/-/issues/749 is fixed */ -}}
    {{- if .Values.redis.cache.host }}
    addr: {{ printf "%s:%d" .Values.redis.cache.host (int .Values.redis.cache.port | default 6379) | quote }}
    {{- else if not .redisMergedConfig.sentinels }}
    addr: {{ printf "%s:%s" ( include "gitlab.redis.host" . ) ( include "gitlab.redis.port" . ) | quote }}
    {{- else }}
    addr:  {{ include "registry.redis.host.sentinels" .redisMergedConfig | quote }}
    mainName: {{ template "gitlab.redis.host" . }}
    {{- end }}
    {{- if .redisMergedConfig.password.enabled }}
    password: "REDIS_CACHE_PASSWORD"
    {{- end }}
    {{- if hasKey .Values.redis.cache "db" }}
    db: {{ .Values.redis.cache.db }}
    {{- end }}
    {{- if .Values.redis.cache.dialtimeout }}
    dialtimeout: {{ .Values.redis.cache.dialtimeout }}
    {{- end }}
    {{- if .Values.redis.cache.readtimeout }}
    readtimeout: {{ .Values.redis.cache.readtimeout }}
    {{- end }}
    {{- if .Values.redis.cache.writetimeout }}
    writetimeout: {{ .Values.redis.cache.writetimeout }}
    {{- end }}
    {{- if .Values.redis.cache.tls }}
    tls:
      enabled: {{ .Values.redis.cache.tls.enabled | eq true }}
      insecure: {{ .Values.redis.cache.tls.insecure | eq true }}
    {{- end }}
    {{- if .Values.redis.cache.pool }}
    pool:
      {{- if .Values.redis.cache.pool.size }}
      size: {{ .Values.redis.cache.pool.size }}
      {{- end }}
      {{- if .Values.redis.cache.pool.maxlifetime }}
      maxlifetime: {{ .Values.redis.cache.pool.maxlifetime }}
      {{- end }}
      {{- if .Values.redis.cache.pool.idletimeout }}
      idletimeout: {{ .Values.redis.cache.pool.idletimeout }}
      {{- end -}}
    {{- end -}}
{{- end -}}
