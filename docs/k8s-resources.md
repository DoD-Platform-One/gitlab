# Kubernetes resource configuration
The BigBang Gitlab Package has a default resource configuration for a minimal installation which is sufficient for development, demos, and CI pipelines. For larger operational deployments you must increase the CPU and memory as needed. Consult Gitlab documentation and Gitlab Support for appropriate settings. The resource requests and limits must be equal to achive quality of service guarantee. Below is a catalog of the possible resource configurations which are provided here for convenience. The values below are fake. If you are pasting selected portions into a BigBang values override file you will need to add three additional indent levels and place them under
```yaml
addons:
  gitlab:
    values:
```
Here are the possible settings:
```yaml
gitlab:
  toolbox:
    init:
      resources:
        requests:
          cpu: 201m
          memory: 201Mi
        limits:
          cpu: 201m
          memory: 201Mi
    resources:
      requests:
        cpu: 1
        memory: 1Gi
      limits:
        cpu: 1
        memory: 1Gi
    backups:
      cron:
        resources:
          requests:
            cpu: 351m
            memory: 351Mi
          limits:
            cpu: 351m
            memory: 351Mi
  gitlab-exporter:
    init:
      resources:
        limits:
          cpu: 201m
          memory: 201Mi
        requests:
          cpu: 201m
          memory: 201Mi
    resources:
      limits:
        cpu: 151m
        memory: 201Mi
      requests:
        cpu: 151m
        memory: 201Mi
  migrations:
    init:
      resources:
        limits:
          cpu: 201m
          memory: 201Mi
        requests:
          cpu: 201m
          memory: 201Mi
    resources:
      limits:
        cpu: 501m
        memory: 1.1G
      requests:
        cpu: 501m
        memory: 1.1G
  webservice:
    init:
      resources:
        limits:
          cpu: 201m
          memory: 201Mi
        requests:
          cpu: 201m
          memory: 201Mi
    resources:
      limits:
        cpu: 601m
        memory: 2.6G
      requests:
        cpu: 601m 
        memory: 2.6G
    workhorse:
      resources:
        limits:
          cpu: 601m
          memory: 2.6G
        requests:
          cpu: 601m
          memory: 2.6G
  sidekiq:
    init:
      resources:
        limits:
          cpu: 201m
          memory: 201Mi
        requests:
          cpu: 201m
          memory: 201Mi
    resources:
      requests:
        memory: 3G
        cpu: 1500m
      limits:
        memory: 3G
        cpu: 1500m
  gitaly:
    init:
      resources:
        limits:
          cpu: 201m
          memory: 201Mi
        requests:
          cpu: 201m
          memory: 201Mi
    resources:
      requests:
        cpu: 201m
        memory: 301Mi
      limits:
        cpu: 201m
        memory: 301Mi
  gitlab-shell:
    init:
      resources:
        limits:
          cpu: 201m
          memory: 201Mi
        requests:
          cpu: 201m
          memory: 201Mi
    resources:
      limits:
        cpu: 301m
        memory: 301Mi
      requests:
        cpu: 301m
        memory: 301Mi
  praefect:
    init:
      resources:
        limits:
          cpu: 200m
          memory: 200Mi
        requests:
          cpu: 200m
          memory: 200Mi
    resources:
      requests:
        cpu: 1.1
        memory: 1.1Gi
      limits:
        cpu: 1.1
        memory: 1.1Gi
upgradeCheck:
  resources:
    requests:
      cpu: 501m
      memory: 501M
    limits:
      cpu: 501m
      memory: 501M
redis:
  metrics:
    resources:
      limits: 
        cpu: 251m
        memory: 257Mi
      requests: 
        cpu: 251m
        memory: 257Mi
  master:
    command: "redis-server"
    resources: 
      limits: 
        cpu: 251m
        memory: 257Mi
      requests: 
        cpu: 251m
        memory: 257Mi
  slave:
    command: "redis-server"
    resources: 
      limits: 
        cpu: 251m
        memory: 257Mi
      requests: 
        cpu: 251m
        memory: 257Mi
  sentinel:
    resources: 
      limits: 
        cpu: 251m
        memory: 257Mi
      requests: 
        cpu: 251m
        memory: 257Mi
  volumePermissions:
    resources: 
      limits: 
        cpu: 251m
        memory: 257Mi
      requests: 
        cpu: 257m
        memory: 257Mi
  sysctlImage:
    resources: 
      limits: 
        cpu: 251m
        memory: 257Mi
      requests: 
        cpu: 251m
        memory: 257Mi
postgresql:
  resources:
    limits:
      cpu: 501m
      memory: 501Mi
    requests:
      cpu: 501m
      memory: 501Mi
registry:
  enabled: true
  init:
    resources:
      limits:
        cpu: 201m
        memory: 201Mi
      requests:
        cpu: 201m
        memory: 201Mi
  resources:
    limits:
      cpu: 201m
      memory: 1025Mi
    requests:
      cpu: 201m
      memory: 1025Mi
shared-secrets:
  resources:
    requests:
      cpu: 301m
      memory: 202Mi
    limits:
      cpu: 301m
      memory: 202Mi
minio:
  init:
    resources:
      limits:
        cpu: 201m
        memory: 201Mi
      requests:
        cpu: 201m
        memory: 201Mi
  resources:
    limits:
      cpu: 201m
      memory: 301Mi
    requests:
      cpu: 201m
      memory: 301Mi
```