---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Using the Container Registry
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

The `registry` sub-chart provides the Registry component to a complete cloud-native
GitLab deployment on Kubernetes. This sub-chart is based on the
[upstream chart](https://github.com/docker/distribution-library-image)
and contains the GitLab [Container Registry](https://gitlab.com/gitlab-org/container-registry).

This chart is composed of 3 primary parts:

- [Service](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/service.yaml),
- [Deployment](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/deployment.yaml),
- [ConfigMap](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/configmap.yaml).

All configuration is handled according to the
[Registry configuration documentation](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md?ref_type=heads)
using `/etc/docker/registry/config.yml` variables provided to the `Deployment` populated
from the `ConfigMap`. The `ConfigMap` overrides the upstream defaults, but is
[based on them](https://github.com/docker/distribution-library-image/blob/master/config-example.yml).
See below for more details:

- [`distribution/cmd/registry/config-example.yml`](https://github.com/docker/distribution/blob/master/cmd/registry/config-example.yml)
- [`distribution-library-image/config-example.yml`](https://github.com/docker/distribution-library-image/blob/master/config-example.yml)

## Design Choices

A Kubernetes `Deployment` was chosen as the deployment method for this chart to allow
for simple scaling of instances, while allowing for
[rolling updates](https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-intro/).

This chart makes use of two required secrets and one optional:

### Required

- `global.registry.certificate.secret`: A global secret that will contain the public
  certificate bundle to verify the authentication tokens provided by the associated
  GitLab instance(s). See [documentation](https://docs.gitlab.com/administration/packages/container_registry/#use-an-external-container-registry-with-gitlab-as-an-auth-endpoint)
  on using GitLab as an auth endpoint.
- `global.registry.httpSecret.secret`: A global secret that will contain the
  [shared secret](https://distribution.github.io/distribution/about/configuration/#http) between registry pods.

### Optional

- `profiling.stackdriver.credentials.secret`: If Stackdriver profiling is enabled and
  you need to provide explicit service account credentials, then the value in this secret
  (in the `credentials` key by default) is the GCP service account JSON credentials.
  If you are using GKE and are providing service accounts to your workloads using
  [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
  (or node service accounts, although this is not recommended), then this secret is not required
  and should not be supplied. In either case, the service account requires the role
  `roles/cloudprofiler.agent` or equivalent [manual permissions](https://cloud.google.com/profiler/docs/iam#roles)

## Configuration

We will describe all the major sections of the configuration below. When configuring
from the parent chart, these values will be:

```yaml
registry:
  enabled:
  maintenance:
    readonly:
      enabled: false
    uploadpurging:
      enabled: true
      age: 168h
      interval: 24h
      dryrun: false
  image:
    tag: 'v4.15.2-gitlab'
    pullPolicy: IfNotPresent
  annotations:
  service:
    type: ClusterIP
    name: registry
  httpSecret:
    secret:
    key:
  authEndpoint:
  tokenIssuer:
  certificate:
    secret: gitlab-registry
    key: registry-auth.crt
  deployment:
    terminationGracePeriodSeconds: 30
  draintimeout: '0'
  hpa:
    minReplicas: 2
    maxReplicas: 10
    cpu:
      targetAverageUtilization: 75
    behavior:
      scaleDown:
        stabilizationWindowSeconds: 300
  storage:
    secret:
    key: storage
    extraKey:
  validation:
    disabled: true
    manifests:
      referencelimit: 0
      payloadsizelimit: 0
      urls:
        allow: []
        deny: []
  notifications: {}
  tolerations: []
  affinity: {}
  ingress:
    enabled: false
    tls:
      enabled: true
      secretName: redis
    annotations:
    configureCertmanager:
    proxyReadTimeout:
    proxyBodySize:
    proxyBuffering:
  networkpolicy:
    enabled: false
    egress:
      enabled: false
      rules: []
    ingress:
      enabled: false
      rules: []
  serviceAccount:
    create: false
    automountServiceAccountToken: false
  tls:
    enabled: false
    secretName:
    verify: true
    caSecretName:
    cipherSuites:
```

If you chose to deploy this chart as a standalone, remove the `registry` at the top level.

## Installation parameters

| Parameter                                                | Default                                                              | Description |
|----------------------------------------------------------|----------------------------------------------------------------------|-------------|
| `annotations`                                            |                                                                      | Pod annotations |
| `podLabels`                                              |                                                                      | Supplemental Pod labels. Will not be used for selectors. |
| `common.labels`                                          |                                                                      | Supplemental labels that are applied to all objects created by this chart. |
| `authAutoRedirect`                                       | `true`                                                               | Auth auto-redirect (must be true for Windows clients to work) |
| `authEndpoint`                                           | `global.hosts.gitlab.name`                                           | Auth endpoint (only host and port) |
| `certificate.secret`                                     | `gitlab-registry`                                                    | JWT certificate |
| `debug.addr.port`                                        | `5001`                                                               | Debug port  |
| `debug.tls.enabled`                                      | `false`                                                              | Enable TLS for the debug port for the registry. Impacts liveness and readiness probes, as well as the metrics endpoint (if enabled) |
| `debug.tls.secretName`                                   |                                                                      | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the registry debug endpoint. When not set and `debug.tls.enabled=true` - the debug TLS configuration will default to the registry's TLS certificate. |
| `debug.prometheus.enabled`                               | `false`                                                              | **DEPRECATED** Use `metrics.enabled` |
| `debug.prometheus.path`                                  | `""`                                                                 | **DEPRECATED** Use `metrics.path` |
| `metrics.enabled`                                        | `false`                                                              | If a metrics endpoint should be made available for scraping |
| `metrics.path`                                           | `/metrics`                                                           | Metrics endpoint path |
| `metrics.serviceMonitor.enabled`                         | `false`                                                              | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping, note that enabling this removes the `prometheus.io` scrape annotations |
| `metrics.serviceMonitor.additionalLabels`                | `{}`                                                                 | Additional labels to add to the ServiceMonitor |
| `metrics.serviceMonitor.endpointConfig`                  | `{}`                                                                 | Additional endpoint configuration for the ServiceMonitor |
| `deployment.terminationGracePeriodSeconds`               | `30`                                                                 | Optional duration in seconds the pod needs to terminate gracefully. |
| `deployment.strategy`                                    | `{}`                                                                 | Allows one to configure the update strategy utilized by the deployment |
| `draintimeout`                                           | `'0'`                                                                | Amount of time to wait for HTTP connections to drain after receiving a SIGTERM signal (e.g. `'10s'`) |
| `relativeurls`                                           | `false`                                                              | Enable the registry to return relative URLs in Location headers. |
| `enabled`                                                | `true`                                                               | Enable registry flag |
| `extraContainers`                                        |                                                                      | Multiline literal style string containing a list of containers to include |
| `extraInitContainers`                                    |                                                                      | List of extra init containers to include |
| `hpa.behavior`                                           | `{scaleDown: {stabilizationWindowSeconds: 300 }}`                    | Behavior contains the specifications for up- and downscaling behavior (requires `autoscaling/v2beta2` or higher) |
| `hpa.customMetrics`                                      | `[]`                                                                 | Custom metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) |
| `hpa.cpu.targetType`                                     | `Utilization`                                                        | Set the autoscaling CPU target type, must be either `Utilization` or `AverageValue` |
| `hpa.cpu.targetAverageValue`                             |                                                                      | Set the autoscaling CPU target value |
| `hpa.cpu.targetAverageUtilization`                       | `75`                                                                 | Set the autoscaling CPU target utilization |
| `hpa.memory.targetType`                                  |                                                                      | Set the autoscaling memory target type, must be either `Utilization` or `AverageValue` |
| `hpa.memory.targetAverageValue`                          |                                                                      | Set the autoscaling memory target value |
| `hpa.memory.targetAverageUtilization`                    |                                                                      | Set the autoscaling memory target utilization |
| `hpa.minReplicas`                                        | `2`                                                                  | Minimum number of replicas |
| `hpa.maxReplicas`                                        | `10`                                                                 | Maximum number of replicas |
| `httpSecret`                                             |                                                                      | Https secret |
| `extraEnvFrom`                                           |                                                                      | List of extra environment variables from other data sources to expose |
| `image.pullPolicy`                                       |                                                                      | Pull policy for the registry image |
| `image.pullSecrets`                                      |                                                                      | Secrets to use for image repository |
| `image.repository`                                       | `registry.gitlab.com/gitlab-org/build/cng/gitlab-container-registry` | Registry image |
| `image.tag`                                              | `v4.15.2-gitlab`                                                     | Version of the image to use |
| `init.image.repository`                                  |                                                                      | initContainer image |
| `init.image.tag`                                         |                                                                      | initContainer image tag |
| `init.containerSecurityContext`                          |                                                                      | initContainer specific [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) |
| `init.containerSecurityContext.runAsUser`                | `1000`                                                               | initContainer specific: User ID under which the container should be started |
| `init.containerSecurityContext.allowPrivilegeEscalation` | `false`                                                              | initContainer specific: Controls whether a process can gain more privileges than its parent process |
| `init.containerSecurityContext.runAsNonRoot`             | `true`                                                               | initContainer specific: Controls whether the container runs with a non-root user |
| `init.containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                                                          | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container |
| `keda.enabled`                                           | `false`                                                              | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers` |
| `keda.pollingInterval`                                   | `30`                                                                 | The interval to check each trigger on |
| `keda.cooldownPeriod`                                    | `300`                                                                | The period to wait after the last trigger reported active before scaling the resource back to 0 |
| `keda.minReplicaCount`                                   | `hpa.minReplicas`                                                    | Minimum number of replicas KEDA will scale the resource down to. |
| `keda.maxReplicaCount`                                   | `hpa.maxReplicas`                                                    | Maximum number of replicas KEDA will scale the resource up to. |
| `keda.fallback`                                          |                                                                      | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback) |
| `keda.hpaName`                                           | `keda-hpa-{scaled-object-name}`                                      | The name of the HPA resource KEDA will create. |
| `keda.restoreToOriginalReplicaCount`                     |                                                                      | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted |
| `keda.behavior`                                          | `hpa.behavior`                                                       | The specifications for up- and downscaling behavior. |
| `keda.triggers`                                          |                                                                      | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory` |
| `log`                                                    | `{level: info, fields: {service: registry}}`                         | Configure the logging options |
| `minio.bucket`                                           | `global.registry.bucket`                                             | Legacy registry bucket name |
| `maintenance.readonly.enabled`                           | `false`                                                              | Enable registry's read-only mode |
| `maintenance.uploadpurging.enabled`                      | `true`                                                               | Enable upload purging |
| `maintenance.uploadpurging.age`                          | `168h`                                                               | Purge uploads older than the specified age |
| `maintenance.uploadpurging.interval`                     | `24h`                                                                | Frequency at which upload purging is performed |
| `maintenance.uploadpurging.dryrun`                       | `false`                                                              | Only list which uploads will be purged without deleting |
| `priorityClassName`                                      |                                                                      | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods. |
| `reporting.sentry.enabled`                               | `false`                                                              | Enable reporting using Sentry |
| `reporting.sentry.dsn`                                   |                                                                      | The Sentry DSN (Data Source Name) |
| `reporting.sentry.environment`                           |                                                                      | The Sentry [environment](https://docs.sentry.io/concepts/key-terms/environments/) |
| `profiling.stackdriver.enabled`                          | `false`                                                              | Enable continuous profiling using Stackdriver |
| `profiling.stackdriver.credentials.secret`               | `gitlab-registry-profiling-creds`                                    | Name of the secret containing credentials |
| `profiling.stackdriver.credentials.key`                  | `credentials`                                                        | Secret key in which the credentials are stored |
| `profiling.stackdriver.service`                          | `RELEASE-registry` (templated Service name)                          | Name of the Stackdriver service to record profiles under |
| `profiling.stackdriver.projectid`                        | GCP project where running                                            | GCP project to report profiles to |
| `database.configure`                                     | `false`                                                              | Populate database configuration in the registry chart without enabling it. Required when [migrating an existing registry](metadata_database.md#existing-registries). |
| `database.enabled`                                       | `false`                                                              | Enable metadata database. This is an experimental feature and must not be used in production environments. |
| `database.host`                                          | `global.psql.host`                                                   | The database server hostname. |
| `database.port`                                          | `global.psql.port`                                                   | The database server port. |
| `database.user`                                          |                                                                      | The database username. |
| `database.password.secret`                               | `RELEASE-registry-database-password`                                 | Name of the secret containing the database password. |
| `database.password.key`                                  | `password`                                                           | Secret key in which the database password is stored. |
| `database.name`                                          |                                                                      | The database name. |
| `database.sslmode`                                       |                                                                      | The SSL mode. Can be one of `disable`, `allow`, `prefer`, `require`, `verify-ca` or `verify-full`. |
| `database.ssl.secret`                                    | `global.psql.ssl.secret`                                             | A secret containing client certificate, key and certificate authority. Defaults to the main PostgreSQL SSL secret. |
| `database.ssl.clientCertificate`                         | `global.psql.ssl.clientCertificate`                                  | The key inside the secret referring the client certificate. |
| `database.ssl.clientKey`                                 | `global.psql.ssl.clientKey`                                          | The key inside the secret referring the client key. |
| `database.ssl.serverCA`                                  | `global.psql.ssl.serverCA`                                           | The key inside the secret referring the certificate authority (CA). |
| `database.connecttimeout`                                | `0`                                                                  | Maximum time to wait for a connection. Zero or not specified means waiting indefinitely. |
| `database.draintimeout`                                  | `0`                                                                  | Maximum time to wait to drain all connections on shutdown. Zero or not specified means waiting indefinitely. |
| `database.preparedstatements`                            | `false`                                                              | Enable prepared statements. Disabled by default for compatibility with PgBouncer. |
| `database.primary`                                       | `false`                                                              | Target primary database server. This is used to specify a dedicated FQDN to target when running registry `database.migrations`. The `host` will be used to run `database.migrations` when not specified. |
| `database.pool.maxidle`                                  | `0`                                                                  | The maximum number of connections in the idle connection pool. If `maxopen` is less than `maxidle`, then `maxidle` is reduced to match the `maxopen` limit. Zero or not specified means no idle connections. |
| `database.pool.maxopen`                                  | `0`                                                                  | The maximum number of open connections to the database. If `maxopen` is less than `maxidle`, then `maxidle` is reduced to match the `maxopen` limit. Zero or not specified means unlimited open connections. |
| `database.pool.maxlifetime`                              | `0`                                                                  | The maximum amount of time a connection may be reused. Expired connections may be closed lazily before reuse. Zero or not specified means unlimited reuse. |
| `database.pool.maxidletime`                              | `0`                                                                  | The maximum amount of time a connection may be idle. Expired connections may be closed lazily before reuse. Zero or not specified means unlimited duration. |
| `database.loadBalancing.enabled`                         | `false`                                                              | Enable database load balancing. This is an experimental feature and must not be used in production environments. |
| `database.loadBalancing.nameserver.host`                 | `localhost`                                                          | The host of the nameserver to use for looking up the DNS record. |
| `database.loadBalancing.nameserver.port`                 | `8600`                                                               | The port of the nameserver to use for looking up the DNS record. |
| `database.loadBalancing.record`                          |                                                                      | The SRV record to look up. This option is required for service discovery to work. |
| `database.loadBalancing.replicaCheckInterval`            | `1m`                                                                 | The minimum amount of time between checking the status of a replica. |
| `database.migrations.enabled`                            | `true`                                                               | Enable the migrations job to automatically run migrations upon initial deployment and upgrades of the Chart. Note that migrations can also be run manually from within any running Registry pods. |
| `database.migrations.activeDeadlineSeconds`              | `3600`                                                               | Set the [activeDeadlineSeconds](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup) on the migrations job. |
| `database.migrations.annotations`                        | `{}`                                                                 | Additional annotations to add to the migrations job. |
| `database.migrations.backoffLimit`                       | `6`                                                                  | Set the [backoffLimit](https://kubernetes.io/docs/concepts/workloads/controllers/job/#job-termination-and-cleanup) on the migrations job. |
| `database.backgroundMigrations.enabled`                  | `false`                                                              | Enable background migrations for the database. This is an experimental feature for the Registry metadata database. Do not use in production. See the [specification](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/spec/gitlab/database-background-migrations.md?ref_type=heads) for a detailed explanation of how it works. |
| `database.backgroundMigrations.jobInterval`              |                                                                      | The sleep interval between each background migration job worker run. When not specified [a default value is set by the registry](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md?ref_type=heads#backgroundmigrations). |
| `database.backgroundMigrations.maxJobRetries`            |                                                                      | The maximum number of retries for a failed background migration job. When not specified [a default value is set by the registry](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md?ref_type=heads#backgroundmigrations). |
| `gc.disabled`                                            | `true`                                                               | When set to `true`, the online GC workers are disabled. |
| `gc.maxbackoff`                                          | `24h`                                                                | The maximum exponential backoff duration used to sleep between worker runs when an error occurs. Also applied when there are no tasks to be processed unless `gc.noidlebackoff` is `true`. Please note that this is not the absolute maximum, as a randomized jitter factor of up to 33% is always added. |
| `gc.noidlebackoff`                                       | `false`                                                              | When set to `true`, disables exponential backoffs between worker runs when there are no tasks to be processed. |
| `gc.transactiontimeout`                                  | `10s`                                                                | The database transaction timeout for each worker run. Each worker starts a database transaction at the start. The worker run is canceled if this timeout is exceeded to avoid stalled or long-running transactions. |
| `gc.blobs.disabled`                                      | `false`                                                              | When set to `true`, the GC worker for blobs is disabled. |
| `gc.blobs.interval`                                      | `5s`                                                                 | The initial sleep interval between each worker run. |
| `gc.blobs.storagetimeout`                                | `5s`                                                                 | The timeout for storage operations. Used to limit the duration of requests to delete dangling blobs on the storage backend. |
| `gc.manifests.disabled`                                  | `false`                                                              | When set to `true`, the GC worker for manifests is disabled. |
| `gc.manifests.interval`                                  | `5s`                                                                 | The initial sleep interval between each worker run. |
| `gc.reviewafter`                                         | `24h`                                                                | The minimum amount of time after which the garbage collector should pick up a record for review. `-1` means no wait. |
| `securityContext.fsGroup`                                | `1000`                                                               | Group ID under which the pod should be started |
| `securityContext.runAsUser`                              | `1000`                                                               | User ID under which the pod should be started |
| `securityContext.fsGroupChangePolicy`                    |                                                                      | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23) |
| `securityContext.seccompProfile.type`                    | `RuntimeDefault`                                                     | Seccomp profile to use |
| `containerSecurityContext`                               |                                                                      | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started |
| `containerSecurityContext.runAsUser`                     | `1000`                                                               | Allow to overwrite the specific security context user ID under which the container is started |
| `containerSecurityContext.allowPrivilegeEscalation`      | `false`                                                              | Controls whether a process of the Gitaly container can gain more privileges than its parent process |
| `containerSecurityContext.runAsNonRoot`                  | `true`                                                               | Controls whether the container runs with a non-root user |
| `containerSecurityContext.capabilities.drop`             | `[ "ALL" ]`                                                          | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container |
| `serviceAccount.automountServiceAccountToken`            | `false`                                                              | Indicates whether or not the default ServiceAccount access token should be mounted in pods |
| `serviceAccount.enabled`                                 | `false`                                                              | Indicates whether or not to use a ServiceAccount |
| `serviceLabels`                                          | `{}`                                                                 | Supplemental service labels |
| `tokenService`                                           | `container_registry`                                                 | JWT token service |
| `tokenIssuer`                                            | `gitlab-issuer`                                                      | JWT token issuer |
| `tolerations`                                            | `[]`                                                                 | Toleration labels for pod assignment |
| `affinity`                                               | `{}`                                                                 | Affinity rules for pod assignment |
| `middleware.storage`                                     |                                                                      | configuration layer for midleware storage ([s3 for instance](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#example-middleware-configuration)) |
| `redis.cache.enabled`                                    | `false`                                                              | When set to `true`, the Redis cache is enabled. This feature is dependent on the [metadata database](#database) being enabled. Repository metadata will be cached on the configured Redis instance. |
| `redis.cache.host`                                       | `<Redis URL>`                                                        | The hostname of the Redis instance. If empty, the value will be filled as `global.redis.host:global.redis.port`. |
| `redis.cache.port`                                       | `6379`                                                               | The port of the Redis instance. |
| `redis.cache.sentinels`                                  | `[]`                                                                 | List sentinels with host and port. |
| `redis.cache.mainname`                                   |                                                                      | The main server name. Only applicable for Sentinel. |
| `redis.cache.password.enabled`                           | `false`                                                              | Indicates whether the Redis cache used by the Registry is password protected. |
| `redis.cache.password.secret`                            | `gitlab-redis-secret`                                                | Name of the secret containing the Redis password. This will be automatically created if not provided, when the `shared-secrets` feature is enabled. |
| `redis.cache.password.key`                               | `redis-password`                                                     | Secret key in which the Redis password is stored. |
| `redis.cache.sentinelpassword.enabled`                   | `false`                                                              | Indicates whether Redis Sentinels are password protected. If `redis.cache.sentinelpassword` is empty, the values from `global.redis.sentinelAuth` are used. Only used when `redis.cache.sentinels` is defined. |
| `redis.cache.sentinelpassword.secret`                    | `gitlab-redis-secret`                                                | Name of the secret containing the Redis Sentinel password. |
| `redis.cache.sentinelpassword.key`                       | `redis-sentinel-password`                                            | Secret key in which the Redis Sentinel password is stored. |
| `redis.cache.db`                                         | `0`                                                                  | The name of the database to use for each connection. |
| `redis.cache.dialtimeout`                                | `0s`                                                                 | The timeout for connecting to the Redis instance. Defaults to no timeout. |
| `redis.cache.readtimeout`                                | `0s`                                                                 | The timeout for reading from the Redis instance. Defaults to no timeout. |
| `redis.cache.writetimeout`                               | `0s`                                                                 | The timeout for writing to the Redis instance. Defaults to no timeout. |
| `redis.cache.tls.enabled`                                | `false`                                                              | Set to `true` to enable TLS. |
| `redis.cache.tls.insecure`                               | `false`                                                              | Set to `true` to disable server name verification when connecting over TLS. |
| `redis.cache.pool.size`                                  | `10`                                                                 | The maximum number of socket connections. Default is 10 connections. |
| `redis.cache.pool.maxlifetime`                           | `1h`                                                                 | The connection age at which client retires a connection. Default is to not close aged connections. |
| `redis.cache.pool.idletimeout`                           | `300s`                                                               | How long to wait before closing inactive connections. |
| `redis.rateLimiting.enabled`                             | `false`                                                              | When set to `true`, the Redis rate limiter is enabled. This feature is under development. |
| `redis.rateLimiting.host`                                | `<Redis URL>`                                                        | The hostname of the Redis instance. If empty, the value will be filled as `global.redis.host:global.redis.port`. |
| `redis.rateLimiting.port`                                | `6379`                                                               | The port of the Redis instance. |
| `redis.rateLimiting.cluster`                             | `[]`                                                                 | List of addresses with host and port. |
| `redis.rateLimiting.sentinels`                           | `[]`                                                                 | List sentinels with host and port. |
| `redis.rateLimiting.mainname`                            |                                                                      | The main server name. Only applicable for Sentinel. |
| `redis.rateLimiting.username`                            |                                                                      | The username used to connect to the Redis instance. |
| `redis.rateLimiting.password.enabled`                    | `false`                                                              | Indicates whether the Redis instance is password protected. |
| `redis.rateLimiting.password.secret`                     | `gitlab-redis-secret`                                                | Name of the secret containing the Redis password. This will be automatically created if not provided, when the `shared-secrets` feature is enabled. |
| `redis.rateLimiting.password.key`                        | `redis-password`                                                     | Secret key in which the Redis password is stored. |
| `redis.rateLimiting.db`                                  | `0`                                                                  | The name of the database to use for each connection. |
| `redis.rateLimiting.dialtimeout`                         | `0s`                                                                 | The timeout for connecting to the Redis instance. Defaults to no timeout. |
| `redis.rateLimiting.readtimeout`                         | `0s`                                                                 | The timeout for reading from the Redis instance. Defaults to no timeout. |
| `redis.rateLimiting.writetimeout`                        | `0s`                                                                 | The timeout for writing to the Redis instance. Defaults to no timeout. |
| `redis.rateLimiting.tls.enabled`                         | `false`                                                              | Set to `true` to enable TLS. |
| `redis.rateLimiting.tls.insecure`                        | `false`                                                              | Set to `true` to disable server name verification when connecting over TLS. |
| `redis.rateLimiting.pool.size`                           | `10`                                                                 | The maximum number of socket connections. |
| `redis.rateLimiting.pool.maxlifetime`                    | `1h`                                                                 | The connection age at which the client retires a connection. Default is to not close aged connections. |
| `redis.rateLimiting.pool.idletimeout`                    | `300s`                                                               | How long to wait before closing inactive connections. |
| `redis.loadBalancing.enabled`                            | `false`                                                              | When set to `true`, the Redis connection for [load balancing](#load-balancing) is enabled. |
| `redis.loadBalancing.host`                               | `<Redis URL>`                                                        | The hostname of the Redis instance. If empty, the value will be filled as `global.redis.host:global.redis.port`. |
| `redis.loadBalancing.port`                               | `6379`                                                               | The port of the Redis instance. |
| `redis.loadBalancing.cluster`                            | `[]`                                                                 | List of addresses with host and port. |
| `redis.loadBalancing.sentinels`                          | `[]`                                                                 | List sentinels with host and port. |
| `redis.loadBalancing.mainname`                           |                                                                      | The main server name. Only applicable for Sentinel. |
| `redis.loadBalancing.username`                           |                                                                      | The username used to connect to the Redis instance. |
| `redis.loadBalancing.password.enabled`                   | `false`                                                              | Indicates whether the Redis instance is password protected. |
| `redis.loadBalancing.password.secret`                    | `gitlab-redis-secret`                                                | Name of the secret containing the Redis password. This will be automatically created if not provided, when the `shared-secrets` feature is enabled. |
| `redis.loadBalancing.password.key`                       | `redis-password`                                                     | Secret key in which the Redis password is stored. |
| `redis.loadBalancing.db`                                 | `0`                                                                  | The name of the database to use for each connection. |
| `redis.loadBalancing.dialtimeout`                        | `0s`                                                                 | The timeout for connecting to the Redis instance. Defaults to no timeout. |
| `redis.loadBalancing.readtimeout`                        | `0s`                                                                 | The timeout for reading from the Redis instance. Defaults to no timeout. |
| `redis.loadBalancing.writetimeout`                       | `0s`                                                                 | The timeout for writing to the Redis instance. Defaults to no timeout. |
| `redis.loadBalancing.tls.enabled`                        | `false`                                                              | Set to `true` to enable TLS. |
| `redis.loadBalancing.tls.insecure`                       | `false`                                                              | Set to `true` to disable server name verification when connecting over TLS. |
| `redis.loadBalancing.pool.size`                          | `10`                                                                 | The maximum number of socket connections. |
| `redis.loadBalancing.pool.maxlifetime`                   | `1h`                                                                 | The connection age at which the client retires a connection. Default is to not close aged connections. |
| `redis.loadBalancing.pool.idletimeout`                   | `300s`                                                               | How long to wait before closing inactive connections. |

## Chart configuration examples

### `pullSecrets`

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```yaml
image:
  repository: my.registry.repository
  tag: latest
  pullPolicy: Always
  pullSecrets:
  - name: my-secret-name
  - name: my-secondary-secret-name
```

### `serviceAccount`

This section controls if a ServiceAccount should be created and if the default access token should be mounted in pods.

| Name                           |  Type   | Default | Description |
|:-------------------------------|:-------:|:--------|:------------|
| `automountServiceAccountToken` | Boolean | `false` | Controls if the default ServiceAccount access token should be mounted in pods. You should not enable this unless it is required by certain sidecars to work properly (for example, Istio). |
| `enabled`                      | Boolean | `false` | Indicates whether or not to use a ServiceAccount. |

### `tolerations`

`tolerations` allow you schedule pods on tainted worker nodes

Below is an example use of `tolerations`:

```yaml
tolerations:
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoExecute"
```

### `affinity`

`affinity` is an optional parameter that allows you to set either or both:

- `podAntiAffinity` rules to:
  - Not schedule pods in the same domain as the pods that match the expression corresponding to the `topology key`.
  - Set two modes of `podAntiAffinity` rules: required (`requiredDuringSchedulingIgnoredDuringExecution`) and preferred
    (`preferredDuringSchedulingIgnoredDuringExecution`). Using the variable `antiAffinity` in `values.yaml`, set the setting to `soft` so that the preferred mode is
    applied or set it to `hard` so that the required mode is applied.
- `nodeAffinity` rules to:
  - Schedule pods to nodes that belong to a specific zone or zones.
  - Set two modes of `nodeAffinity` rules: required (`requiredDuringSchedulingIgnoredDuringExecution`) and preferred
    (`preferredDuringSchedulingIgnoredDuringExecution`). When set to `soft`, the preferred mode is applied. When set to `hard`, the required mode is applied. This
    rule is implemented only for the `registry` chart and the `gitlab` chart alongwith all its subcharts except `webservice` and `sidekiq`.

`nodeAffinity` only implements the [`In` operator](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#operators).

For more information, see [the relevant Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity).

The following example sets `affinity`, with both `nodeAffinity` and `antiAffinity` set to `hard`:

```yaml
nodeAffinity: "hard"
antiAffinity: "hard"
affinity:
  nodeAffinity:
    key: "test.com/zone"
    values:
    - us-east1-a
    - us-east1-b
  podAntiAffinity:
    topologyKey: "test.com/hostname"
```

### `annotations`

`annotations` allows you to add annotations to the registry pods.

Below is an example use of `annotations`

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

## Enable the sub-chart

The way we've chosen to implement compartmentalized sub-charts includes the ability
to disable the components that you may not want in a given deployment. For this reason,
the first setting you should decide on is `enabled`.

By default, Registry is enabled out of the box. Should you wish to disable it, set `enabled: false`.

## Configuring the `image`

This section details the settings for the container image used by this sub-chart's
[Deployment](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/deployment.yaml).
You can change the included version of the Registry and `pullPolicy`.

Default settings:

- `tag: 'v4.15.2-gitlab'`
- `pullPolicy: 'IfNotPresent'`

## Configuring the `service`

This section controls the name and type of the [Service](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/templates/service.yaml).
These settings will be populated by [`values.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/registry/values.yaml).

By default, the Service is configured as:

| Name             |  Type  | Default     | Description |
|:-----------------|:------:|:------------|:------------|
| `name`           | String | `registry`  | Configures the name of the service |
| `type`           | String | `ClusterIP` | Configures the type of the service |
| `externalPort`   |  Int   | `5000`      | Port exposed by the Service |
| `internalPort`   |  Int   | `5000`      | Port utilized by the Pod to accept request from the service |
| `clusterIP`      | String | `null`      | Allows one to configure a custom Cluster IP as necessary |
| `loadBalancerIP` | String | `null`      | Allows one to configure a custom LoadBalancer IP address as necessary |

## Configuring the `ingress`

This section controls the registry Ingress.

| Name                   |  Type   | Default | Description |
|:-----------------------|:-------:|:--------|:------------|
| `apiVersion`           | String  |         | Value to use in the `apiVersion` field. |
| `annotations`          | String  |         | This field is an exact match to the standard `annotations` for [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/). |
| `configureCertmanager` | Boolean |         | Toggles Ingress annotation `cert-manager.io/issuer` and `acme.cert-manager.io/http01-edit-in-place`. For more information see the [TLS requirement for GitLab Pages](../../installation/tls.md). |
| `enabled`              | Boolean | `false` | Setting that controls whether to create Ingress objects for services that support them. When `false` the `global.ingress.enabled` setting is used. |
| `tls.enabled`          | Boolean | `true`  | When set to `false`, you disable TLS for the Registry subchart. This is mainly useful for cases in which you cannot use TLS termination at `ingress-level`, like when you have a TLS-terminating proxy before the Ingress Controller. |
| `tls.secretName`       | String  |         | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the registry URL. When not set, the `global.ingress.tls.secretName` is used instead. Defaults to not being set. |
| `tls.cipherSuites`     |  Array  | `[]`    | The list of cipher suites that Container registry should present to the client during TLS handshake. |

## Configuring TLS

Container Registry supports TLS which secures its communication with other components,
including `nginx-ingress`.

Prerequisites to configure TLS:

- The TLS certificate must include the Registry Service host name
  (for example, `RELEASE-registry.default.svc`) in the Common
  Name (CN) or Subject Alternate Name (SAN).
- After the TLS certificate generates:
  - Create a [Kubernetes TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)
  - Create another Secret that only contains the CA certificate of the TLS certificate with `ca.crt` key.

To enable TLS:

1. Set `registry.tls.enabled` to `true`.
1. Set `global.hosts.registry.protocol` to `https`.
1. Pass the Secret names to `registry.tls.secretName` and `global.certificates.customCAs` accordingly.

When `registry.tls.verify` is `true`, you must pass the CA certificate Secret
name to `registry.tls.caSecretName`. This is necessary for self-signed
certificates and custom Certificate Authorities. This Secret is used by NGINX to verify the TLS
certificate of Registry.

For example:

```yaml
global:
  certificates:
    customCAs:
    - secret: registry-tls-ca
  hosts:
    registry:
      protocol: https

registry:
  tls:
    enabled: true
    secretName: registry-tls
    verify: true
    caSecretName: registry-tls-ca
```

### Container Registry cipher suites

Normally `tls.cipherSuites` option should be used only in some very unusual configurations where registry is deployed in a standalone mode and/or some non-default Ingress is used that does not support modern cipher suites.
In a standard GitLab deployment, the NGINX Ingress will choose the highest supported TLS version by the container-registry backend, which is TLS1.3 at the moment.
TLS1.3 does not allow for configuring ciphers and is secure by default.
In case when for some reason TLS1.3 is unavailable, the default TLS1.2 ciphers list that Container Registry is using is also compatible with NGINX Ingress default settings and is secure as well.

### Configuring TLS for the debug port

The Registry debug port also supports TLS. The debug port is used for the
Kubernetes liveness and readiness checks as well as exposing a `/metrics`
endpoint for Prometheus (if enabled).

TLS can be enabled for by setting `registry.debug.tls.enabled` to `true`.
A [Kubernetes TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets)
can be provided in `registry.debug.tls.secretName` dedicated for use in
the debug port's TLS configuration. If a dedicated secret is not specified,
the debug configuration will fall back to sharing `registry.tls.secretName` with
the registry's regular TLS configuration.

For Prometheus to scrape the `/metrics/` endpoint using `https` - additional
configuration is required for the certificate's CommonName attribute or
a SubjectAlternativeName entry. See
[Configuring Prometheus to scrape TLS-enabled endpoints](../../installation/tools.md#configure-prometheus-to-scrape-tls-enabled-endpoints)
for those requirements.

## Configuring the `networkpolicy`

This section controls the registry
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
This configuration is optional and is used to limit egress and Ingress of the registry to specific endpoints.
and Ingress to specific endpoints.

| Name              |  Type   | Default | Description |
|:------------------|:-------:|:--------|:------------|
| `enabled`         | Boolean | `false` | This setting enables the `NetworkPolicy` for registry |
| `ingress.enabled` | Boolean | `false` | When set to `true`, the `Ingress` network policy will be activated. This will block all Ingress connections unless rules are specified. |
| `ingress.rules`   |  Array  | `[]`    | Rules for the Ingress policy, for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |
| `egress.enabled`  | Boolean | `false` | When set to `true`, the `Egress` network policy will be activated. This will block all egress connections unless rules are specified. |
| `egress.rules`    |  Array  | `[]`    | Rules for the egress policy, these for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |

### Example policy for preventing connections to all internal endpoints

The Registry service normally requires egress connections to object storage,
Ingress connections from Docker clients, and kube-dns for DNS lookups. This
adds the following network restrictions to the Registry service:

- Allows Ingress requests:
  - From the pods `sidekiq` , `webservice` and `nginx-ingress` to port `5000`
  - From the `Prometheus` pod to port `9235`
- Allows Egress requests:
  - To `kube-dns` to port `53`
  - To endpoints like AWS VPC endpoint for S3 or STS `172.16.1.0/24` to port `443`
  - To the internet `0.0.0.0/0` to port `443`

_Note that the registry service requires outbound connectivity to the public
internet for images on [external object storage](../../advanced/external-object-storage) if no endpoint is used_  

The example is based on the assumption that `kube-dns` was deployed
to the namespace `kube-system`, `prometheus` was deployed to the namespace
`monitoring` and `nginx-ingress` was deployed to the namespace `nginx-ingress`.

```yaml
networkpolicy:
  enabled: true
  ingress:
    enabled: true
    rules:
      - from:
          - namespaceSelector:
              matchLabels:
                kubernetes.io/metadata.name: nginx-ingress
            podSelector:
              matchLabels:
                app: nginx-ingress
                component: controller
        ports:
          - port: 5000
      - from:
          - namespaceSelector:
              matchLabels:
                kubernetes.io/metadata.name: monitoring
            podSelector:
              matchLabels:
                app: prometheus
                component: server
                release: gitlab
        ports:
          - port: 9235
      - from:
          - podSelector:
              matchLabels:
                app: sidekiq
        ports:
          - port: 5000
      - from:
          - podSelector:
              matchLabels:
                app: webservice
        ports:
          - port: 5000
  egress:
    enabled: true
    rules:
      - to:
          - namespaceSelector:
              matchLabels:
                kubernetes.io/metadata.name: kube-system
            podSelector:
              matchLabels:
                k8s-app: kube-dns
        ports:
          - port: 53
            protocol: UDP
      - to:
          - ipBlock:
              cidr: 172.16.1.0/24
        ports:
          - port: 443
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 10.0.0.0/8
```

## Configuring KEDA

This `keda` section enables the installation of [KEDA](https://keda.sh/) `ScaledObjects` instead of regular `HorizontalPodAutoscalers`.
This configuration is optional and can be used when there is a need for autoscaling based on custom or external metrics.

Most settings default to the values set in the `hpa` section where applicable.

If the following are true, CPU and memory triggers are added automatically based on the CPU and memory thresholds set in the `hpa` section:

- `triggers` is not set.
- The corresponding `request.cpu.request` or `request.memory.request` setting is also set to a non-zero value.

If no triggers are set, the `ScaledObject` is not created.

Refer to the [KEDA documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/) for more details about those settings.

| Name                            |  Type   | Default                         | Description |
|:--------------------------------|:-------:|:--------------------------------|:------------|
| `enabled`                       | Boolean | `false`                         | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers` |
| `pollingInterval`               | Integer | `30`                            | The interval to check each trigger on |
| `cooldownPeriod`                | Integer | `300`                           | The period to wait after the last trigger reported active before scaling the resource back to 0 |
| `minReplicaCount`               | Integer | `hpa.minReplicas`               | Minimum number of replicas KEDA will scale the resource down to. |
| `maxReplicaCount`               | Integer | `hpa.maxReplicas`               | Maximum number of replicas KEDA will scale the resource up to. |
| `fallback`                      |   Map   |                                 | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback) |
| `hpaName`                       | String  | `keda-hpa-{scaled-object-name}` | The name of the HPA resource KEDA will create. |
| `restoreToOriginalReplicaCount` | Boolean |                                 | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted |
| `behavior`                      |   Map   | `hpa.behavior`                  | The specifications for up- and downscaling behavior. |
| `triggers`                      |  Array  |                                 | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory` |

### Example policy for preventing connections to all internal endpoints

The Registry service normally requires egress connections to object storage,
Ingress connections from Docker clients, and kube-dns for DNS lookups. This
adds the following network restrictions to the Registry service:

- All egress requests to the local network on `10.0.0.0/8` port 53 are allowed (for kubeDNS)
- Other egress requests to the local network on `10.0.0.0/8` are restricted
- Egress requests outside of the `10.0.0.0/8` are allowed

_Note that the registry service requires outbound connectivity to the public
internet for images on [external object storage](../../advanced/external-object-storage)_

```yaml
networkpolicy:
  enabled: true
  egress:
    enabled: true
    # The following rules enable traffic to all external
    # endpoints, except the local
    # network (except DNS requests)
    rules:
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
        - port: 53
          protocol: UDP
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
            - 10.0.0.0/8
```

## Defining the Registry Configuration

The following properties of this chart pertain to the configuration of the underlying
[registry](https://hub.docker.com/_/registry/) container. Only the most critical values
for integration with GitLab are exposed. For this integration, we make use of the `auth.token.x`
settings of [Docker Distribution](https://github.com/docker/distribution), controlling
authentication to the registry via JWT [authentication tokens](https://distribution.github.io/distribution/spec/auth/token/).

### `httpSecret`

Field `httpSecret` is a map that contains two items: `secret` and `key`.

The content of the key this references correlates to the `http.secret` value of
[registry](https://hub.docker.com/_/registry/). This value should be populated with
a cryptographically generated random string.

The `shared-secrets` job will automatically create this secret if not provided. It will be
filled with a securely generated 128 character alpha-numeric string that is base64 encoded.

To create this secret manually:

```shell
kubectl create secret generic gitlab-registry-httpsecret --from-literal=secret=strongrandomstring
```

### Notification Secret

Notification Secret is utilized for calling back to the GitLab application in various ways,
such as for Geo to help manage syncing Container Registry data between primary and secondary sites.

The `notificationSecret` secret object will be automatically created if
not provided, when the `shared-secrets` feature is enabled.

To create this secret manually:

```shell
kubectl create secret generic gitlab-registry-notification --from-literal=secret=[\"strongrandomstring\"]
```

Then proceed to set

```yaml
global:
  # To provide your own secret
  registry:
    notificationSecret:
        secret: gitlab-registry-notification
        key: secret

  # If utilising Geo, and wishing to sync the container registry.
  # Define this in the primary site configs only.
  geo:
    registry:
      replication:
        enabled: true
        primaryApiUrl: <URL to primary registry>
```

Ensuring the `secret` value is set to the name of the secret created above

### Redis cache Secret

The Redis cache Secret is used when `global.redis.auth.enabled` is set to `true`.

When the `shared-secrets` feature is enabled, the `gitlab-redis-secret` secret object
is automatically created if not provided.

To create this secret manually, see the [Redis password instructions](../../installation/secrets.md#redis-password).

### `authEndpoint`

The `authEndpoint` field is a string, providing the URL to the GitLab instance(s) that
the [registry](https://hub.docker.com/_/registry/) will authenticate to.

The value should include the protocol and hostname only. The chart template will automatically
append the necessary request path. The resulting value will be populated to `auth.token.realm`
inside the container. For example: `authEndpoint: "https://gitlab.example.com"`

By default this field is populated with the GitLab hostname configuration set by the
[Global Settings](../globals.md).

### `certificate`

The `certificate` field is a map containing two items: `secret` and `key`.

`secret` is a string containing the name of the [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/)
that houses the certificate bundle to be used to verify the tokens created by the GitLab instance(s).

`key` is the name of the `key` in the `Secret` which houses the certificate
bundle that will be provided to the [registry](https://hub.docker.com/_/registry/)
container as `auth.token.rootcertbundle`.

Default Example:

```yaml
certificate:
  secret: gitlab-registry
  key: registry-auth.crt
```

### readiness and liveness probe

By default there is a readiness and liveness probe configured to
check `/debug/health` on port `5001` which is the debug port.

### `validation`

The `validation` field is a map that controls the Docker image validation
process in the registry. When image validation is enabled the registry rejects
windows images with foreign layers, unless the `manifests.urls.allow` field
within the validation stanza is explicitly set to allow those layer urls.

Validation only happens during manifest push, so images already present in the
registry are not affected by changes to the values in this section.

The image validation is turned off by default.

To enable image validation you need to explicitly set `registry.validation.disabled: false`.

#### `manifests`

The `manifests` field allows configuration of validation policies particular to
manifests.

The `urls` section contains both `allow` and `deny` fields. For manifest layers
which contain URLs to pass validation, that layer must match one of the regular
expressions in the `allow` field, while not matching any regular expression in
the `deny` field.

|        Name        | Type  | Default | Description |
|:------------------:|:-----:|:--------|:-----------:|
|  `referencelimit`  |  Int  | `0`     | The maximum number of references, such as layers, image configurations, and other manifests, that a single manifest may have. When set to `0` (default) this validation is disabled. |
| `payloadsizelimit` |  Int  | `0`     | The maximum data size in bytes of manifest payloads. When set to `0` (default) this validation is disabled. |
|    `urls.allow`    | Array | `[]`    | List of regular expressions that enables URLs in the layers of manifests. When left empty (default), layers with any URLs will be rejected. |
|    `urls.deny`     | Array | `[]`    | List of regular expressions that restricts the URLs in the layers of manifests. When left empty (default), no layer with URLs which passed the `urls.allow` list will be rejected |

### `notifications`

The `notifications` field is used to configure [Registry notifications](https://distribution.github.io/distribution/about/notifications/#configuration).
It has an empty hash as default value.

|    Name     | Type  | Default | Description |
|:-----------:|:-----:|:--------|:-----------:|
| `endpoints` | Array | `[]`    | List of items where each item correspond to an [endpoint](https://distribution.github.io/distribution/about/configuration/#endpoints) |
|  `events`   | Hash  | `{}`    | Information provided in [event](https://distribution.github.io/distribution/about/configuration/#events) notifications |

An example setting will look like the following:

```yaml
notifications:
  endpoints:
    - name: FooListener
      url: https://foolistener.com/event
      timeout: 500ms
      # DEPRECATED: use `maxretries` instead https://gitlab.com/gitlab-org/container-registry/-/issues/1243.
      # When using `maxretries`, `threshold` is ignored: https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md?ref_type=heads#endpoints
      threshold: 10
      maxretries: 10
      backoff: 1s
    - name: BarListener
      url: https://barlistener.com/event
      timeout: 100ms
      # DEPRECATED: use `maxretries` instead https://gitlab.com/gitlab-org/container-registry/-/issues/1243.
      # When using `maxretries`, `threshold` is ignored: https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md?ref_type=heads#endpoints
      threshold: 3
      maxretries: 5
      backoff: 1s
  events:
    includereferences: true
```

<!-- vale gitlab.Spelling = NO -->

### `hpa`

<!-- vale gitlab.Spelling = YES -->

The `hpa` field is an object, controlling the number of [registry](https://hub.docker.com/_/registry/)
instances to create as a part of the set. This defaults to a `minReplicas` value
of `2`, a `maxReplicas` value of 10, and configures the
`cpu.targetAverageUtilization` to 75%.

### `storage`

```yaml
storage:
  secret:
  key: config
  extraKey:
```

The `storage` field is a reference to a Kubernetes Secret and associated key. The content
of this secret is taken directly from [Registry Configuration: `storage`](https://distribution.github.io/distribution/about/configuration/#storage).
Please refer to that documentation for more details.

Examples for [AWS s3](https://distribution.github.io/distribution/storage-drivers/s3/) and
[Google GCS](https://distribution.github.io/distribution/storage-drivers/gcs/) drivers can be
found in [`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage):

- [`registry.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.s3.yaml)
- [`registry.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.gcs.yaml)

For S3, make sure you give the correct
[permissions for registry storage](https://distribution.github.io/distribution/storage-drivers/s3/#s3-permission-scopes). For more information about storage configuration, see
[Container Registry storage driver](https://docs.gitlab.com/administration/packages/container_registry/#container-registry-storage-driver) in the administration documentation.

Place the _contents_ of the `storage` block into the secret, and provide the following
as items to the `storage` map:

- `secret`: name of the Kubernetes Secret housing the YAML block.
- `key`: name of the key in the secret to use. Defaults to `config`.
- `extraKey`: _(optional)_ name of an extra key in the secret, which will be mounted
  to `/etc/docker/registry/storage/${extraKey}` within the container. This can be
  used to provide the `keyfile` for the `gcs` driver.

```shell
# Example using S3
kubectl create secret generic registry-storage \
    --from-file=config=registry-storage.yaml

# Example using GCS with JSON key
# - Note: `registry.storage.extraKey=gcs.json`
kubectl create secret generic registry-storage \
    --from-file=config=registry-storage.yaml \
    --from-file=gcs.json=example-project-382839-gcs-bucket.json
```

You can [disable the redirect for the storage driver](https://docs.gitlab.com/administration/packages/container_registry/#disable-redirect-for-storage-driver),
ensuring that all traffic flows through the Registry service instead of redirecting to another backend:

```yaml
storage:
  secret: example-secret
  key: config
  redirect:
    disable: true
```

If you chose to use the `filesystem` driver:

- You will need to provide persistent volumes for this data.
- [`hpa.minReplicas`](#hpa) should be set to `1`
- [`hpa.maxReplicas`](#hpa) should be set to `1`

For the sake of resiliency and simplicity, it is recommended to make use of an
external service, such as `s3`, `gcs`, `azure` or other compatible Object Storage.

{{< alert type="note" >}}

The chart will populate `delete.enabled: true` into this configuration
by default if not specified by the user. This keeps expected behavior in line with
the default use of MinIO, as well as the Linux package. Any user provided value
will supersede this default.

{{< /alert >}}

### `middleware.storage`

Configuration of `middleware.storage` follows [upstream convention](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#middleware):

Configuration is fairly generic and follows similar pattern:

```yaml
middleware:
  # See https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#middleware
  storage:
    - name: cloudfront
      options:
        baseurl: https://abcdefghijklmn.cloudfront.net/
        # `privatekey` is auto-populated with the content from the privatekey Secret.
        privatekeySecret:
          secret: cloudfront-secret-name
          # "key" value is going to be used to generate filename for PEM storage:
          #   /etc/docker/registry/middleware.storage/<index>/<key>
          key: private-key-ABC.pem
        keypairid: ABCEDFGHIJKLMNOPQRST
```

Within above code `options.privatekeySecret` is a `generic` Kubernetes secret contents of which corresponds to PEM file contents:

```shell
kubectl create secret generic cloudfront-secret-name --type=kubernetes.io/ssh-auth --from-file=private-key-ABC.pem=pk-ABCEDFGHIJKLMNOPQRST.pem
```

`privatekey` used upstream is being auto-populated by chart from the `privatekey` Secret and will be **ignored** if specified.

#### `keypairid` variants

Various vendors use different field names for the same construct:

|   Vendor   | field name |
|:----------:|:----------:|
| Google CDN | `keyname`  |
| CloudFront | `keypairid` |

{{< alert type="note" >}}

Only configuration of `middleware.storage` section is supported at this time.

{{< /alert >}}

### `debug`

The debug port is enabled by default and is used for the liveness/readiness
probe. Additionally, Prometheus metrics can be enabled via the `metrics` values.

```yaml
debug:
  addr:
    port: 5001

metrics:
  enabled: true
```

### `health`

The `health` property is optional, and contains preferences for
a periodic health check on the storage driver's backend storage.
For more details, see the Docker [configuration documentation](https://distribution.github.io/distribution/about/configuration/#health).

```yaml
health:
  storagedriver:
    enabled: false
    interval: 10s
    threshold: 3
```

### `reporting`

The `reporting` property is optional and enables [reporting](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#reporting)

```yaml
reporting:
  sentry:
    enabled: true
    dsn: 'https://<key>@sentry.io/<project>'
    environment: 'production'
```

### `profiling`

The `profiling` property is optional and enables [continuous profiling](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#profiling)

```yaml
profiling:
  stackdriver:
    enabled: true
    credentials:
      secret: gitlab-registry-profiling-creds
      key: credentials
    service: gitlab-registry
```

### `database`

{{< history >}}

- [Introduced](https://gitlab.com/groups/gitlab-org/-/epics/5521) in GitLab 16.4 as a [beta](https://docs.gitlab.com/policy/development_stages_support/#beta) feature.
- [Generally available](https://gitlab.com/gitlab-org/gitlab/-/issues/423459) in GitLab 17.3.

{{< /history >}}

The `database` property is optional and enables the [metadata database](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#database).

See the [administration documentation](https://docs.gitlab.com/administration/packages/container_registry_metadata_database/)
before enabling this feature.

{{< alert type="note" >}}

This feature requires PostgreSQL 13 or newer.

{{< /alert >}}

```yaml
database:
  enabled: true
  host: registry.db.example.com
  port: 5432
  user: registry
  password:
    secret: gitlab-postgresql-password
    key: postgresql-registry-password
  dbname: registry
  sslmode: verify-full
  ssl:
    secret: gitlab-registry-postgresql-ssl
    clientKey: client-key.pem
    clientCertificate: client-cert.pem
    serverCA: server-ca.pem
  connecttimeout: 5s
  draintimeout: 2m
  preparedstatements: false
  primary: 'primary.record.fqdn'
  pool:
    maxidle: 25
    maxopen: 25
    maxlifetime: 5m
    maxidletime: 5m
  migrations:
    enabled: true
    activeDeadlineSeconds: 3600
    backoffLimit: 6
  backgroundMigrations:
    enabled: true
    maxJobRetries: 3
    jobInterval: 10s
```

#### Load balancing

{{< alert type="warning" >}}

This is an experimental feature under active development and must not be used in production.

{{< /alert >}}

The `loadBalancing` section allows configuring [database load balancing](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#loadbalancing). The corresponding [Redis connection](#redis-for-database-load-balancing) must be enabled for this feature to work.

#### Manage the database

See the [Container registry metadata database](metadata_database.md) page for
more information about creating and maintaining the database.

### `gc` property

The `gc` property provides [online garbage collection](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#gc)
options.

Online garbage collection requires the [metadata database](#database) to be enabled. You must use online garbage collection when using the database, though
you can temporarily disable online garbage collection for maintenance and debugging.

```yaml
gc:
  disabled: false
  maxbackoff: 24h
  noidlebackoff: false
  transactiontimeout: 10s
  reviewafter: 24h
  manifests:
    disabled: false
    interval: 5s
  blobs:
    disabled: false
    interval: 5s
    storagetimeout: 5s
```

### Redis cache

{{< alert type="note" >}}

The Redis cache is a beta feature from version 16.4 and later. Please
review the [feedback issue](https://gitlab.com/gitlab-org/gitlab/-/issues/423459)
and associated documentation before enabling this feature.

{{< /alert >}}

The `redis.cache` property is optional and provides options related to the
[Redis cache](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#cache-1).
To use `redis.cache` with the registry, the [metadata database](#database) must be enabled.

For example:

```yaml
redis:
  cache:
    enabled: true
    host: localhost
    port: 16379
    password:
      secret: gitlab-redis-secret
      key: redis-password
    db: 0
    dialtimeout: 10ms
    readtimeout: 10ms
    writetimeout: 10ms
    tls:
      enabled: true
      insecure: true
    pool:
      size: 10
      maxlifetime: 1h
      idletimeout: 300s
```

#### Cluster

The `redis.rateLimiting.cluster` property is a list of hosts and ports
to connect to a Redis cluster. For example:

```yaml
redis:
  cache:
    enabled: true
    host: redis.example.com
    cluster:
      - host: host1.example.com
        port: 6379
      - host: host2.example.com
        port: 6379
```

#### Sentinels

The `redis.cache` can use the `global.redis.sentinels` configuration. Local values can be provided and
will take precedence over the global values. For example:

```yaml
redis:
  cache:
    enabled: true
    host: redis.example.com
    sentinels:
      - host: sentinel1.example.com
        port: 16379
      - host: sentinel2.example.com
        port: 16379
```

#### Sentinel password support

{{< history >}}

- [Introduced](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3805) in GitLab 17.2.

{{< /history >}}

The `redis.cache` can also use the [`global.redis.sentinelAuth` configuration](../globals.md#redis-sentinel-password-support)
to use an authentication password for Redis Sentinel. Local values can
be provided and take precedence over the global values. For example:

```yaml
redis:
  cache:
    enabled: true
    host: redis.example.com
    sentinels:
      - host: sentinel1.example.com
        port: 16379
      - host: sentinel2.example.com
        port: 16379
    sentinelpassword:
      enabled: true
      secret: registry-redis-sentinel
      key: password
```

### Redis rate-limiter

{{< alert type="warning" >}}

The Redis rate-limiting is [under development](https://gitlab.com/groups/gitlab-org/-/epics/13237).
More functionality details will be added to this section as they become available.

{{< /alert >}}

The `redis.rateLimiting` property is optional and provides options related to the
[Redis rate-limiter](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#ratelimiter).

For example:

```yaml
redis:
  rateLimiting:
    enabled: true
    host: localhost
    port: 16379
    username: registry
    password:
      secret: gitlab-redis-secret
      key: redis-password
    db: 0
    dialtimeout: 10ms
    readtimeout: 10ms
    writetimeout: 10ms
    tls:
      enabled: true
      insecure: true
    pool:
      size: 10
      maxlifetime: 1h
      idletimeout: 300s
```

### Redis for Database Load Balancing

{{< details >}}

Status: Experiment

{{< /details >}}

{{< history >}}

- [Introduced](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/4180) in Charts 8.11.

{{< /history >}}

{{< alert type="warning" >}}

[Database Load Balancing](#load-balancing) is an experimental feature under active development and must not be used in production. Use [epic 8591](https://gitlab.com/groups/gitlab-org/-/epics/8591) to follow progress and share feedback.

{{< /alert >}}

The `redis.loadBalancing` property is optional and provides options related to the
[Redis connection for database load balancing](https://gitlab.com/gitlab-org/container-registry/-/blob/b4d71f24a9ae31288401a3459228aa7f8d3dd8f0/docs/configuration.md#loadbalancing-1).

For example:

```yaml
redis:
  loadBalancing:
    enabled: true
    host: localhost
    port: 16379
    username: registry
    password:
      secret: gitlab-redis-secret
      key: redis-password
    db: 0
    dialtimeout: 10ms
    readtimeout: 10ms
    writetimeout: 10ms
    tls:
      enabled: true
      insecure: true
    pool:
      size: 10
      maxlifetime: 1h
      idletimeout: 300s
```

## Garbage Collection

The Docker Registry will build up extraneous data over time which can be freed using
[garbage collection](https://distribution.github.io/distribution/about/garbage-collection/).
As of [now](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/1586) there is no
fully automated or scheduled way to run the garbage collection with this Chart.

{{< alert type="warning" >}}

You must use [online garbage collection](https://gitlab.com/gitlab-org/container-registry/-/blob/master/docs/configuration.md#gc) with the
[metadata database](#database). Using manual garbage collection with the metadata database will lead to data loss.
Online garbage collection fully replaces the need to manually run garbage collection.

{{< /alert >}}

### Manual Garbage Collection

Manual garbage collection requires the registry to be in read-only mode first. Let's assume that you've already
installed the GitLab chart by using Helm, named it `mygitlab`, and installed it in the namespace `gitlabns`.
Replace these values in the commands below according to your actual configuration.

```shell
# Because of https://github.com/helm/helm/issues/2948 we can't rely on --reuse-values, so let's get our current config.
helm get values mygitlab > mygitlab.yml
# Upgrade Helm installation and configure the registry to be read-only.
# The --wait parameter makes Helm wait until all ressources are in ready state, so we are safe to continue.
helm upgrade mygitlab gitlab/gitlab -f mygitlab.yml --set registry.maintenance.readonly.enabled=true --wait
# Our registry is in r/o mode now, so let's get the name of one of the registry Pods.
# Note down the Pod name and replace the '<registry-pod>' placeholder below with that value.
# Replace the single quotes to double quotes (' => ") if you are using this with Windows' cmd.exe.
kubectl get pods -n gitlabns -l app=registry -o jsonpath='{.items[0].metadata.name}'
# Run the actual garbage collection. Check the registry's manual if you really want the '-m' parameter.
kubectl exec -n gitlabns <registry-pod> -- /bin/registry garbage-collect -m /etc/docker/registry/config.yml
# Reset registry back to original state.
helm upgrade mygitlab gitlab/gitlab -f mygitlab.yml --wait
# All done :)
```

### Running administrative commands against the Container Registry

The administrative commands can be run against the Container Registry
only from a Registry pod, where both the `registry` binary as well as necessary
configuration is available. [Issue #2629](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2629)
is open to discuss how to provide this functionality from the toolbox pod.

To run administrative commands:

1. Connect to a Registry pod:

   ```shell
   kubectl exec -it <registry-pod> -- bash
   ```

1. Once inside the Registry pod, the `registry` binary is available in `PATH` and
   can be used directly. The configuration file is available at
   `/etc/docker/registry/config.yml`. The following example checks the status
   of the database migration:

   ```shell
   registry database migrate status /etc/docker/registry/config.yml
   ```

For further details and other available commands, refer to the relevant
documentation:

- [General Registry documentation](https://docs.docker.com/registry/)
- [GitLab-specific Registry documentation](https://gitlab.com/gitlab-org/container-registry/-/tree/master/docs-gitlab)

## Registry Rate Limiter Configuration

The Registry can be configured with rate limiting to control the traffic to your container registry instance. This helps protect your registry from abuse, DoS attacks, or excessive usage.

### Notes

- Rate limiting requires Redis to be configured properly via the `registry.redis.rateLimiting` settings.
- Rate limiting is disabled by default. Set `registry.rateLimiter.enabled: true` to enable it.
- Limiters are applied in order of precedence (lowest values first).
- The `log_only` option can be useful for testing rate limits before enforcing them.

### Rate Limiter Configuration

To enable and configure rate limiting for the container registry, you can use the `registry.rateLimiter` settings:

```yaml
registry:
  rateLimiter:
    enabled: true
    limiters:
      - name: global_rate_limit
        description: "Global IP rate limit"
        log_only: false
        match:
          type: IP
        precedence: 10
        limit:
          rate: 5000
          period: "minute"
          burst: 8000
        action:
          warn_threshold: 0.7
          warn_action: "log"
          hard_action: "block"
```

### Limiters Configuration

The rate limiter uses a list of limiters to define rate limiting rules. Each limiter has the following properties:

- `name`: A unique identifier for the limiter
- `description`: A human-readable description of the limiter's purpose
- `log_only`: When set to `true`, violations are only logged without enforcement
- `precedence`: Defines the order in which limiters are evaluated (lower values first)
- `match`: Criteria for matching requests
- `limit`: The rate limit parameters
- `action`: Actions to take when limits are reached

### Limit Configuration

The `limit` section defines the actual rate limit parameters:

```yaml
limit:
  rate: 100       # Number of requests allowed
  period: "minute" # Time period (second, minute, hour, day)
  burst: 200      # Allowed burst capacity
```

### Action Configuration

The `action` section defines what happens when limits are approached or reached:

```yaml
action:
  warn_threshold: 0.7      # Percentage of limit to trigger warning
  warn_action: "log"       # Action when warning threshold is reached
  hard_action: "block"     # Action when limit is reached
```

### Examples

#### Global IP Rate Limit

This example limits all requests from a single IP address:

```yaml
- name: global_rate_limit
  description: "Global IP rate limit"
  log_only: false
  match:
    type: IP
  precedence: 10
  limit:
    rate: 5000
    period: "minute"
    burst: 8000
  action:
    warn_threshold: 0.7
    warn_action: "log"
    hard_action: "block"
```
