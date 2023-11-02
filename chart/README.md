# gitlab-exporter

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: 13.2.0](https://img.shields.io/badge/AppVersion-13.2.0-informational?style=flat-square)

Exporter for GitLab Prometheus metrics (e.g. CI, pull mirrors)

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/gitlab-exporter>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-exporter>
* <https://gitlab.com/gitlab-org/gitlab-exporter>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install gitlab-exporter chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter"` |  |
| service.name | string | `"gitlab-exporter"` |  |
| service.type | string | `"ClusterIP"` |  |
| service.externalPort | int | `9168` |  |
| service.internalPort | int | `9168` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `9168` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| metrics.annotations | object | `{}` |  |
| enabled | bool | `true` |  |
| tls.enabled | bool | `false` |  |
| tolerations | list | `[]` |  |
| annotations | object | `{}` |  |
| priorityClassName | string | `""` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| redis.auth | object | `{}` |  |
| psql | object | `{}` |  |
| resources.requests.cpu | string | `"75m"` |  |
| resources.requests.memory | string | `"100M"` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| extraEnv.MALLOC_CONF | string | `"dirty_decay_ms:0,muzzy_decay_ms:0"` |  |
| extraEnv.RUBY_GC_HEAP_INIT_SLOTS | int | `80000` |  |
| extraEnv.RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO | float | `0.055` |  |
| extraEnv.RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO | float | `0.111` |  |
| deployment.strategy | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# migrations

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: v16.4.1](https://img.shields.io/badge/AppVersion-v16.4.1-informational?style=flat-square)

Database migrations and other versioning tasks for upgrading Gitlab

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/migrations>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-rails>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install migrations chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| annotations | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| priorityClassName | string | `""` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| enabled | bool | `true` |  |
| initialRootPassword | object | `{}` |  |
| redis.auth | object | `{}` |  |
| gitaly.authToken | object | `{}` |  |
| psql | object | `{}` |  |
| global.psql | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.memory | string | `"200Mi"` |  |
| activeDeadlineSeconds | int | `3600` |  |
| backoffLimit | int | `6` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# praefect

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: 16.4.1](https://img.shields.io/badge/AppVersion-16.4.1-informational?style=flat-square)

Praefect is a router and transaction manager for Gitaly, and a required component for running a Gitaly Cluster.

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/praefect>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitaly>
* <https://gitlab.com/gitlab-org/gitaly/-/tree/master/cmd/praefect>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install praefect chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| failover.enabled | bool | `true` |  |
| failover.readonlyAfter | bool | `true` |  |
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitaly"` |  |
| service.tls | object | `{}` |  |
| init.resources | object | `{}` |  |
| init.image | object | `{}` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `9236` |  |
| metrics.separate_database_metrics | bool | `true` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| replicas | int | `2` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"200Mi"` |  |
| maxUnavailable | int | `1` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| tolerations | list | `[]` |  |
| gitaly.service.tls | object | `{}` |  |
| common.labels | object | `{}` |  |
| podLabels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| statefulset.strategy | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# sidekiq

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: v16.4.1](https://img.shields.io/badge/AppVersion-v16.4.1-informational?style=flat-square)

Gitlab Sidekiq for asynchronous task processing in rails

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/sidekiq>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-sidekiq>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install sidekiq chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| enabled | bool | `true` |  |
| queueSelector | bool | `false` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| logging.format | string | `"json"` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `3807` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.log_enabled | bool | `false` |  |
| metrics.podMonitor.enabled | bool | `false` |  |
| metrics.podMonitor.additionalLabels | object | `{}` |  |
| metrics.podMonitor.endpointConfig | object | `{}` |  |
| metrics.annotations | object | `{}` |  |
| metrics.tls.enabled | bool | `false` |  |
| health_checks.port | int | `3808` |  |
| redis.auth | object | `{}` |  |
| psql | object | `{}` |  |
| memoryKiller.daemonMode | bool | `true` |  |
| memoryKiller.maxRss | int | `2000000` |  |
| memoryKiller.graceTime | int | `900` |  |
| memoryKiller.shutdownWait | int | `30` |  |
| memoryKiller.checkInterval | int | `3` |  |
| livenessProbe.initialDelaySeconds | int | `20` |  |
| livenessProbe.periodSeconds | int | `60` |  |
| livenessProbe.timeoutSeconds | int | `30` |  |
| livenessProbe.successThreshold | int | `1` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| readinessProbe.initialDelaySeconds | int | `0` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.timeoutSeconds | int | `2` |  |
| readinessProbe.successThreshold | int | `1` |  |
| readinessProbe.failureThreshold | int | `3` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.gitlab | object | `{}` |  |
| global.hosts.registry | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| global.psql | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| global.webservice | object | `{}` |  |
| global.minio.enabled | string | `nil` |  |
| global.minio.credentials | object | `{}` |  |
| global.appConfig.microsoft_graph_mailer.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.address | string | `nil` |  |
| global.appConfig.serviceDeskEmail.enabled | bool | `false` |  |
| global.appConfig.serviceDeskEmail.address | string | `nil` |  |
| global.appConfig.lfs.enabled | bool | `true` |  |
| global.appConfig.lfs.proxy_download | bool | `true` |  |
| global.appConfig.lfs.bucket | string | `nil` |  |
| global.appConfig.lfs.connection | object | `{}` |  |
| global.appConfig.artifacts.enabled | bool | `true` |  |
| global.appConfig.artifacts.proxy_download | bool | `true` |  |
| global.appConfig.artifacts.bucket | string | `nil` |  |
| global.appConfig.artifacts.connection | object | `{}` |  |
| global.appConfig.uploads.enabled | bool | `true` |  |
| global.appConfig.uploads.proxy_download | bool | `true` |  |
| global.appConfig.uploads.bucket | string | `nil` |  |
| global.appConfig.uploads.connection | object | `{}` |  |
| global.appConfig.packages.enabled | bool | `true` |  |
| global.appConfig.packages.proxy_download | bool | `true` |  |
| global.appConfig.packages.bucket | string | `nil` |  |
| global.appConfig.packages.connection | object | `{}` |  |
| global.appConfig.externalDiffs.when | string | `nil` |  |
| global.appConfig.externalDiffs.proxy_download | bool | `true` |  |
| global.appConfig.externalDiffs.bucket | string | `nil` |  |
| global.appConfig.externalDiffs.connection | object | `{}` |  |
| global.appConfig.terraformState.enabled | bool | `false` |  |
| global.appConfig.terraformState.bucket | string | `nil` |  |
| global.appConfig.terraformState.connection | object | `{}` |  |
| global.appConfig.dependencyProxy.enabled | bool | `false` |  |
| global.appConfig.dependencyProxy.proxy_download | bool | `true` |  |
| global.appConfig.dependencyProxy.bucket | string | `nil` |  |
| global.appConfig.dependencyProxy.connection | object | `{}` |  |
| global.appConfig.ldap.servers | object | `{}` |  |
| global.appConfig.omniauth.enabled | bool | `false` |  |
| global.appConfig.omniauth.autoSignInWithProvider | string | `nil` |  |
| global.appConfig.omniauth.syncProfileFromProvider | list | `[]` |  |
| global.appConfig.omniauth.syncProfileAttributes[0] | string | `"email"` |  |
| global.appConfig.omniauth.allowSingleSignOn[0] | string | `"saml"` |  |
| global.appConfig.omniauth.blockAutoCreatedUsers | bool | `true` |  |
| global.appConfig.omniauth.autoLinkLdapUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkSamlUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkUser | list | `[]` |  |
| global.appConfig.omniauth.externalProviders | list | `[]` |  |
| global.appConfig.omniauth.allowBypassTwoFactor | list | `[]` |  |
| global.appConfig.omniauth.providers | list | `[]` |  |
| global.appConfig.sentry.enabled | bool | `false` |  |
| global.appConfig.sentry.dsn | string | `nil` |  |
| global.appConfig.sentry.clientside_dsn | string | `nil` |  |
| global.appConfig.sentry.environment | string | `nil` |  |
| gitaly.authToken | object | `{}` |  |
| minio.serviceName | string | `"minio-svc"` |  |
| minio.port | int | `9000` |  |
| extra | object | `{}` |  |
| extraEnv | object | `{}` |  |
| rack_attack.git_basic_auth.enabled | bool | `false` |  |
| trusted_proxies | list | `[]` |  |
| minReplicas | int | `1` |  |
| maxReplicas | int | `10` |  |
| concurrency | int | `20` |  |
| deployment.strategy | object | `{}` |  |
| deployment.terminationGracePeriodSeconds | int | `30` |  |
| hpa.cpu.targetType | string | `"AverageValue"` |  |
| hpa.cpu.targetAverageValue | string | `"350m"` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| timeout | int | `25` |  |
| resources.requests.cpu | string | `"900m"` |  |
| resources.requests.memory | string | `"2G"` |  |
| maxUnavailable | int | `1` |  |
| pods[0].name | string | `"all-in-1"` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| priorityClassName | string | `""` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# toolbox

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: v16.4.1](https://img.shields.io/badge/AppVersion-v16.4.1-informational?style=flat-square)

For manually running rake tasks through kubectl

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/toolbox>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-toolbox>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install toolbox chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| extraEnv | object | `{}` |  |
| antiAffinityLabels.matchLabels | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |
| common.labels | object | `{}` |  |
| enabled | bool | `true` |  |
| replicas | int | `1` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| priorityClassName | string | `""` |  |
| psql | object | `{}` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.gitlab | object | `{}` |  |
| global.hosts.registry | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| global.psql.password | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| global.minio.enabled | string | `nil` |  |
| global.minio.credentials | object | `{}` |  |
| global.webservice | object | `{}` |  |
| global.appConfig.lfs.enabled | bool | `true` |  |
| global.appConfig.lfs.proxy_download | bool | `true` |  |
| global.appConfig.lfs.bucket | string | `nil` |  |
| global.appConfig.lfs.connection | object | `{}` |  |
| global.appConfig.artifacts.enabled | bool | `true` |  |
| global.appConfig.artifacts.proxy_download | bool | `true` |  |
| global.appConfig.artifacts.bucket | string | `nil` |  |
| global.appConfig.artifacts.connection | object | `{}` |  |
| global.appConfig.uploads.enabled | bool | `true` |  |
| global.appConfig.uploads.proxy_download | bool | `true` |  |
| global.appConfig.uploads.bucket | string | `nil` |  |
| global.appConfig.uploads.connection | object | `{}` |  |
| global.appConfig.packages.enabled | bool | `true` |  |
| global.appConfig.packages.proxy_download | bool | `true` |  |
| global.appConfig.packages.bucket | string | `nil` |  |
| global.appConfig.packages.connection | object | `{}` |  |
| global.appConfig.externalDiffs.when | string | `nil` |  |
| global.appConfig.externalDiffs.proxy_download | bool | `true` |  |
| global.appConfig.externalDiffs.bucket | string | `nil` |  |
| global.appConfig.externalDiffs.connection | object | `{}` |  |
| global.appConfig.terraformState.enabled | bool | `false` |  |
| global.appConfig.terraformState.bucket | string | `nil` |  |
| global.appConfig.terraformState.connection | object | `{}` |  |
| global.appConfig.dependencyProxy.enabled | bool | `false` |  |
| global.appConfig.dependencyProxy.proxy_download | bool | `true` |  |
| global.appConfig.dependencyProxy.bucket | string | `nil` |  |
| global.appConfig.dependencyProxy.connection | object | `{}` |  |
| global.appConfig.ldap.servers | object | `{}` |  |
| global.appConfig.omniauth.enabled | bool | `false` |  |
| global.appConfig.omniauth.autoSignInWithProvider | string | `nil` |  |
| global.appConfig.omniauth.syncProfileFromProvider | list | `[]` |  |
| global.appConfig.omniauth.syncProfileAttributes[0] | string | `"email"` |  |
| global.appConfig.omniauth.allowSingleSignOn[0] | string | `"saml"` |  |
| global.appConfig.omniauth.blockAutoCreatedUsers | bool | `true` |  |
| global.appConfig.omniauth.autoLinkLdapUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkSamlUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkUser | list | `[]` |  |
| global.appConfig.omniauth.externalProviders | list | `[]` |  |
| global.appConfig.omniauth.allowBypassTwoFactor | list | `[]` |  |
| global.appConfig.omniauth.providers | list | `[]` |  |
| backups.cron.enabled | bool | `false` |  |
| backups.cron.concurrencyPolicy | string | `"Replace"` |  |
| backups.cron.failedJobsHistoryLimit | int | `1` |  |
| backups.cron.schedule | string | `"0 1 * * *"` |  |
| backups.cron.startingDeadlineSeconds | string | `nil` |  |
| backups.cron.successfulJobsHistoryLimit | int | `3` |  |
| backups.cron.suspend | bool | `false` |  |
| backups.cron.backoffLimit | int | `6` |  |
| backups.cron.safeToEvict | bool | `false` |  |
| backups.cron.restartPolicy | string | `"OnFailure"` |  |
| backups.cron.extraArgs | string | `""` |  |
| backups.cron.resources.requests.cpu | string | `"50m"` |  |
| backups.cron.resources.requests.memory | string | `"350M"` |  |
| backups.cron.persistence.enabled | bool | `false` |  |
| backups.cron.persistence.useGenericEphemeralVolume | bool | `false` |  |
| backups.cron.persistence.accessMode | string | `"ReadWriteOnce"` |  |
| backups.cron.persistence.size | string | `"10Gi"` |  |
| backups.cron.persistence.subPath | string | `""` |  |
| backups.cron.persistence.matchLabels | object | `{}` |  |
| backups.cron.persistence.matchExpressions | list | `[]` |  |
| backups.objectStorage.backend | string | `"s3"` |  |
| backups.objectStorage.config | object | `{}` |  |
| extra | object | `{}` |  |
| rack_attack.git_basic_auth.enabled | bool | `false` |  |
| trusted_proxies | list | `[]` |  |
| redis.auth | object | `{}` |  |
| gitaly.authToken | object | `{}` |  |
| minio.bucket | string | `"git-lfs"` |  |
| minio.serviceName | string | `"minio-svc"` |  |
| minio.port | int | `9000` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"350M"` |  |
| persistence.enabled | bool | `false` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.size | string | `"10Gi"` |  |
| persistence.subPath | string | `""` |  |
| persistence.matchLabels | object | `{}` |  |
| persistence.matchExpressions | list | `[]` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| deployment.strategy.type | string | `"Recreate"` |  |
| deployment.strategy.rollingUpdate | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# registry

![Version: 0.7.0](https://img.shields.io/badge/Version-0.7.0-informational?style=flat-square) ![AppVersion: v3.83.0-gitlab](https://img.shields.io/badge/AppVersion-v3.83.0--gitlab-informational?style=flat-square)

Stateless, highly scalable application that stores and lets you distribute container images

## Upstream References
* <https://docs.gitlab.com/ee/user/packages/container_registry>

* <https://gitlab.com/gitlab-org/container-registry>
* <https://gitlab.com/gitlab-org/charts/gitlab/charts/registry>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install registry chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-container-registry"` |  |
| image.tag | string | `"v3.83.0-gitlab"` |  |
| deployment.terminationGracePeriodSeconds | int | `30` |  |
| deployment.readinessProbe.enabled | bool | `true` |  |
| deployment.readinessProbe.path | string | `"/debug/health"` |  |
| deployment.readinessProbe.port | string | `nil` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `5` |  |
| deployment.readinessProbe.periodSeconds | int | `5` |  |
| deployment.readinessProbe.timeoutSeconds | int | `1` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.enabled | bool | `true` |  |
| deployment.livenessProbe.path | string | `"/debug/health"` |  |
| deployment.livenessProbe.port | string | `nil` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `5` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.timeoutSeconds | int | `1` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.strategy | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| service.name | string | `"registry"` |  |
| service.type | string | `"ClusterIP"` |  |
| service.externalPort | int | `5000` |  |
| service.internalPort | int | `5000` |  |
| service.clusterIP | string | `nil` |  |
| service.loadBalancerIP | string | `nil` |  |
| tolerations | list | `[]` |  |
| priorityClassName | string | `""` |  |
| enabled | bool | `true` |  |
| maintenance.readonly.enabled | bool | `false` |  |
| maintenance.uploadpurging.enabled | bool | `true` |  |
| maintenance.uploadpurging.age | string | `"168h"` |  |
| maintenance.uploadpurging.interval | string | `"24h"` |  |
| maintenance.uploadpurging.dryrun | bool | `false` |  |
| annotations | object | `{}` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| ingress.apiVersion | string | `nil` |  |
| ingress.enabled | string | `nil` |  |
| ingress.proxyReadTimeout | int | `900` |  |
| ingress.proxyBodySize | string | `"0"` |  |
| ingress.proxyBuffering | string | `"off"` |  |
| ingress.tls | object | `{}` |  |
| ingress.annotations | object | `{}` |  |
| ingress.configureCertmanager | string | `nil` |  |
| ingress.path | string | `nil` |  |
| global.ingress.enabled | string | `nil` |  |
| global.ingress.annotations | object | `{}` |  |
| global.ingress.tls | object | `{}` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.tls | object | `{}` |  |
| global.hosts.gitlab | object | `{}` |  |
| global.hosts.registry | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| global.minio.enabled | string | `nil` |  |
| global.minio.credentials | object | `{}` |  |
| global.registry.certificate | object | `{}` |  |
| global.registry.httpSecret | object | `{}` |  |
| global.psql.ssl | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| init.script | string | `"if [ -e /config/accesskey ] ; then\n  sed -e 's@ACCESS_KEY@'\"$(cat /config/accesskey)\"'@' -e 's@SECRET_KEY@'\"$(cat /config/secretkey)\"'@' /config/config.yml > /registry/config.yml\nelse\n  cp -v -r -L /config/config.yml  /registry/config.yml\nfi\n# Place the `http.secret` value from the kubernetes secret\nsed -i -e 's@HTTP_SECRET@'\"$(cat /config/httpSecret)\"'@' /registry/config.yml\n# Populate sensitive registry notification secrets in the config file\nif [ -d /config/notifications ]; then\n  for i in /config/notifications/*; do\n    filename=$(basename $i);\n    sed -i -e 's@'\"${filename}\"'@'\"$(cat $i)\"'@' /registry/config.yml;\n  done\nfi\n# Insert any provided `storage` block from kubernetes secret\nif [ -d /config/storage ]; then\n  # Copy contents of storage secret(s)\n  mkdir -p /registry/storage\n  cp -v -r -L /config/storage/* /registry/storage/\n  # Ensure there is a new line in the end\n  echo '' >> /registry/storage/config\n  # Default `delete.enabled: true` if not present.\n  ## Note: busybox grep doesn't support multiline, so we chain `egrep`.\n  if ! $(egrep -A1 '^delete:\\s*$' /registry/storage/config \| egrep -q '\\s{2,4}enabled:') ; then\n    echo 'delete:' >> /registry/storage/config\n    echo '  enabled: true' >> /registry/storage/config\n  fi\n  # Indent /registry/storage/config 2 spaces before inserting into config.yml\n  sed -i 's/^/  /' /registry/storage/config\n  # Insert into /registry/config.yml after `storage:`\n  sed -i '/^storage:/ r /registry/storage/config' /registry/config.yml\n  # Remove the now extraneous `config` file\n  rm /registry/storage/config\nfi\n# Copy any middleware.storage if present\nif [ -d /config/middleware.storage ]; then\n  cp -v -r -L /config/middleware.storage  /registry/middleware.storage\nfi\n# Set to known path, to used ConfigMap\ncat /config/certificate.crt > /registry/certificate.crt\n# Copy the optional profiling keyfile to the expected location\nif [ -f /config/profiling-key.json ]; then\n  cp /config/profiling-key.json /registry/profiling-key.json\nfi\n# Insert Database password, if enabled\nif [ -f /config/database_password ] ; then\n  sed -i -e 's@DB_PASSWORD_FILE@'\"$(cat /config/database_password)\"'@' /registry/config.yml\nfi\n# Insert Redis password, if enabled\nif [ -f /config/registry/redis-password ] ; then\n  sed -i -e 's@REDIS_CACHE_PASSWORD@'\"$(cat /config/registry/redis-password)\"'@' /registry/config.yml\nfi\n# Copy the database TLS connection files to the expected location and set permissions\nif [ -d /config/ssl ]; then\n  cp -r /config/ssl/ /registry/ssl\n  chmod 700 /registry/ssl\n  chmod 600 /registry/ssl/*.pem\nfi\n# Copy TLS certificates if present\nif [ -d /config/tls ]; then\n  cp -r /config/tls/ /registry/tls\n  chmod 700 /registry/tls\n  chmod 600 /registry/tls/*\nfi"` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| nodeSelector | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |
| authEndpoint | string | `nil` |  |
| tokenService | string | `"container_registry"` |  |
| authAutoRedirect | bool | `false` |  |
| maxUnavailable | int | `1` |  |
| hpa.minReplicas | int | `2` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.cpu.targetType | string | `"Utilization"` |  |
| hpa.cpu.targetAverageUtilization | int | `75` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| storage | object | `{}` |  |
| middleware.storage | list | `[]` |  |
| minio.redirect | bool | `false` |  |
| validation.disabled | bool | `true` |  |
| validation.manifests.referencelimit | int | `0` |  |
| validation.manifests.payloadsizelimit | int | `0` |  |
| validation.manifests.urls.allow | list | `[]` |  |
| validation.manifests.urls.deny | list | `[]` |  |
| log.level | string | `"info"` |  |
| log.fields.service | string | `"registry"` |  |
| debug.addr.port | int | `5001` |  |
| debug.tls.enabled | bool | `false` |  |
| debug.tls.secretName | string | `nil` |  |
| debug.tls.clientCAs | list | `[]` |  |
| debug.tls.minimumTLS | string | `"tls1.2"` |  |
| debug.prometheus.enabled | bool | `false` |  |
| debug.prometheus.path | string | `nil` |  |
| metrics.enabled | bool | `false` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| draintimeout | string | `"0"` |  |
| relativeurls | bool | `false` |  |
| health.storagedriver.enabled | bool | `false` |  |
| health.storagedriver.interval | string | `"10s"` |  |
| health.storagedriver.threshold | int | `3` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| reporting.sentry.enabled | bool | `false` |  |
| profiling.stackdriver.enabled | bool | `false` |  |
| profiling.stackdriver.credentials | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| database.enabled | bool | `false` |  |
| database.user | string | `"registry"` |  |
| database.password | object | `{}` |  |
| database.name | string | `"registry"` |  |
| database.sslmode | string | `"disable"` |  |
| database.ssl | object | `{}` |  |
| database.migrations.enabled | bool | `true` |  |
| database.migrations.activeDeadlineSeconds | int | `3600` |  |
| database.migrations.backoffLimit | int | `6` |  |
| database.discovery.enabled | bool | `false` |  |
| redis.cache.enabled | bool | `false` |  |
| redis.cache.password.enabled | bool | `false` |  |
| gc.disabled | bool | `false` |  |
| tls.enabled | bool | `false` |  |
| tls.secretName | string | `nil` |  |
| tls.clientCAs | list | `[]` |  |
| tls.minimumTLS | string | `"tls1.2"` |  |
| tls.verify | bool | `true` |  |
| tls.caSecretName | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab

![Version: 7.4.1-bb.0](https://img.shields.io/badge/Version-7.4.1--bb.0-informational?style=flat-square) ![AppVersion: 16.4.1](https://img.shields.io/badge/AppVersion-16.4.1-informational?style=flat-square)

GitLab is the most comprehensive AI-powered DevSecOps Platform.

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install gitlab chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.istio.enabled | bool | `false` |  |
| global.istio.injection | string | `"disabled"` |  |
| global.common.labels | object | `{}` |  |
| global.image | object | `{}` |  |
| global.pod.labels | object | `{}` |  |
| global.edition | string | `"ee"` |  |
| global.gitlabVersion | string | `"16.4.1"` |  |
| global.application.create | bool | `false` |  |
| global.application.links | list | `[]` |  |
| global.application.allowClusterRoles | bool | `true` |  |
| global.hosts.domain | string | `"bigbang.dev"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.externalIP | string | `nil` |  |
| global.hosts.ssh | string | `nil` |  |
| global.hosts.gitlab.name | string | `"gitlab.bigbang.dev"` |  |
| global.hosts.minio | object | `{}` |  |
| global.hosts.registry.name | string | `"registry.bigbang.dev"` |  |
| global.hosts.tls | object | `{}` |  |
| global.hosts.smartcard | object | `{}` |  |
| global.hosts.kas | object | `{}` |  |
| global.hosts.pages | object | `{}` |  |
| global.ingress.apiVersion | string | `""` |  |
| global.ingress.configureCertmanager | bool | `false` |  |
| global.ingress.provider | string | `"nginx"` |  |
| global.ingress.annotations | object | `{}` |  |
| global.ingress.enabled | bool | `false` |  |
| global.ingress.tls | object | `{}` |  |
| global.ingress.path | string | `"/"` |  |
| global.ingress.pathType | string | `"Prefix"` |  |
| global.hpa.apiVersion | string | `"autoscaling/v2"` |  |
| global.keda.enabled | bool | `false` |  |
| global.pdb.apiVersion | string | `"policy/v1"` |  |
| global.batch.cronJob.apiVersion | string | `"batch/v1"` |  |
| global.gitlab.license | object | `{}` |  |
| global.initialRootPassword | object | `{}` |  |
| global.psql.connectTimeout | string | `nil` |  |
| global.psql.keepalives | string | `nil` |  |
| global.psql.keepalivesIdle | string | `nil` |  |
| global.psql.keepalivesInterval | string | `nil` |  |
| global.psql.keepalivesCount | string | `nil` |  |
| global.psql.tcpUserTimeout | string | `nil` |  |
| global.psql.password | object | `{}` |  |
| global.redis.auth.enabled | bool | `true` |  |
| global.redis.securityContext.runAsUser | int | `1001` |  |
| global.redis.securityContext.fsGroup | int | `1001` |  |
| global.redis.securityContext.runAsNonRoot | bool | `true` |  |
| global.redis.containerSecurityContext.enabled | bool | `true` |  |
| global.redis.containerSecurityContext.runAsUser | int | `1001` |  |
| global.redis.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| global.redis.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| global.gitaly.enabled | bool | `true` |  |
| global.gitaly.authToken | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.service.name | string | `"gitaly"` |  |
| global.gitaly.service.type | string | `"ClusterIP"` |  |
| global.gitaly.service.externalPort | int | `8075` |  |
| global.gitaly.service.internalPort | int | `8075` |  |
| global.gitaly.service.tls.externalPort | int | `8076` |  |
| global.gitaly.service.tls.internalPort | int | `8076` |  |
| global.gitaly.tls.enabled | bool | `false` |  |
| global.praefect.enabled | bool | `false` |  |
| global.praefect.ntpHost | string | `"pool.ntp.org"` |  |
| global.praefect.replaceInternalGitaly | bool | `true` |  |
| global.praefect.authToken | object | `{}` |  |
| global.praefect.autoMigrate | bool | `true` |  |
| global.praefect.dbSecret | object | `{}` |  |
| global.praefect.virtualStorages[0].name | string | `"default"` |  |
| global.praefect.virtualStorages[0].gitalyReplicas | int | `3` |  |
| global.praefect.virtualStorages[0].maxUnavailable | int | `1` |  |
| global.praefect.psql.sslMode | string | `"disable"` |  |
| global.praefect.service.name | string | `"praefect"` |  |
| global.praefect.service.type | string | `"ClusterIP"` |  |
| global.praefect.service.externalPort | int | `8075` |  |
| global.praefect.service.internalPort | int | `8075` |  |
| global.praefect.service.tls.externalPort | int | `8076` |  |
| global.praefect.service.tls.internalPort | int | `8076` |  |
| global.praefect.tls.enabled | bool | `false` |  |
| global.minio.enabled | bool | `true` |  |
| global.minio.credentials | object | `{}` |  |
| global.appConfig.enableUsagePing | bool | `true` |  |
| global.appConfig.enableSeatLink | bool | `true` |  |
| global.appConfig.enableImpersonation | string | `nil` |  |
| global.appConfig.applicationSettingsCacheSeconds | int | `60` |  |
| global.appConfig.defaultCanCreateGroup | bool | `false` |  |
| global.appConfig.usernameChangingEnabled | bool | `true` |  |
| global.appConfig.issueClosingPattern | string | `nil` |  |
| global.appConfig.defaultTheme | string | `nil` |  |
| global.appConfig.defaultProjectsFeatures.issues | bool | `true` |  |
| global.appConfig.defaultProjectsFeatures.mergeRequests | bool | `true` |  |
| global.appConfig.defaultProjectsFeatures.wiki | bool | `true` |  |
| global.appConfig.defaultProjectsFeatures.snippets | bool | `true` |  |
| global.appConfig.defaultProjectsFeatures.builds | bool | `true` |  |
| global.appConfig.graphQlTimeout | string | `nil` |  |
| global.appConfig.webhookTimeout | string | `nil` |  |
| global.appConfig.maxRequestDurationSeconds | string | `nil` |  |
| global.appConfig.cron_jobs | object | `{}` |  |
| global.appConfig.contentSecurityPolicy.enabled | bool | `false` |  |
| global.appConfig.contentSecurityPolicy.report_only | bool | `true` |  |
| global.appConfig.gravatar.plainUrl | string | `nil` |  |
| global.appConfig.gravatar.sslUrl | string | `nil` |  |
| global.appConfig.extra.googleAnalyticsId | string | `nil` |  |
| global.appConfig.extra.matomoUrl | string | `nil` |  |
| global.appConfig.extra.matomoSiteId | string | `nil` |  |
| global.appConfig.extra.matomoDisableCookies | string | `nil` |  |
| global.appConfig.extra.oneTrustId | string | `nil` |  |
| global.appConfig.extra.googleTagManagerNonceId | string | `nil` |  |
| global.appConfig.extra.bizible | string | `nil` |  |
| global.appConfig.object_store.enabled | bool | `false` |  |
| global.appConfig.object_store.proxy_download | bool | `true` |  |
| global.appConfig.object_store.storage_options | object | `{}` |  |
| global.appConfig.object_store.connection | object | `{}` |  |
| global.appConfig.lfs.enabled | bool | `true` |  |
| global.appConfig.lfs.proxy_download | bool | `true` |  |
| global.appConfig.lfs.bucket | string | `"git-lfs"` |  |
| global.appConfig.lfs.connection | object | `{}` |  |
| global.appConfig.artifacts.enabled | bool | `true` |  |
| global.appConfig.artifacts.proxy_download | bool | `true` |  |
| global.appConfig.artifacts.bucket | string | `"gitlab-artifacts"` |  |
| global.appConfig.artifacts.connection | object | `{}` |  |
| global.appConfig.uploads.enabled | bool | `true` |  |
| global.appConfig.uploads.proxy_download | bool | `true` |  |
| global.appConfig.uploads.bucket | string | `"gitlab-uploads"` |  |
| global.appConfig.uploads.connection | object | `{}` |  |
| global.appConfig.packages.enabled | bool | `true` |  |
| global.appConfig.packages.proxy_download | bool | `true` |  |
| global.appConfig.packages.bucket | string | `"gitlab-packages"` |  |
| global.appConfig.packages.connection | object | `{}` |  |
| global.appConfig.externalDiffs.enabled | bool | `false` |  |
| global.appConfig.externalDiffs.when | string | `nil` |  |
| global.appConfig.externalDiffs.proxy_download | bool | `true` |  |
| global.appConfig.externalDiffs.bucket | string | `"gitlab-mr-diffs"` |  |
| global.appConfig.externalDiffs.connection | object | `{}` |  |
| global.appConfig.terraformState.enabled | bool | `false` |  |
| global.appConfig.terraformState.bucket | string | `"gitlab-terraform-state"` |  |
| global.appConfig.terraformState.connection | object | `{}` |  |
| global.appConfig.ciSecureFiles.enabled | bool | `false` |  |
| global.appConfig.ciSecureFiles.bucket | string | `"gitlab-ci-secure-files"` |  |
| global.appConfig.ciSecureFiles.connection | object | `{}` |  |
| global.appConfig.dependencyProxy.enabled | bool | `false` |  |
| global.appConfig.dependencyProxy.proxy_download | bool | `true` |  |
| global.appConfig.dependencyProxy.bucket | string | `"gitlab-dependency-proxy"` |  |
| global.appConfig.dependencyProxy.connection | object | `{}` |  |
| global.appConfig.backups.bucket | string | `"gitlab-backups"` |  |
| global.appConfig.backups.tmpBucket | string | `"tmp"` |  |
| global.appConfig.microsoft_graph_mailer.enabled | bool | `false` |  |
| global.appConfig.microsoft_graph_mailer.user_id | string | `""` |  |
| global.appConfig.microsoft_graph_mailer.tenant | string | `""` |  |
| global.appConfig.microsoft_graph_mailer.client_id | string | `""` |  |
| global.appConfig.microsoft_graph_mailer.client_secret.secret | string | `""` |  |
| global.appConfig.microsoft_graph_mailer.client_secret.key | string | `"secret"` |  |
| global.appConfig.microsoft_graph_mailer.azure_ad_endpoint | string | `"https://login.microsoftonline.com"` |  |
| global.appConfig.microsoft_graph_mailer.graph_endpoint | string | `"https://graph.microsoft.com"` |  |
| global.appConfig.incomingEmail.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.address | string | `""` |  |
| global.appConfig.incomingEmail.host | string | `"imap.gmail.com"` |  |
| global.appConfig.incomingEmail.port | int | `993` |  |
| global.appConfig.incomingEmail.ssl | bool | `true` |  |
| global.appConfig.incomingEmail.startTls | bool | `false` |  |
| global.appConfig.incomingEmail.user | string | `""` |  |
| global.appConfig.incomingEmail.password.secret | string | `""` |  |
| global.appConfig.incomingEmail.password.key | string | `"password"` |  |
| global.appConfig.incomingEmail.deleteAfterDelivery | bool | `true` |  |
| global.appConfig.incomingEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.incomingEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.incomingEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.incomingEmail.idleTimeout | int | `60` |  |
| global.appConfig.incomingEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.incomingEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.incomingEmail.pollInterval | int | `60` |  |
| global.appConfig.incomingEmail.deliveryMethod | string | `"webhook"` |  |
| global.appConfig.incomingEmail.authToken | object | `{}` |  |
| global.appConfig.serviceDeskEmail.enabled | bool | `false` |  |
| global.appConfig.serviceDeskEmail.address | string | `""` |  |
| global.appConfig.serviceDeskEmail.host | string | `"imap.gmail.com"` |  |
| global.appConfig.serviceDeskEmail.port | int | `993` |  |
| global.appConfig.serviceDeskEmail.ssl | bool | `true` |  |
| global.appConfig.serviceDeskEmail.startTls | bool | `false` |  |
| global.appConfig.serviceDeskEmail.user | string | `""` |  |
| global.appConfig.serviceDeskEmail.password.secret | string | `""` |  |
| global.appConfig.serviceDeskEmail.password.key | string | `"password"` |  |
| global.appConfig.serviceDeskEmail.deleteAfterDelivery | bool | `true` |  |
| global.appConfig.serviceDeskEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.serviceDeskEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.serviceDeskEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.serviceDeskEmail.idleTimeout | int | `60` |  |
| global.appConfig.serviceDeskEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.serviceDeskEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.serviceDeskEmail.pollInterval | int | `60` |  |
| global.appConfig.serviceDeskEmail.deliveryMethod | string | `"webhook"` |  |
| global.appConfig.serviceDeskEmail.authToken | object | `{}` |  |
| global.appConfig.ldap.preventSignin | bool | `false` |  |
| global.appConfig.ldap.servers | object | `{}` |  |
| global.appConfig.duoAuth.enabled | bool | `false` |  |
| global.appConfig.gitlab_kas | object | `{}` |  |
| global.appConfig.suggested_reviewers | object | `{}` |  |
| global.appConfig.omniauth.enabled | bool | `false` |  |
| global.appConfig.omniauth.autoSignInWithProvider | string | `nil` |  |
| global.appConfig.omniauth.syncProfileFromProvider | list | `[]` |  |
| global.appConfig.omniauth.syncProfileAttributes[0] | string | `"email"` |  |
| global.appConfig.omniauth.allowSingleSignOn[0] | string | `"saml"` |  |
| global.appConfig.omniauth.blockAutoCreatedUsers | bool | `true` |  |
| global.appConfig.omniauth.autoLinkLdapUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkSamlUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkUser | list | `[]` |  |
| global.appConfig.omniauth.externalProviders | list | `[]` |  |
| global.appConfig.omniauth.allowBypassTwoFactor | list | `[]` |  |
| global.appConfig.omniauth.providers | list | `[]` |  |
| global.appConfig.kerberos.enabled | bool | `false` |  |
| global.appConfig.kerberos.keytab.key | string | `"keytab"` |  |
| global.appConfig.kerberos.servicePrincipalName | string | `""` |  |
| global.appConfig.kerberos.krb5Config | string | `""` |  |
| global.appConfig.kerberos.dedicatedPort.enabled | bool | `false` |  |
| global.appConfig.kerberos.dedicatedPort.port | int | `8443` |  |
| global.appConfig.kerberos.dedicatedPort.https | bool | `true` |  |
| global.appConfig.kerberos.simpleLdapLinkingAllowedRealms | list | `[]` |  |
| global.appConfig.sentry.enabled | bool | `false` |  |
| global.appConfig.sentry.dsn | string | `nil` |  |
| global.appConfig.sentry.clientside_dsn | string | `nil` |  |
| global.appConfig.sentry.environment | string | `nil` |  |
| global.appConfig.gitlab_docs.enabled | bool | `false` |  |
| global.appConfig.gitlab_docs.host | string | `""` |  |
| global.appConfig.smartcard.enabled | bool | `false` |  |
| global.appConfig.smartcard.CASecret | string | `nil` |  |
| global.appConfig.smartcard.clientCertificateRequiredHost | string | `nil` |  |
| global.appConfig.smartcard.sanExtensions | bool | `false` |  |
| global.appConfig.smartcard.requiredForGitAccess | bool | `false` |  |
| global.appConfig.sidekiq.routingRules | list | `[]` |  |
| global.appConfig.initialDefaults | object | `{}` |  |
| global.oauth.gitlab-pages | object | `{}` |  |
| global.geo.enabled | bool | `false` |  |
| global.geo.role | string | `"primary"` |  |
| global.geo.nodeName | string | `nil` |  |
| global.geo.psql.password | object | `{}` |  |
| global.geo.registry.replication.enabled | bool | `false` |  |
| global.geo.registry.replication.primaryApiUrl | string | `nil` |  |
| global.kas.enabled | bool | `false` |  |
| global.kas.service.apiExternalPort | int | `8153` |  |
| global.kas.tls.enabled | bool | `false` |  |
| global.kas.tls.verify | bool | `true` |  |
| global.spamcheck.enabled | bool | `false` |  |
| global.shell.authToken | object | `{}` |  |
| global.shell.hostKeys | object | `{}` |  |
| global.shell.tcp.proxyProtocol | bool | `false` |  |
| global.railsSecrets | object | `{}` |  |
| global.rails.bootsnap.enabled | bool | `true` |  |
| global.registry.bucket | string | `"registry"` |  |
| global.registry.certificate | object | `{}` |  |
| global.registry.httpSecret | object | `{}` |  |
| global.registry.notificationSecret | object | `{}` |  |
| global.registry.tls.enabled | bool | `false` |  |
| global.registry.redis.cache.password | object | `{}` |  |
| global.registry.notifications | object | `{}` |  |
| global.registry.enabled | bool | `true` |  |
| global.registry.host | string | `nil` |  |
| global.registry.api.protocol | string | `"http"` |  |
| global.registry.api.serviceName | string | `"registry"` |  |
| global.registry.api.port | int | `5000` |  |
| global.registry.tokenIssuer | string | `"gitlab-issuer"` |  |
| global.pages.enabled | bool | `false` |  |
| global.pages.accessControl | bool | `false` |  |
| global.pages.path | string | `nil` |  |
| global.pages.host | string | `nil` |  |
| global.pages.port | string | `nil` |  |
| global.pages.https | string | `nil` |  |
| global.pages.externalHttp | list | `[]` |  |
| global.pages.externalHttps | list | `[]` |  |
| global.pages.artifactsServer | bool | `true` |  |
| global.pages.localStore.enabled | bool | `false` |  |
| global.pages.objectStore.enabled | bool | `true` |  |
| global.pages.objectStore.bucket | string | `"gitlab-pages"` |  |
| global.pages.objectStore.connection | object | `{}` |  |
| global.pages.apiSecret | object | `{}` |  |
| global.pages.authSecret | object | `{}` |  |
| global.runner.registrationToken | object | `{}` |  |
| global.smtp.enabled | bool | `false` |  |
| global.smtp.address | string | `"smtp.mailgun.org"` |  |
| global.smtp.port | int | `2525` |  |
| global.smtp.user_name | string | `""` |  |
| global.smtp.password.secret | string | `""` |  |
| global.smtp.password.key | string | `"password"` |  |
| global.smtp.authentication | string | `"plain"` |  |
| global.smtp.starttls_auto | bool | `false` |  |
| global.smtp.openssl_verify_mode | string | `"peer"` |  |
| global.smtp.open_timeout | int | `30` |  |
| global.smtp.read_timeout | int | `60` |  |
| global.smtp.pool | bool | `false` |  |
| global.email.from | string | `""` |  |
| global.email.display_name | string | `"GitLab"` |  |
| global.email.reply_to | string | `""` |  |
| global.email.subject_suffix | string | `""` |  |
| global.email.smime.enabled | bool | `false` |  |
| global.email.smime.secretName | string | `""` |  |
| global.email.smime.keyName | string | `"tls.key"` |  |
| global.email.smime.certName | string | `"tls.crt"` |  |
| global.time_zone | string | `"UTC"` |  |
| global.service.labels | object | `{}` |  |
| global.service.annotations | object | `{}` |  |
| global.deployment.annotations | object | `{}` |  |
| global.antiAffinity | string | `"soft"` |  |
| global.affinity.podAntiAffinity.topologyKey | string | `"kubernetes.io/hostname"` |  |
| global.priorityClassName | string | `""` |  |
| global.workhorse.serviceName | string | `"webservice-default"` |  |
| global.workhorse.tls.enabled | bool | `false` |  |
| global.webservice.workerTimeout | int | `60` |  |
| global.certificates.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/certificates"` |  |
| global.certificates.image.tag | string | `"16.4.1"` |  |
| global.certificates.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.certificates.customCAs[0].secret | string | `"ca-certs-australian-defence-organisation-cross-cert-chain"` |  |
| global.certificates.customCAs[1].secret | string | `"ca-certs-australian-defence-organisation-direct-trust-chain"` |  |
| global.certificates.customCAs[2].secret | string | `"ca-certs-boeing"` |  |
| global.certificates.customCAs[3].secret | string | `"ca-certs-carillon-federal-services-trust-chain-1"` |  |
| global.certificates.customCAs[4].secret | string | `"ca-certs-carillon-federal-services-trust-chain-2"` |  |
| global.certificates.customCAs[5].secret | string | `"ca-certs-department-of-state-trust-chain-1"` |  |
| global.certificates.customCAs[6].secret | string | `"ca-certs-department-of-state-trust-chain-2"` |  |
| global.certificates.customCAs[7].secret | string | `"ca-certs-digicert-federal-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[8].secret | string | `"ca-certs-digicert-federal-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[9].secret | string | `"ca-certs-digicert-nfi-trust-chain-1"` |  |
| global.certificates.customCAs[10].secret | string | `"ca-certs-digicert-nfi-trust-chain-2"` |  |
| global.certificates.customCAs[11].secret | string | `"ca-certs-entrust-federal-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[12].secret | string | `"ca-certs-entrust-federal-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[13].secret | string | `"ca-certs-entrust-managed-service-nfi"` |  |
| global.certificates.customCAs[14].secret | string | `"ca-certs-exostar-llc"` |  |
| global.certificates.customCAs[15].secret | string | `"ca-certs-identrust-nfi"` |  |
| global.certificates.customCAs[16].secret | string | `"ca-certs-lockheed-martin"` |  |
| global.certificates.customCAs[17].secret | string | `"ca-certs-netherlands-ministry-of-defence"` |  |
| global.certificates.customCAs[18].secret | string | `"ca-certs-northrop-grumman"` |  |
| global.certificates.customCAs[19].secret | string | `"ca-certs-raytheon-trust-chain-1"` |  |
| global.certificates.customCAs[20].secret | string | `"ca-certs-raytheon-trust-chain-2"` |  |
| global.certificates.customCAs[21].secret | string | `"ca-certs-us-treasury-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[22].secret | string | `"ca-certs-us-treasury-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[23].secret | string | `"ca-certs-verizon-cybertrust-federal-ssp"` |  |
| global.certificates.customCAs[24].secret | string | `"ca-certs-widepoint-federal-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[25].secret | string | `"ca-certs-widepoint-federal-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[26].secret | string | `"ca-certs-widepoint-nfi"` |  |
| global.certificates.customCAs[27].secret | string | `"ca-certs-dod-intermediate-and-issuing-ca-certs"` |  |
| global.certificates.customCAs[28].secret | string | `"ca-certs-dod-trust-anchors-self-signed"` |  |
| global.certificates.customCAs[29].secret | string | `"ca-certs-eca"` |  |
| global.kubectl.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/kubectl"` |  |
| global.kubectl.image.tag | string | `"16.4.1"` |  |
| global.kubectl.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.kubectl.securityContext.runAsUser | int | `65534` |  |
| global.kubectl.securityContext.fsGroup | int | `65534` |  |
| global.gitlabBase.image.repository | string | `"registry1.dso.mil/ironbank/redhat/ubi/ubi8"` |  |
| global.gitlabBase.image.tag | string | `"8.8"` |  |
| global.gitlabBase.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.serviceAccount.enabled | bool | `false` |  |
| global.serviceAccount.create | bool | `true` |  |
| global.serviceAccount.annotations | object | `{}` |  |
| global.tracing.connection.string | string | `""` |  |
| global.tracing.urlTemplate | string | `""` |  |
| global.zoekt.gateway.basicAuth | object | `{}` |  |
| global.extraEnv | object | `{}` |  |
| global.extraEnvFrom | object | `{}` |  |
| containerSecurityContext.runAsUser | int | `65534` |  |
| containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upgradeCheck.enabled | bool | `true` |  |
| upgradeCheck.image.repository | string | `"registry1.dso.mil/ironbank/redhat/ubi/ubi8"` |  |
| upgradeCheck.image.tag | string | `"8.8"` |  |
| upgradeCheck.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upgradeCheck.securityContext.runAsUser | int | `65534` |  |
| upgradeCheck.securityContext.fsGroup | int | `65534` |  |
| upgradeCheck.tolerations | list | `[]` |  |
| upgradeCheck.annotations."sidecar.istio.io/inject" | string | `"false"` |  |
| upgradeCheck.configMapAnnotations | object | `{}` |  |
| upgradeCheck.resources.requests.cpu | string | `"500m"` |  |
| upgradeCheck.resources.requests.memory | string | `"500Mi"` |  |
| upgradeCheck.resources.limits.cpu | string | `"500m"` |  |
| upgradeCheck.resources.limits.memory | string | `"500Mi"` |  |
| certmanager.installCRDs | bool | `false` |  |
| certmanager.nameOverride | string | `"certmanager"` |  |
| certmanager.install | bool | `false` |  |
| certmanager.rbac.create | bool | `true` |  |
| nginx-ingress.enabled | bool | `false` |  |
| nginx-ingress.tcpExternalConfig | string | `"true"` |  |
| nginx-ingress.controller.addHeaders.Referrer-Policy | string | `"strict-origin-when-cross-origin"` |  |
| nginx-ingress.controller.config.annotation-value-word-blocklist | string | `"load_module,lua_package,_by_lua,location,root,proxy_pass,serviceaccount,{,},',\""` |  |
| nginx-ingress.controller.config.hsts | string | `"true"` |  |
| nginx-ingress.controller.config.hsts-include-subdomains | string | `"false"` |  |
| nginx-ingress.controller.config.hsts-max-age | string | `"63072000"` |  |
| nginx-ingress.controller.config.server-name-hash-bucket-size | string | `"256"` |  |
| nginx-ingress.controller.config.use-http2 | string | `"true"` |  |
| nginx-ingress.controller.config.ssl-ciphers | string | `"ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"` |  |
| nginx-ingress.controller.config.ssl-protocols | string | `"TLSv1.3 TLSv1.2"` |  |
| nginx-ingress.controller.config.server-tokens | string | `"false"` |  |
| nginx-ingress.controller.config.upstream-keepalive-connections | int | `100` |  |
| nginx-ingress.controller.config.upstream-keepalive-time | string | `"30s"` |  |
| nginx-ingress.controller.config.upstream-keepalive-timeout | int | `5` |  |
| nginx-ingress.controller.config.upstream-keepalive-requests | int | `1000` |  |
| nginx-ingress.controller.service.externalTrafficPolicy | string | `"Local"` |  |
| nginx-ingress.controller.ingressClassByName | bool | `false` |  |
| nginx-ingress.controller.ingressClassResource.name | string | `"{{ include \"ingress.class.name\" $ }}"` |  |
| nginx-ingress.controller.resources.requests.cpu | string | `"100m"` |  |
| nginx-ingress.controller.resources.requests.memory | string | `"100Mi"` |  |
| nginx-ingress.controller.publishService.enabled | bool | `true` |  |
| nginx-ingress.controller.replicaCount | int | `2` |  |
| nginx-ingress.controller.minAvailable | int | `1` |  |
| nginx-ingress.controller.scope.enabled | bool | `true` |  |
| nginx-ingress.controller.metrics.enabled | bool | `true` |  |
| nginx-ingress.controller.metrics.service.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| nginx-ingress.controller.metrics.service.annotations."gitlab.com/prometheus_port" | string | `"10254"` |  |
| nginx-ingress.controller.metrics.service.annotations."prometheus.io/scrape" | string | `"true"` |  |
| nginx-ingress.controller.metrics.service.annotations."prometheus.io/port" | string | `"10254"` |  |
| nginx-ingress.controller.admissionWebhooks.enabled | bool | `false` |  |
| nginx-ingress.defaultBackend.resources.requests.cpu | string | `"5m"` |  |
| nginx-ingress.defaultBackend.resources.requests.memory | string | `"5Mi"` |  |
| nginx-ingress.rbac.create | bool | `true` |  |
| nginx-ingress.rbac.scope | bool | `false` |  |
| nginx-ingress.serviceAccount.create | bool | `true` |  |
| nginx-ingress-geo.<<.enabled | bool | `false` |  |
| nginx-ingress-geo.<<.tcpExternalConfig | string | `"true"` |  |
| nginx-ingress-geo.<<.controller.addHeaders.Referrer-Policy | string | `"strict-origin-when-cross-origin"` |  |
| nginx-ingress-geo.<<.controller.config.annotation-value-word-blocklist | string | `"load_module,lua_package,_by_lua,location,root,proxy_pass,serviceaccount,{,},',\""` |  |
| nginx-ingress-geo.<<.controller.config.hsts | string | `"true"` |  |
| nginx-ingress-geo.<<.controller.config.hsts-include-subdomains | string | `"false"` |  |
| nginx-ingress-geo.<<.controller.config.hsts-max-age | string | `"63072000"` |  |
| nginx-ingress-geo.<<.controller.config.server-name-hash-bucket-size | string | `"256"` |  |
| nginx-ingress-geo.<<.controller.config.use-http2 | string | `"true"` |  |
| nginx-ingress-geo.<<.controller.config.ssl-ciphers | string | `"ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"` |  |
| nginx-ingress-geo.<<.controller.config.ssl-protocols | string | `"TLSv1.3 TLSv1.2"` |  |
| nginx-ingress-geo.<<.controller.config.server-tokens | string | `"false"` |  |
| nginx-ingress-geo.<<.controller.config.upstream-keepalive-connections | int | `100` |  |
| nginx-ingress-geo.<<.controller.config.upstream-keepalive-time | string | `"30s"` |  |
| nginx-ingress-geo.<<.controller.config.upstream-keepalive-timeout | int | `5` |  |
| nginx-ingress-geo.<<.controller.config.upstream-keepalive-requests | int | `1000` |  |
| nginx-ingress-geo.<<.controller.service.externalTrafficPolicy | string | `"Local"` |  |
| nginx-ingress-geo.<<.controller.ingressClassByName | bool | `false` |  |
| nginx-ingress-geo.<<.controller.ingressClassResource.name | string | `"{{ include \"ingress.class.name\" $ }}"` |  |
| nginx-ingress-geo.<<.controller.resources.requests.cpu | string | `"100m"` |  |
| nginx-ingress-geo.<<.controller.resources.requests.memory | string | `"100Mi"` |  |
| nginx-ingress-geo.<<.controller.publishService.enabled | bool | `true` |  |
| nginx-ingress-geo.<<.controller.replicaCount | int | `2` |  |
| nginx-ingress-geo.<<.controller.minAvailable | int | `1` |  |
| nginx-ingress-geo.<<.controller.scope.enabled | bool | `true` |  |
| nginx-ingress-geo.<<.controller.metrics.enabled | bool | `true` |  |
| nginx-ingress-geo.<<.controller.metrics.service.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| nginx-ingress-geo.<<.controller.metrics.service.annotations."gitlab.com/prometheus_port" | string | `"10254"` |  |
| nginx-ingress-geo.<<.controller.metrics.service.annotations."prometheus.io/scrape" | string | `"true"` |  |
| nginx-ingress-geo.<<.controller.metrics.service.annotations."prometheus.io/port" | string | `"10254"` |  |
| nginx-ingress-geo.<<.controller.admissionWebhooks.enabled | bool | `false` |  |
| nginx-ingress-geo.<<.defaultBackend.resources.requests.cpu | string | `"5m"` |  |
| nginx-ingress-geo.<<.defaultBackend.resources.requests.memory | string | `"5Mi"` |  |
| nginx-ingress-geo.<<.rbac.create | bool | `true` |  |
| nginx-ingress-geo.<<.rbac.scope | bool | `false` |  |
| nginx-ingress-geo.<<.serviceAccount.create | bool | `true` |  |
| nginx-ingress-geo.enabled | bool | `false` |  |
| nginx-ingress-geo.controller.<<.addHeaders.Referrer-Policy | string | `"strict-origin-when-cross-origin"` |  |
| nginx-ingress-geo.controller.<<.config.annotation-value-word-blocklist | string | `"load_module,lua_package,_by_lua,location,root,proxy_pass,serviceaccount,{,},',\""` |  |
| nginx-ingress-geo.controller.<<.config.hsts | string | `"true"` |  |
| nginx-ingress-geo.controller.<<.config.hsts-include-subdomains | string | `"false"` |  |
| nginx-ingress-geo.controller.<<.config.hsts-max-age | string | `"63072000"` |  |
| nginx-ingress-geo.controller.<<.config.server-name-hash-bucket-size | string | `"256"` |  |
| nginx-ingress-geo.controller.<<.config.use-http2 | string | `"true"` |  |
| nginx-ingress-geo.controller.<<.config.ssl-ciphers | string | `"ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"` |  |
| nginx-ingress-geo.controller.<<.config.ssl-protocols | string | `"TLSv1.3 TLSv1.2"` |  |
| nginx-ingress-geo.controller.<<.config.server-tokens | string | `"false"` |  |
| nginx-ingress-geo.controller.<<.config.upstream-keepalive-connections | int | `100` |  |
| nginx-ingress-geo.controller.<<.config.upstream-keepalive-time | string | `"30s"` |  |
| nginx-ingress-geo.controller.<<.config.upstream-keepalive-timeout | int | `5` |  |
| nginx-ingress-geo.controller.<<.config.upstream-keepalive-requests | int | `1000` |  |
| nginx-ingress-geo.controller.<<.service.externalTrafficPolicy | string | `"Local"` |  |
| nginx-ingress-geo.controller.<<.ingressClassByName | bool | `false` |  |
| nginx-ingress-geo.controller.<<.ingressClassResource.name | string | `"{{ include \"ingress.class.name\" $ }}"` |  |
| nginx-ingress-geo.controller.<<.resources.requests.cpu | string | `"100m"` |  |
| nginx-ingress-geo.controller.<<.resources.requests.memory | string | `"100Mi"` |  |
| nginx-ingress-geo.controller.<<.publishService.enabled | bool | `true` |  |
| nginx-ingress-geo.controller.<<.replicaCount | int | `2` |  |
| nginx-ingress-geo.controller.<<.minAvailable | int | `1` |  |
| nginx-ingress-geo.controller.<<.scope.enabled | bool | `true` |  |
| nginx-ingress-geo.controller.<<.metrics.enabled | bool | `true` |  |
| nginx-ingress-geo.controller.<<.metrics.service.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| nginx-ingress-geo.controller.<<.metrics.service.annotations."gitlab.com/prometheus_port" | string | `"10254"` |  |
| nginx-ingress-geo.controller.<<.metrics.service.annotations."prometheus.io/scrape" | string | `"true"` |  |
| nginx-ingress-geo.controller.<<.metrics.service.annotations."prometheus.io/port" | string | `"10254"` |  |
| nginx-ingress-geo.controller.<<.admissionWebhooks.enabled | bool | `false` |  |
| nginx-ingress-geo.controller.config.<<.annotation-value-word-blocklist | string | `"load_module,lua_package,_by_lua,location,root,proxy_pass,serviceaccount,{,},',\""` |  |
| nginx-ingress-geo.controller.config.<<.hsts | string | `"true"` |  |
| nginx-ingress-geo.controller.config.<<.hsts-include-subdomains | string | `"false"` |  |
| nginx-ingress-geo.controller.config.<<.hsts-max-age | string | `"63072000"` |  |
| nginx-ingress-geo.controller.config.<<.server-name-hash-bucket-size | string | `"256"` |  |
| nginx-ingress-geo.controller.config.<<.use-http2 | string | `"true"` |  |
| nginx-ingress-geo.controller.config.<<.ssl-ciphers | string | `"ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"` |  |
| nginx-ingress-geo.controller.config.<<.ssl-protocols | string | `"TLSv1.3 TLSv1.2"` |  |
| nginx-ingress-geo.controller.config.<<.server-tokens | string | `"false"` |  |
| nginx-ingress-geo.controller.config.<<.upstream-keepalive-connections | int | `100` |  |
| nginx-ingress-geo.controller.config.<<.upstream-keepalive-time | string | `"30s"` |  |
| nginx-ingress-geo.controller.config.<<.upstream-keepalive-timeout | int | `5` |  |
| nginx-ingress-geo.controller.config.<<.upstream-keepalive-requests | int | `1000` |  |
| nginx-ingress-geo.controller.config.use-forwarded-headers | bool | `true` |  |
| nginx-ingress-geo.controller.electionID | string | `"ingress-controller-leader-geo"` |  |
| nginx-ingress-geo.controller.ingressClassResource.name | string | `"{{ include \"gitlab.geo.ingress.class.name\" $ \| quote }}"` |  |
| nginx-ingress-geo.controller.ingressClassResource.controllerValue | string | `"k8s.io/nginx-ingress-geo"` |  |
| haproxy.install | bool | `false` |  |
| haproxy.controller.service.type | string | `"LoadBalancer"` |  |
| haproxy.controller.service.tcpPorts[0].name | string | `"ssh"` |  |
| haproxy.controller.service.tcpPorts[0].port | int | `22` |  |
| haproxy.controller.service.tcpPorts[0].targetPort | int | `22` |  |
| haproxy.controller.extraArgs[0] | string | `"--configmap-tcp-services=$(POD_NAMESPACE)/$(POD_NAMESPACE)-haproxy-tcp"` |  |
| prometheus.install | bool | `false` |  |
| prometheus.rbac.create | bool | `true` |  |
| prometheus.alertmanager.enabled | bool | `false` |  |
| prometheus.alertmanagerFiles."alertmanager.yml" | object | `{}` |  |
| prometheus.kubeStateMetrics.enabled | bool | `false` |  |
| prometheus.nodeExporter.enabled | bool | `false` |  |
| prometheus.pushgateway.enabled | bool | `false` |  |
| prometheus.server.enabled | bool | `false` |  |
| prometheus.server.retention | string | `"15d"` |  |
| prometheus.server.strategy.type | string | `"Recreate"` |  |
| prometheus.server.image.tag | string | `"v2.38.0"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[0].job_name | string | `"prometheus"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[0].static_configs[0].targets[0] | string | `"localhost:9090"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].job_name | string | `"kubernetes-apiservers"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].kubernetes_sd_configs[0].role | string | `"endpoints"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].scheme | string | `"https"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].tls_config.ca_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].tls_config.insecure_skip_verify | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].bearer_token_file | string | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].source_labels[0] | string | `"__meta_kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].source_labels[1] | string | `"__meta_kubernetes_service_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].source_labels[2] | string | `"__meta_kubernetes_endpoint_port_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[1].relabel_configs[0].regex | string | `"default;kubernetes;https"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].job_name | string | `"kubernetes-pods"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].kubernetes_sd_configs[0].role | string | `"pod"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[0].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_gitlab_com_prometheus_scrape"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[0].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[0].regex | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_gitlab_com_prometheus_scheme"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].regex | string | `"(https?)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].target_label | string | `"__scheme__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_gitlab_com_prometheus_path"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].target_label | string | `"__metrics_path__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].regex | string | `"(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].source_labels[0] | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].source_labels[1] | string | `"__meta_kubernetes_pod_annotation_gitlab_com_prometheus_port"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].regex | string | `"([^:]+)(?::\\d+)?;(\\d+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].replacement | string | `"$1:$2"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[4].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[4].regex | string | `"__meta_kubernetes_pod_label_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[5].source_labels[0] | string | `"__meta_kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[5].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[5].target_label | string | `"kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[6].source_labels[0] | string | `"__meta_kubernetes_pod_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[6].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[6].target_label | string | `"kubernetes_pod_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].job_name | string | `"kubernetes-service-endpoints"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].kubernetes_sd_configs[0].role | string | `"endpoints"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[0].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[0].regex | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[0].source_labels[0] | string | `"__meta_kubernetes_service_annotation_gitlab_com_prometheus_scrape"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[1].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[1].regex | string | `"(https?)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[1].source_labels[0] | string | `"__meta_kubernetes_service_annotation_gitlab_com_prometheus_scheme"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[1].target_label | string | `"__scheme__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].regex | string | `"(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].source_labels[0] | string | `"__meta_kubernetes_service_annotation_gitlab_com_prometheus_path"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[2].target_label | string | `"__metrics_path__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[3].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[3].regex | string | `"([^:]+)(?::\\d+)?;(\\d+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[3].replacement | string | `"$1:$2"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[3].source_labels[0] | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[3].source_labels[1] | string | `"__meta_kubernetes_service_annotation_gitlab_com_prometheus_port"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[3].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[4].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[4].regex | string | `"__meta_kubernetes_service_label_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[5].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[5].source_labels[0] | string | `"__meta_kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[5].target_label | string | `"kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[6].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[6].source_labels[0] | string | `"__meta_kubernetes_service_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[6].target_label | string | `"kubernetes_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[7].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[7].source_labels[0] | string | `"__meta_kubernetes_pod_node_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[3].relabel_configs[7].target_label | string | `"kubernetes_node"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].job_name | string | `"kubernetes-services"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].metrics_path | string | `"/probe"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].params.module[0] | string | `"http_2xx"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].kubernetes_sd_configs[0].role | string | `"service"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[0].source_labels[0] | string | `"__meta_kubernetes_service_annotation_gitlab_com_prometheus_probe"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[0].action | string | `"keep"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[0].regex | bool | `true` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[1].source_labels[0] | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[1].target_label | string | `"__param_target"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[2].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[2].replacement | string | `"blackbox"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[3].source_labels[0] | string | `"__param_target"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[3].target_label | string | `"instance"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[4].regex | string | `"__meta_kubernetes_service_label_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].source_labels[0] | string | `"__meta_kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[5].target_label | string | `"kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[6].source_labels[0] | string | `"__meta_kubernetes_service_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[4].relabel_configs[6].target_label | string | `"kubernetes_name"` |  |
| redis.global.imagePullSecrets[0] | string | `"private-registry"` |  |
| redis.install | bool | `true` |  |
| redis.auth.existingSecret | string | `"gitlab-redis-secret"` |  |
| redis.auth.existingSecretKey | string | `"secret"` |  |
| redis.auth.usePasswordFiles | bool | `true` |  |
| redis.architecture | string | `"standalone"` |  |
| redis.cluster.enabled | bool | `false` |  |
| redis.metrics.enabled | bool | `true` |  |
| redis.metrics.image.registry | string | `"registry1.dso.mil/ironbank/bitnami"` |  |
| redis.metrics.image.repository | string | `"analytics/redis-exporter"` |  |
| redis.metrics.image.tag | string | `"v1.54.0"` |  |
| redis.metrics.image.pullSecrets | list | `[]` |  |
| redis.metrics.resources.limits.cpu | string | `"250m"` |  |
| redis.metrics.resources.limits.memory | string | `"256Mi"` |  |
| redis.metrics.resources.requests.cpu | string | `"250m"` |  |
| redis.metrics.resources.requests.memory | string | `"256Mi"` |  |
| redis.metrics.containerSecurityContext.enabled | bool | `true` |  |
| redis.metrics.containerSecurityContext.runAsUser | int | `1001` |  |
| redis.metrics.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| redis.metrics.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| redis.securityContext.runAsUser | int | `1001` |  |
| redis.securityContext.fsGroup | int | `1001` |  |
| redis.securityContext.runAsNonRoot | bool | `true` |  |
| redis.image.registry | string | `"registry1.dso.mil/ironbank/bitnami"` |  |
| redis.image.repository | string | `"redis"` |  |
| redis.image.tag | string | `"7.0.0-debian-10-r3"` |  |
| redis.image.pullSecrets | list | `[]` |  |
| redis.master.resources.limits.cpu | string | `"250m"` |  |
| redis.master.resources.limits.memory | string | `"256Mi"` |  |
| redis.master.resources.requests.cpu | string | `"250m"` |  |
| redis.master.resources.requests.memory | string | `"256Mi"` |  |
| redis.master.containerSecurityContext.enabled | bool | `true` |  |
| redis.master.containerSecurityContext.runAsUser | int | `1001` |  |
| redis.master.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| redis.master.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| redis.slave.resources.limits.cpu | string | `"250m"` |  |
| redis.slave.resources.limits.memory | string | `"256Mi"` |  |
| redis.slave.resources.requests.cpu | string | `"250m"` |  |
| redis.slave.resources.requests.memory | string | `"256Mi"` |  |
| redis.slave.containerSecurityContext.enabled | bool | `true` |  |
| redis.slave.containerSecurityContext.runAsUser | int | `1001` |  |
| redis.slave.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| redis.slave.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| redis.sentinel.resources.limits.cpu | string | `"250m"` |  |
| redis.sentinel.resources.limits.memory | string | `"256Mi"` |  |
| redis.sentinel.resources.requests.cpu | string | `"250m"` |  |
| redis.sentinel.resources.requests.memory | string | `"256Mi"` |  |
| redis.volumePermissions.resources.limits.cpu | string | `"250m"` |  |
| redis.volumePermissions.resources.limits.memory | string | `"256Mi"` |  |
| redis.volumePermissions.resources.requests.cpu | string | `"250m"` |  |
| redis.volumePermissions.resources.requests.memory | string | `"256Mi"` |  |
| redis.sysctlImage.resources.limits.cpu | string | `"250m"` |  |
| redis.sysctlImage.resources.limits.memory | string | `"256Mi"` |  |
| redis.sysctlImage.resources.requests.cpu | string | `"250m"` |  |
| redis.sysctlImage.resources.requests.memory | string | `"256Mi"` |  |
| postgresql.install | bool | `true` |  |
| postgresql.postgresqlDatabase | string | `"gitlabhq_production"` |  |
| postgresql.resources.limits.cpu | string | `"500m"` |  |
| postgresql.resources.limits.memory | string | `"500Mi"` |  |
| postgresql.resources.requests.cpu | string | `"500m"` |  |
| postgresql.resources.requests.memory | string | `"500Mi"` |  |
| postgresql.image.registry | string | `"registry1.dso.mil"` |  |
| postgresql.image.repository | string | `"ironbank/opensource/postgres/postgresql"` |  |
| postgresql.image.tag | string | `"15.4"` |  |
| postgresql.image.pullSecrets[0] | string | `"private-registry"` |  |
| postgresql.auth.username | string | `"gitlab"` |  |
| postgresql.auth.password | string | `"bogus-satisfy-upgrade"` |  |
| postgresql.auth.postgresPassword | string | `"bogus-satisfy-upgrade"` |  |
| postgresql.auth.usePasswordFiles | bool | `false` |  |
| postgresql.auth.existingSecret | string | `"{{ include \"gitlab.psql.password.secret\" . }}"` |  |
| postgresql.auth.secretKeys.adminPasswordKey | string | `"postgresql-postgres-password"` |  |
| postgresql.auth.secretKeys.userPasswordKey | string | `"{{ include \"gitlab.psql.password.key\" $ }}"` |  |
| postgresql.primary.persistence.mountPath | string | `"/var/lib/postgresql"` |  |
| postgresql.primary.initdb.scriptsConfigMap | string | `"{{ include \"gitlab.psql.initdbscripts\" $}}"` |  |
| postgresql.primary.initdb.user | string | `"gitlab"` |  |
| postgresql.primary.containerSecurityContext.enabled | bool | `true` |  |
| postgresql.primary.containerSecurityContext.runAsUser | int | `1001` |  |
| postgresql.primary.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| postgresql.master.extraVolumeMounts[0].name | string | `"custom-init-scripts"` |  |
| postgresql.master.extraVolumeMounts[0].mountPath | string | `"/docker-entrypoint-preinitdb.d/init_revision.sh"` |  |
| postgresql.master.extraVolumeMounts[0].subPath | string | `"init_revision.sh"` |  |
| postgresql.master.podAnnotations."postgresql.gitlab/init-revision" | string | `"1"` |  |
| postgresql.metrics.enabled | bool | `false` |  |
| postgresql.metrics.service.annotations."prometheus.io/scrape" | string | `"true"` |  |
| postgresql.metrics.service.annotations."prometheus.io/port" | string | `"9187"` |  |
| postgresql.metrics.service.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| postgresql.metrics.service.annotations."gitlab.com/prometheus_port" | string | `"9187"` |  |
| postgresql.postgresqlInitdbArgs | string | `"-A scram-sha-256"` |  |
| postgresql.securityContext.enabled | bool | `true` |  |
| postgresql.securityContext.fsGroup | int | `26` |  |
| postgresql.securityContext.runAsUser | int | `26` |  |
| postgresql.securityContext.runAsGroup | int | `26` |  |
| postgresql.postgresqlDataDir | string | `"/var/lib/postgresql/pgdata/data"` |  |
| postgresql.volumePermissions.enabled | bool | `false` |  |
| registry.enabled | bool | `true` |  |
| registry.init.resources.limits.cpu | string | `"200m"` |  |
| registry.init.resources.limits.memory | string | `"200Mi"` |  |
| registry.init.resources.requests.cpu | string | `"200m"` |  |
| registry.init.resources.requests.memory | string | `"200Mi"` |  |
| registry.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| registry.resources.limits.cpu | string | `"200m"` |  |
| registry.resources.limits.memory | string | `"1024Mi"` |  |
| registry.resources.requests.cpu | string | `"200m"` |  |
| registry.resources.requests.memory | string | `"1024Mi"` |  |
| registry.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-container-registry"` |  |
| registry.image.tag | string | `"16.4.1"` |  |
| registry.image.pullSecrets[0].name | string | `"private-registry"` |  |
| registry.ingress.enabled | bool | `false` |  |
| registry.metrics.enabled | bool | `true` |  |
| registry.metrics.path | string | `"/metrics"` |  |
| registry.metrics.serviceMonitor.enabled | bool | `true` |  |
| registry.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| shared-secrets.enabled | bool | `true` |  |
| shared-secrets.rbac.create | bool | `true` |  |
| shared-secrets.selfsign.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/cfssl-self-sign"` |  |
| shared-secrets.selfsign.image.tag | string | `"1.6.1"` |  |
| shared-secrets.selfsign.keyAlgorithm | string | `"rsa"` |  |
| shared-secrets.selfsign.keySize | string | `"4096"` |  |
| shared-secrets.selfsign.expiry | string | `"3650d"` |  |
| shared-secrets.selfsign.caSubject | string | `"GitLab Helm Chart"` |  |
| shared-secrets.env | string | `"production"` |  |
| shared-secrets.serviceAccount.enabled | bool | `true` |  |
| shared-secrets.serviceAccount.create | bool | `true` |  |
| shared-secrets.serviceAccount.name | string | `nil` |  |
| shared-secrets.resources.requests.cpu | string | `"300m"` |  |
| shared-secrets.resources.requests.memory | string | `"200Mi"` |  |
| shared-secrets.resources.limits.cpu | string | `"300m"` |  |
| shared-secrets.resources.limits.memory | string | `"200Mi"` |  |
| shared-secrets.securityContext.runAsUser | int | `65534` |  |
| shared-secrets.securityContext.fsGroup | int | `65534` |  |
| shared-secrets.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| shared-secrets.tolerations | list | `[]` |  |
| shared-secrets.podLabels | object | `{}` |  |
| shared-secrets.annotations."sidecar.istio.io/inject" | string | `"false"` |  |
| gitlab-runner.install | bool | `false` |  |
| gitlab-runner.rbac.create | bool | `true` |  |
| gitlab-runner.runners.locked | bool | `false` |  |
| gitlab-runner.runners.config | string | `"[[runners]]\n  [runners.kubernetes]\n  image = \"ubuntu:22.04\"\n  {{- if .Values.global.minio.enabled }}\n  [runners.cache]\n    Type = \"s3\"\n    Path = \"gitlab-runner\"\n    Shared = true\n    [runners.cache.s3]\n      ServerAddress = {{ include \"gitlab-runner.cache-tpl.s3ServerAddress\" . }}\n      BucketName = \"runner-cache\"\n      BucketLocation = \"us-east-1\"\n      Insecure = false\n  {{ end }}\n"` |  |
| gitlab-runner.podAnnotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| gitlab-runner.podAnnotations."gitlab.com/prometheus_port" | int | `9252` |  |
| gitlab-runner.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| traefik.install | bool | `false` |  |
| traefik.ports.gitlab-shell.expose | bool | `true` |  |
| traefik.ports.gitlab-shell.port | int | `2222` |  |
| traefik.ports.gitlab-shell.exposedPort | int | `22` |  |
| gitlab.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.toolbox.replicas | int | `1` |  |
| gitlab.toolbox.antiAffinityLabels.matchLabels.app | string | `"gitaly"` |  |
| gitlab.toolbox.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-toolbox"` |  |
| gitlab.toolbox.image.tag | string | `"16.4.1"` |  |
| gitlab.toolbox.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.toolbox.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.toolbox.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.toolbox.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.toolbox.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.toolbox.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.toolbox.resources.requests.cpu | int | `2` |  |
| gitlab.toolbox.resources.requests.memory | string | `"3.5Gi"` |  |
| gitlab.toolbox.resources.limits.cpu | int | `2` |  |
| gitlab.toolbox.resources.limits.memory | string | `"3.5Gi"` |  |
| gitlab.toolbox.annotations."sidecar.istio.io/proxyMemory" | string | `"512Mi"` |  |
| gitlab.toolbox.annotations."sidecar.istio.io/proxyMemoryLimit" | string | `"512Mi"` |  |
| gitlab.toolbox.backups.cron.resources.requests.cpu | string | `"500m"` |  |
| gitlab.toolbox.backups.cron.resources.requests.memory | string | `"768Mi"` |  |
| gitlab.toolbox.backups.cron.resources.limits.cpu | string | `"500m"` |  |
| gitlab.toolbox.backups.cron.resources.limits.memory | string | `"768Mi"` |  |
| gitlab.toolbox.backups.cron.istioShutdown | string | `"&& echo \"Backup Complete\" && until curl -fsI http://localhost:15021/healthz/ready; do echo \"Waiting for Istio sidecar proxy...\"; sleep 3; done && sleep 5 && echo \"Stopping the istio proxy...\" && curl -X POST http://localhost:15020/quitquitquit"` |  |
| gitlab.toolbox.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitlab-exporter.enabled | bool | `false` |  |
| gitlab.gitlab-exporter.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.gitlab-exporter.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.gitlab-exporter.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitlab-exporter.resources.limits.cpu | string | `"150m"` |  |
| gitlab.gitlab-exporter.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.resources.requests.cpu | string | `"150m"` |  |
| gitlab.gitlab-exporter.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitlab-exporter.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-exporter"` |  |
| gitlab.gitlab-exporter.image.tag | string | `"16.4.1"` |  |
| gitlab.gitlab-exporter.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.gitlab-exporter.metrics.enabled | bool | `true` |  |
| gitlab.gitlab-exporter.metrics.port | int | `9168` |  |
| gitlab.gitlab-exporter.metrics.serviceMonitor.enabled | bool | `true` |  |
| gitlab.gitlab-exporter.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.migrations.annotations."sidecar.istio.io/inject" | string | `"false"` |  |
| gitlab.migrations.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.migrations.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.migrations.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.migrations.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.migrations.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.migrations.resources.limits.cpu | string | `"500m"` |  |
| gitlab.migrations.resources.limits.memory | string | `"1G"` |  |
| gitlab.migrations.resources.requests.cpu | string | `"500m"` |  |
| gitlab.migrations.resources.requests.memory | string | `"1G"` |  |
| gitlab.migrations.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-toolbox"` |  |
| gitlab.migrations.image.tag | string | `"16.4.1"` |  |
| gitlab.migrations.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.migrations.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.webservice.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.webservice.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.webservice.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.webservice.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.webservice.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.webservice.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.webservice.resources.limits.cpu | string | `"600m"` |  |
| gitlab.webservice.resources.limits.memory | string | `"2.5G"` |  |
| gitlab.webservice.resources.requests.cpu | string | `"600m"` |  |
| gitlab.webservice.resources.requests.memory | string | `"2.5G"` |  |
| gitlab.webservice.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-webservice"` |  |
| gitlab.webservice.image.tag | string | `"16.4.1"` |  |
| gitlab.webservice.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.webservice.workhorse.resources.limits.cpu | string | `"600m"` |  |
| gitlab.webservice.workhorse.resources.limits.memory | string | `"2.5G"` |  |
| gitlab.webservice.workhorse.resources.requests.cpu | string | `"600m"` |  |
| gitlab.webservice.workhorse.resources.requests.memory | string | `"2.5G"` |  |
| gitlab.webservice.workhorse.image | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-workhorse"` |  |
| gitlab.webservice.workhorse.tag | string | `"16.4.1"` |  |
| gitlab.webservice.workhorse.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.webservice.workhorse.metrics.enabled | bool | `true` |  |
| gitlab.webservice.workhorse.metrics.serviceMonitor.enabled | bool | `true` |  |
| gitlab.webservice.workhorse.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.webservice.ingress.enabled | bool | `false` |  |
| gitlab.webservice.metrics.enabled | bool | `true` |  |
| gitlab.webservice.metrics.port | int | `8083` |  |
| gitlab.webservice.metrics.serviceMonitor.enabled | bool | `true` |  |
| gitlab.sidekiq.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-sidekiq"` |  |
| gitlab.sidekiq.image.tag | string | `"16.4.1"` |  |
| gitlab.sidekiq.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.sidekiq.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.sidekiq.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.sidekiq.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.sidekiq.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.sidekiq.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.sidekiq.resources.requests.memory | string | `"3G"` |  |
| gitlab.sidekiq.resources.requests.cpu | string | `"1500m"` |  |
| gitlab.sidekiq.resources.limits.memory | string | `"3G"` |  |
| gitlab.sidekiq.resources.limits.cpu | string | `"1500m"` |  |
| gitlab.sidekiq.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitaly.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitaly"` |  |
| gitlab.gitaly.image.tag | string | `"16.4.1"` |  |
| gitlab.gitaly.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.gitaly.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.gitaly.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitaly.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.gitaly.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitaly.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitaly.resources.requests.cpu | string | `"400m"` |  |
| gitlab.gitaly.resources.requests.memory | string | `"600Mi"` |  |
| gitlab.gitaly.resources.limits.cpu | string | `"400m"` |  |
| gitlab.gitaly.resources.limits.memory | string | `"600Mi"` |  |
| gitlab.gitaly.metrics.enabled | bool | `true` |  |
| gitlab.gitaly.metrics.serviceMonitor.enabled | bool | `true` |  |
| gitlab.gitaly.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitlab-shell.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-shell"` |  |
| gitlab.gitlab-shell.image.tag | string | `"16.4.1"` |  |
| gitlab.gitlab-shell.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.gitlab-shell.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.gitlab-shell.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitlab-shell.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.gitlab-shell.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitlab-shell.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitlab-shell.resources.limits.cpu | string | `"300m"` |  |
| gitlab.gitlab-shell.resources.limits.memory | string | `"300Mi"` |  |
| gitlab.gitlab-shell.resources.requests.cpu | string | `"300m"` |  |
| gitlab.gitlab-shell.resources.requests.memory | string | `"300Mi"` |  |
| gitlab.gitlab-shell.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.mailroom.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-mailroom"` |  |
| gitlab.mailroom.image.tag | string | `"16.4.1"` |  |
| gitlab.mailroom.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.mailroom.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.gitlab-pages.service.customDomains.type | string | `"ClusterIP"` |  |
| gitlab.gitlab-pages.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-pages"` |  |
| gitlab.gitlab-pages.image.tag | string | `"16.4.1"` |  |
| gitlab.gitlab-pages.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.praefect.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitaly"` |  |
| gitlab.praefect.image.tag | string | `"16.4.1"` |  |
| gitlab.praefect.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.praefect.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.praefect.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.praefect.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.praefect.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab.praefect.resources.requests.cpu | int | `1` |  |
| gitlab.praefect.resources.requests.memory | string | `"1Gi"` |  |
| gitlab.praefect.resources.limits.cpu | int | `1` |  |
| gitlab.praefect.resources.limits.memory | string | `"1Gi"` |  |
| gitlab.praefect.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| gitlab-zoekt.install | bool | `false` |  |
| minio.init.resources.limits.cpu | string | `"200m"` |  |
| minio.init.resources.limits.memory | string | `"200Mi"` |  |
| minio.init.resources.requests.cpu | string | `"200m"` |  |
| minio.init.resources.requests.memory | string | `"200Mi"` |  |
| minio.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| minio.resources.limits.cpu | string | `"200m"` |  |
| minio.resources.limits.memory | string | `"300Mi"` |  |
| minio.resources.requests.cpu | string | `"200m"` |  |
| minio.resources.requests.memory | string | `"300Mi"` |  |
| minio.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| minio.jobAnnotations."sidecar.istio.io/inject" | string | `"false"` |  |
| minio.image | string | `"registry1.dso.mil/ironbank/opensource/minio/minio"` |  |
| minio.imageTag | string | `"RELEASE.2022-12-12T19-27-27Z"` |  |
| minio.pullSecrets[0].name | string | `"private-registry"` |  |
| minio.minioMc.image | string | `"registry1.dso.mil/ironbank/opensource/minio/mc"` |  |
| minio.minioMc.tag | string | `"RELEASE.2022-12-24T15-21-38Z"` |  |
| minio.minioMc.pullSecrets[0].name | string | `"private-registry"` |  |
| domain | string | `"bigbang.dev"` |  |
| istio.enabled | bool | `false` |  |
| istio.injection | string | `"disabled"` |  |
| istio.gitlab.enabled | bool | `true` |  |
| istio.gitlab.annotations | object | `{}` |  |
| istio.gitlab.labels | object | `{}` |  |
| istio.gitlab.gateways[0] | string | `"istio-system/main"` |  |
| istio.gitlab.hosts | string | `nil` |  |
| istio.registry.enabled | bool | `true` |  |
| istio.registry.annotations | object | `{}` |  |
| istio.registry.labels | object | `{}` |  |
| istio.registry.gateways[0] | string | `"istio-system/main"` |  |
| istio.registry.hosts | string | `nil` |  |
| istio.pages.enabled | bool | `false` |  |
| istio.pages.annotations | object | `{}` |  |
| istio.pages.ingressLabels.app | string | `"pages-ingressgateway"` |  |
| istio.pages.ingressLabels.istio | string | `"ingressgateway"` |  |
| istio.pages.labels | object | `{}` |  |
| istio.pages.gateways[0] | string | `"istio-system/pages"` |  |
| istio.pages.customDomains.enabled | bool | `true` |  |
| istio.pages.hosts[0] | string | `"*.pages.bigbang.dev"` |  |
| istio.mtls | object | `{"mode":"STRICT"}` | Default peer authentication |
| istio.mtls.mode | string | `"STRICT"` | STRICT = Allow only mutual TLS traffic, PERMISSIVE = Allow both plain text and mutual TLS traffic |
| monitoring.enabled | bool | `false` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.ingressLabels.app | string | `"istio-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.gitalyEgress.enabled | bool | `false` |  |
| openshift | bool | `false` |  |
| use_iam_profile | bool | `false` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_baseUrl | string | `"http://gitlab-webservice-default.gitlab.svc.cluster.local:8181"` |  |
| bbtests.cypress.envs.cypress_gitlab_first_name | string | `"test"` |  |
| bbtests.cypress.envs.cypress_gitlab_last_name | string | `"user"` |  |
| bbtests.cypress.envs.cypress_gitlab_username | string | `"testuser"` |  |
| bbtests.cypress.envs.cypress_gitlab_password | string | `"Password123h56a78"` |  |
| bbtests.cypress.envs.cypress_gitlab_email | string | `"testuser@example.com"` |  |
| bbtests.cypress.envs.cypress_gitlab_project | string | `"my-awesome-project"` |  |
| bbtests.cypress.envs.cypress_keycloak_username | string | `"cypress"` |  |
| bbtests.cypress.envs.cypress_keycloak_password | string | `"tnr_w!G33ZyAt@C8"` |  |
| bbtests.cypress.secretEnvs[0].name | string | `"cypress_adminpassword"` |  |
| bbtests.cypress.secretEnvs[0].valueFrom.secretKeyRef.name | string | `"gitlab-gitlab-initial-root-password"` |  |
| bbtests.cypress.secretEnvs[0].valueFrom.secretKeyRef.key | string | `"password"` |  |
| bbtests.scripts.image | string | `"registry1.dso.mil/bigbang-ci/gitlab-tester:0.0.4"` |  |
| bbtests.scripts.envs.GITLAB_USER | string | `"testuser"` |  |
| bbtests.scripts.envs.GITLAB_PASS | string | `"Password123h56a78"` |  |
| bbtests.scripts.envs.GITLAB_EMAIL | string | `"testuser@example.com"` |  |
| bbtests.scripts.envs.GITLAB_PROJECT | string | `"my-awesome-project"` |  |
| bbtests.scripts.envs.GITLAB_REPOSITORY | string | `"http://gitlab-webservice-default.gitlab.svc.cluster.local:8181"` |  |
| bbtests.scripts.envs.GITLAB_ORIGIN | string | `"http://testuser:Password123h56a78@gitlab-webservice-default.gitlab.svc.cluster.local:8181"` |  |
| bbtests.scripts.envs.GITLAB_REGISTRY | string | `"gitlab-registry-test-svc.gitlab.svc.cluster.local:80"` |  |
| bbtests.gateway.basicAuth.enabled | bool | `true` |  |
| bbtests.gateway.basicAuth.secretName | string | `"{{ include \"gitlab.zoekt.gateway.basicAuth.secretName\" $ }}"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab-shell

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: 14.28.0](https://img.shields.io/badge/AppVersion-14.28.0-informational?style=flat-square)

sshd for Gitlab

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/gitlab-shell>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-shell>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install gitlab-shell chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-shell"` |  |
| service.name | string | `"gitlab-shell"` |  |
| service.type | string | `"ClusterIP"` |  |
| service.internalPort | int | `2222` |  |
| service.externalTrafficPolicy | string | `"Cluster"` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| priorityClassName | string | `""` |  |
| global | object | `{}` |  |
| enabled | bool | `true` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| workhorse | object | `{}` |  |
| resources.requests.cpu | int | `0` |  |
| resources.requests.memory | string | `"6M"` |  |
| maxUnavailable | int | `1` |  |
| minReplicas | int | `2` |  |
| maxReplicas | int | `10` |  |
| hpa.cpu.targetType | string | `"AverageValue"` |  |
| hpa.cpu.targetAverageValue | string | `"100m"` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| deployment.terminationGracePeriodSeconds | int | `30` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `10` |  |
| deployment.livenessProbe.periodSeconds | int | `10` |  |
| deployment.livenessProbe.timeoutSeconds | int | `3` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `10` |  |
| deployment.readinessProbe.periodSeconds | int | `5` |  |
| deployment.readinessProbe.timeoutSeconds | int | `3` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.failureThreshold | int | `2` |  |
| deployment.strategy | object | `{}` |  |
| logging.format | string | `"json"` |  |
| logging.sshdLogLevel | string | `"ERROR"` |  |
| config.clientAliveInterval | int | `0` |  |
| config.loginGraceTime | int | `60` |  |
| config.maxStartups.start | int | `10` |  |
| config.maxStartups.rate | int | `30` |  |
| config.maxStartups.full | int | `100` |  |
| config.proxyProtocol | bool | `false` |  |
| config.proxyPolicy | string | `"use"` |  |
| config.proxyHeaderTimeout | string | `"500ms"` |  |
| config.ciphers[0] | string | `"aes128-gcm@openssh.com"` |  |
| config.ciphers[1] | string | `"chacha20-poly1305@openssh.com"` |  |
| config.ciphers[2] | string | `"aes256-gcm@openssh.com"` |  |
| config.ciphers[3] | string | `"aes128-ctr"` |  |
| config.ciphers[4] | string | `"aes192-ctr"` |  |
| config.ciphers[5] | string | `"aes256-ctr"` |  |
| config.kexAlgorithms[0] | string | `"curve25519-sha256"` |  |
| config.kexAlgorithms[1] | string | `"curve25519-sha256@libssh.org"` |  |
| config.kexAlgorithms[2] | string | `"ecdh-sha2-nistp256"` |  |
| config.kexAlgorithms[3] | string | `"ecdh-sha2-nistp384"` |  |
| config.kexAlgorithms[4] | string | `"ecdh-sha2-nistp521"` |  |
| config.kexAlgorithms[5] | string | `"diffie-hellman-group14-sha256"` |  |
| config.kexAlgorithms[6] | string | `"diffie-hellman-group14-sha1"` |  |
| config.macs[0] | string | `"hmac-sha2-256-etm@openssh.com"` |  |
| config.macs[1] | string | `"hmac-sha2-512-etm@openssh.com"` |  |
| config.macs[2] | string | `"hmac-sha2-256"` |  |
| config.macs[3] | string | `"hmac-sha2-512"` |  |
| config.macs[4] | string | `"hmac-sha1"` |  |
| config.gssapi.enabled | bool | `false` |  |
| config.gssapi.libpath | string | `"libgssapi_krb5.so.2"` |  |
| config.gssapi.keytab.key | string | `"keytab"` |  |
| config.gssapi.krb5Config | string | `""` |  |
| config.gssapi.servicePrincipalName | string | `""` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| metrics.enabled | bool | `false` |  |
| metrics.port | int | `9122` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| metrics.annotations | object | `{}` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| sshDaemon | string | `"openssh"` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# webservice

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: v16.4.1](https://img.shields.io/badge/AppVersion-v16.4.1-informational?style=flat-square)

HTTP server for Gitlab

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/webservice>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-webservice>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install webservice chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| monitoring.ipWhitelist[0] | string | `"0.0.0.0/0"` |  |
| monitoring.exporter.enabled | bool | `false` |  |
| monitoring.exporter.port | int | `8083` |  |
| shutdown.blackoutSeconds | int | `10` |  |
| extraEnv | object | `{}` |  |
| extraEnvFrom | object | `{}` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| sshHostKeys.mount | bool | `false` |  |
| sshHostKeys.mountName | string | `"ssh-host-keys"` |  |
| sshHostKeys.types[0] | string | `"dsa"` |  |
| sshHostKeys.types[1] | string | `"rsa"` |  |
| sshHostKeys.types[2] | string | `"ecdsa"` |  |
| sshHostKeys.types[3] | string | `"ed25519"` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `8083` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.tls | object | `{}` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| metrics.annotations | object | `{}` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| http.enabled | bool | `true` |  |
| tls.enabled | bool | `false` |  |
| service.type | string | `"ClusterIP"` |  |
| service.externalPort | int | `8080` |  |
| service.internalPort | int | `8080` |  |
| service.workhorseExternalPort | int | `8181` |  |
| service.workhorseInternalPort | int | `8181` |  |
| service.tls.externalPort | int | `8081` |  |
| service.tls.internalPort | int | `8081` |  |
| enabled | bool | `true` |  |
| ingress.apiVersion | string | `nil` |  |
| ingress.enabled | string | `nil` |  |
| ingress.proxyConnectTimeout | int | `15` |  |
| ingress.proxyReadTimeout | int | `600` |  |
| ingress.proxyBodySize | string | `"512m"` |  |
| ingress.tls | object | `{}` |  |
| ingress.annotations."nginx.ingress.kubernetes.io/service-upstream" | string | `"true"` |  |
| ingress.configureCertmanager | string | `nil` |  |
| ingress.requireBasePath | bool | `true` |  |
| ingress.useGeoClass | bool | `false` |  |
| extraIngress.enabled | bool | `false` |  |
| extraIngress.apiVersion | string | `nil` |  |
| extraIngress.proxyConnectTimeout | int | `15` |  |
| extraIngress.proxyReadTimeout | int | `600` |  |
| extraIngress.proxyBodySize | string | `"512m"` |  |
| extraIngress.tls | object | `{}` |  |
| extraIngress.annotations."nginx.ingress.kubernetes.io/service-upstream" | string | `"true"` |  |
| extraIngress.configureCertmanager | string | `nil` |  |
| extraIngress.requireBasePath | bool | `true` |  |
| extraIngress.useGeoClass | bool | `false` |  |
| workerProcesses | int | `2` |  |
| puma.threads.min | int | `4` |  |
| puma.threads.max | int | `4` |  |
| puma.disableWorkerKiller | bool | `true` |  |
| hpa.cpu.targetType | string | `"AverageValue"` |  |
| hpa.cpu.targetAverageValue | int | `1` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| deployment.startupProbe | object | `{}` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `20` |  |
| deployment.livenessProbe.periodSeconds | int | `60` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `0` |  |
| deployment.readinessProbe.periodSeconds | int | `5` |  |
| deployment.readinessProbe.timeoutSeconds | int | `2` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.failureThreshold | int | `2` |  |
| deployment.strategy | object | `{}` |  |
| workhorse.keywatcher | bool | `true` |  |
| workhorse.sentryDSN | string | `""` |  |
| workhorse.extraArgs | string | `""` |  |
| workhorse.logFormat | string | `"json"` |  |
| workhorse.resources.requests.cpu | string | `"100m"` |  |
| workhorse.resources.requests.memory | string | `"100M"` |  |
| workhorse.containerSecurityContext | object | `{}` |  |
| workhorse.startupProbe | object | `{}` |  |
| workhorse.livenessProbe.initialDelaySeconds | int | `20` |  |
| workhorse.livenessProbe.periodSeconds | int | `60` |  |
| workhorse.livenessProbe.timeoutSeconds | int | `30` |  |
| workhorse.livenessProbe.successThreshold | int | `1` |  |
| workhorse.livenessProbe.failureThreshold | int | `3` |  |
| workhorse.readinessProbe.initialDelaySeconds | int | `0` |  |
| workhorse.readinessProbe.periodSeconds | int | `10` |  |
| workhorse.readinessProbe.timeoutSeconds | int | `2` |  |
| workhorse.readinessProbe.successThreshold | int | `1` |  |
| workhorse.readinessProbe.failureThreshold | int | `3` |  |
| workhorse.monitoring.exporter.enabled | bool | `false` |  |
| workhorse.monitoring.exporter.port | int | `9229` |  |
| workhorse.monitoring.exporter.tls | object | `{}` |  |
| workhorse.metrics.enabled | bool | `false` |  |
| workhorse.metrics.port | int | `9229` |  |
| workhorse.metrics.path | string | `"/metrics"` |  |
| workhorse.metrics.serviceMonitor.enabled | bool | `false` |  |
| workhorse.metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| workhorse.metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| workhorse.imageScaler.maxProcs | int | `2` |  |
| workhorse.imageScaler.maxFileSizeBytes | int | `250000` |  |
| workhorse.tls | object | `{}` |  |
| psql | object | `{}` |  |
| global.ingress.enabled | string | `nil` |  |
| global.ingress.annotations | object | `{}` |  |
| global.ingress.tls | object | `{}` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.gitlab | object | `{}` |  |
| global.hosts.registry | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| global.psql | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| global.minio.enabled | string | `nil` |  |
| global.minio.credentials | object | `{}` |  |
| global.webservice | object | `{}` |  |
| global.appConfig.microsoft_graph_mailer.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.address | string | `nil` |  |
| global.appConfig.serviceDeskEmail.enabled | bool | `false` |  |
| global.appConfig.serviceDeskEmail.address | string | `nil` |  |
| global.appConfig.object_store.connection | object | `{}` |  |
| global.appConfig.object_store.storage_options | object | `{}` |  |
| global.appConfig.lfs.enabled | bool | `true` |  |
| global.appConfig.lfs.proxy_download | bool | `true` |  |
| global.appConfig.lfs.bucket | string | `nil` |  |
| global.appConfig.lfs.connection | object | `{}` |  |
| global.appConfig.artifacts.enabled | bool | `true` |  |
| global.appConfig.artifacts.proxy_download | bool | `true` |  |
| global.appConfig.artifacts.bucket | string | `nil` |  |
| global.appConfig.artifacts.connection | object | `{}` |  |
| global.appConfig.uploads.enabled | bool | `true` |  |
| global.appConfig.uploads.proxy_download | bool | `true` |  |
| global.appConfig.uploads.bucket | string | `nil` |  |
| global.appConfig.uploads.connection | object | `{}` |  |
| global.appConfig.packages.enabled | bool | `true` |  |
| global.appConfig.packages.proxy_download | bool | `true` |  |
| global.appConfig.packages.bucket | string | `nil` |  |
| global.appConfig.packages.connection | object | `{}` |  |
| global.appConfig.externalDiffs.when | string | `nil` |  |
| global.appConfig.externalDiffs.proxy_download | bool | `true` |  |
| global.appConfig.externalDiffs.bucket | string | `nil` |  |
| global.appConfig.externalDiffs.connection | object | `{}` |  |
| global.appConfig.terraformState.enabled | bool | `false` |  |
| global.appConfig.terraformState.bucket | string | `nil` |  |
| global.appConfig.terraformState.connection | object | `{}` |  |
| global.appConfig.dependencyProxy.enabled | bool | `false` |  |
| global.appConfig.dependencyProxy.proxy_download | bool | `true` |  |
| global.appConfig.dependencyProxy.bucket | string | `nil` |  |
| global.appConfig.dependencyProxy.connection | object | `{}` |  |
| global.appConfig.ldap.servers | object | `{}` |  |
| global.appConfig.omniauth.enabled | bool | `false` |  |
| global.appConfig.omniauth.autoSignInWithProvider | string | `nil` |  |
| global.appConfig.omniauth.syncProfileFromProvider | list | `[]` |  |
| global.appConfig.omniauth.syncProfileAttributes[0] | string | `"email"` |  |
| global.appConfig.omniauth.allowSingleSignOn[0] | string | `"saml"` |  |
| global.appConfig.omniauth.blockAutoCreatedUsers | bool | `true` |  |
| global.appConfig.omniauth.autoLinkLdapUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkSamlUser | bool | `false` |  |
| global.appConfig.omniauth.autoLinkUser | list | `[]` |  |
| global.appConfig.omniauth.externalProviders | list | `[]` |  |
| global.appConfig.omniauth.allowBypassTwoFactor | list | `[]` |  |
| global.appConfig.omniauth.providers | list | `[]` |  |
| global.appConfig.sentry.enabled | bool | `false` |  |
| global.appConfig.sentry.dsn | string | `nil` |  |
| global.appConfig.sentry.clientside_dsn | string | `nil` |  |
| global.appConfig.sentry.environment | string | `nil` |  |
| global.appConfig.gitlab_docs.enabled | bool | `false` |  |
| global.appConfig.gitlab_docs.host | string | `""` |  |
| redis.auth | object | `{}` |  |
| gitaly.authToken | object | `{}` |  |
| minio.serviceName | string | `"minio-svc"` |  |
| minio.port | int | `9000` |  |
| extra | object | `{}` |  |
| rack_attack.git_basic_auth.enabled | bool | `false` |  |
| trusted_proxies | list | `[]` |  |
| resources.requests.cpu | string | `"300m"` |  |
| resources.requests.memory | string | `"2.5G"` |  |
| maxUnavailable | int | `1` |  |
| minReplicas | int | `2` |  |
| maxReplicas | int | `10` |  |
| helmTests.enabled | bool | `true` |  |
| webServer | string | `"puma"` |  |
| sharedTmpDir | object | `{}` |  |
| sharedUploadDir | object | `{}` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| priorityClassName | string | `""` |  |
| deployments | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab-pages

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: 16.4.1](https://img.shields.io/badge/AppVersion-16.4.1-informational?style=flat-square)

Daemon for serving static websites from GitLab projects

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/gitlab-pages>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-pages>
* <https://gitlab.com/gitlab-org/gitlab-pages>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install gitlab-pages chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.pages.enabled | bool | `false` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.minReplicas | int | `1` |  |
| hpa.cpu.targetType | string | `"AverageValue"` |  |
| hpa.cpu.targetAverageValue | string | `"100m"` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-pages"` |  |
| service.type | string | `"ClusterIP"` |  |
| service.externalPort | int | `8090` |  |
| service.internalPort | int | `8090` |  |
| service.annotations | object | `{}` |  |
| service.customDomains.type | string | `"LoadBalancer"` |  |
| service.customDomains.internalHttpsPort | int | `8091` |  |
| service.customDomains.nodePort | object | `{}` |  |
| service.customDomains.annotations | object | `{}` |  |
| service.metrics.annotations | object | `{}` |  |
| service.primary.annotations | object | `{}` |  |
| service.sessionAffinity | string | `"None"` |  |
| service.sessionAffinityConfig | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| deployment.strategy | object | `{}` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `0` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.timeoutSeconds | int | `2` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| ingress.apiVersion | string | `nil` |  |
| ingress.annotations | object | `{}` |  |
| ingress.configureCertmanager | bool | `false` |  |
| ingress.tls | object | `{}` |  |
| ingress.path | string | `nil` |  |
| tolerations | list | `[]` |  |
| cluster | bool | `true` |  |
| queueSelector | bool | `false` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| extraEnv | object | `{}` |  |
| maxUnavailable | int | `1` |  |
| resources.requests.cpu | string | `"900m"` |  |
| resources.requests.memory | string | `"2G"` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| priorityClassName | string | `""` |  |
| artifactsServerTimeout | int | `10` |  |
| artifactsServerUrl | string | `nil` |  |
| gitlabClientHttpTimeout | string | `nil` |  |
| gitlabClientJwtExpiry | string | `nil` |  |
| gitlabServer | string | `nil` |  |
| headers | list | `[]` |  |
| insecureCiphers | bool | `false` |  |
| internalGitlabServer | string | `nil` |  |
| logFormat | string | `"json"` |  |
| logVerbose | bool | `false` |  |
| maxConnections | string | `nil` |  |
| redirectHttp | bool | `false` |  |
| sentry.enabled | bool | `false` |  |
| sentry.dsn | string | `nil` |  |
| sentry.environment | string | `nil` |  |
| statusUri | string | `"/-/readiness"` |  |
| tls.minVersion | string | `nil` |  |
| tls.maxVersion | string | `nil` |  |
| useHTTPProxy | bool | `false` |  |
| useProxyV2 | bool | `false` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `9235` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.tls.enabled | bool | `false` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| metrics.annotations | object | `{}` |  |
| workhorse | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# geo-logcursor

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: v16.4.1](https://img.shields.io/badge/AppVersion-v16.4.1-informational?style=flat-square)

GitLab Geo logcursor

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/charts/gitlab/tree/master/charts/gitlab/charts/geo-logcursor>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-rails>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install geo-logcursor chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| enabled | bool | `true` |  |
| replicaCount | int | `1` |  |
| global.geo.role | string | `"primary"` |  |
| global.geo.nodeName | string | `nil` |  |
| global.geo.psql.password | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.gitlab | object | `{}` |  |
| global.hosts.registry | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| redis.auth | object | `{}` |  |
| psql | object | `{}` |  |
| gitaly.authToken | object | `{}` |  |
| minio.serviceName | string | `"minio-svc"` |  |
| minio.port | int | `9000` |  |
| resources.requests.cpu | string | `"300m"` |  |
| resources.requests.memory | string | `"700M"` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `20` |  |
| deployment.livenessProbe.periodSeconds | int | `60` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `0` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.timeoutSeconds | int | `2` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.strategy | object | `{}` |  |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| priorityClassName | string | `""` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# kas

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: v16.4.0](https://img.shields.io/badge/AppVersion-v16.4.0-informational?style=flat-square)

GitLab Agent Server

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/gitlab-kas>
* <https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install kas chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotations | object | `{}` |  |
| global.ingress | object | `{}` |  |
| global.kas.enabled | bool | `true` |  |
| global.redis.auth | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| hpa.cpu.targetType | string | `"AverageValue"` |  |
| hpa.cpu.targetAverageValue | string | `"100m"` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-kas"` |  |
| ingress.apiVersion | string | `nil` |  |
| ingress.annotations | object | `{}` |  |
| ingress.tls | object | `{}` |  |
| ingress.agentPath | string | `"/"` |  |
| ingress.k8sApiPath | string | `"/k8s-proxy"` |  |
| maxReplicas | int | `10` |  |
| maxUnavailable | int | `1` |  |
| minReplicas | int | `2` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| extraEnv | object | `{}` |  |
| extraEnvFrom | object | `{}` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"100M"` |  |
| service.externalPort | int | `8150` |  |
| service.internalPort | int | `8150` |  |
| service.apiInternalPort | int | `8153` |  |
| service.kubernetesApiPort | int | `8154` |  |
| service.privateApiPort | int | `8155` |  |
| service.type | string | `"ClusterIP"` |  |
| metrics.enabled | bool | `true` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| observability.port | int | `8151` |  |
| observability.livenessProbe.path | string | `"/liveness"` |  |
| observability.readinessProbe.path | string | `"/readiness"` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| tolerations | list | `[]` |  |
| workhorse | object | `{}` |  |
| customConfig | object | `{}` |  |
| privateApi.tls.enabled | bool | `false` |  |
| deployment.terminationGracePeriodSeconds | int | `300` |  |
| deployment.strategy | object | `{}` |  |
| securityContext.runAsUser | int | `65532` |  |
| securityContext.runAsGroup | int | `65532` |  |
| securityContext.fsGroup | int | `65532` |  |
| containerSecurityContext.runAsUser | int | `65532` |  |
| redis.enabled | bool | `true` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |
| priorityClassName | string | `""` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# minio

![Version: 0.4.3](https://img.shields.io/badge/Version-0.4.3-informational?style=flat-square) ![AppVersion: RELEASE.2017-12-28T01-21-00Z](https://img.shields.io/badge/AppVersion-RELEASE.2017--12--28T01--21--00Z-informational?style=flat-square)

Object storage server built for cloud applications and devops.

## Upstream References
* <https://minio.io>

* <https://gitlab.com/gitlab-org/charts/gitlab/charts/minio>
* <https://github.com/minio/minio>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install minio chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image | string | `"minio/minio"` |  |
| imageTag | string | `"RELEASE.2017-12-28T01-21-00Z"` |  |
| minioMc.image | string | `"minio/mc"` |  |
| minioMc.tag | string | `"RELEASE.2018-07-13T00-53-22Z"` |  |
| ingress.apiVersion | string | `nil` |  |
| ingress.enabled | string | `nil` |  |
| ingress.proxyReadTimeout | int | `900` |  |
| ingress.proxyBodySize | string | `"0"` |  |
| ingress.proxyBuffering | string | `"off"` |  |
| ingress.tls | object | `{}` |  |
| ingress.annotations | object | `{}` |  |
| ingress.configureCertmanager | string | `nil` |  |
| ingress.path | string | `nil` |  |
| tolerations | list | `[]` |  |
| priorityClassName | string | `""` |  |
| global.ingress.enabled | string | `nil` |  |
| global.ingress.annotations | object | `{}` |  |
| global.ingress.tls | object | `{}` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.tls | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| global.minio.enabled | bool | `true` |  |
| common.labels | object | `{}` |  |
| init.image | object | `{}` |  |
| init.script | string | `"sed -e 's@ACCESS_KEY@'\"$(cat /config/accesskey)\"'@' -e 's@SECRET_KEY@'\"$(cat /config/secretkey)\"'@' /config/config.json > /minio/config.json"` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| configPath | string | `""` |  |
| mountPath | string | `"/export"` |  |
| replicas | int | `4` |  |
| persistence.enabled | bool | `true` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.size | string | `"10Gi"` |  |
| persistence.subPath | string | `""` |  |
| persistence.matchLabels | object | `{}` |  |
| persistence.matchExpressions | list | `[]` |  |
| serviceType | string | `"ClusterIP"` |  |
| servicePort | int | `9000` |  |
| nodeSelector | object | `{}` |  |
| resources.requests.memory | string | `"128Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| jobAnnotations | object | `{}` |  |
| defaultBuckets[0].name | string | `"registry"` |  |
| defaultBuckets[1].name | string | `"git-lfs"` |  |
| defaultBuckets[2].name | string | `"runner-cache"` |  |
| defaultBuckets[3].name | string | `"gitlab-uploads"` |  |
| defaultBuckets[4].name | string | `"gitlab-artifacts"` |  |
| defaultBuckets[5].name | string | `"gitlab-backups"` |  |
| defaultBuckets[6].name | string | `"gitlab-packages"` |  |
| defaultBuckets[7].name | string | `"tmp"` |  |
| defaultBuckets[8].name | string | `"gitlab-mr-diffs"` |  |
| defaultBuckets[9].name | string | `"gitlab-terraform-state"` |  |
| defaultBuckets[10].name | string | `"gitlab-ci-secure-files"` |  |
| defaultBuckets[11].name | string | `"gitlab-dependency-proxy"` |  |
| defaultBuckets[12].name | string | `"gitlab-pages"` |  |
| minioConfig.region | string | `"us-east-1"` |  |
| minioConfig.browser | string | `"on"` |  |
| minioConfig.domain | string | `""` |  |
| minioConfig.logger.console.enable | bool | `true` |  |
| minioConfig.logger.file.enable | bool | `false` |  |
| minioConfig.logger.file.filename | string | `""` |  |
| minioConfig.aqmp.enable | bool | `false` |  |
| minioConfig.aqmp.url | string | `""` |  |
| minioConfig.aqmp.exchange | string | `""` |  |
| minioConfig.aqmp.routingKey | string | `""` |  |
| minioConfig.aqmp.exchangeType | string | `""` |  |
| minioConfig.aqmp.deliveryMode | int | `0` |  |
| minioConfig.aqmp.mandatory | bool | `false` |  |
| minioConfig.aqmp.immediate | bool | `false` |  |
| minioConfig.aqmp.durable | bool | `false` |  |
| minioConfig.aqmp.internal | bool | `false` |  |
| minioConfig.aqmp.noWait | bool | `false` |  |
| minioConfig.aqmp.autoDeleted | bool | `false` |  |
| minioConfig.nats.enable | bool | `false` |  |
| minioConfig.nats.address | string | `""` |  |
| minioConfig.nats.subject | string | `""` |  |
| minioConfig.nats.username | string | `""` |  |
| minioConfig.nats.password | string | `""` |  |
| minioConfig.nats.token | string | `""` |  |
| minioConfig.nats.secure | bool | `false` |  |
| minioConfig.nats.pingInterval | int | `0` |  |
| minioConfig.nats.enableStreaming | bool | `false` |  |
| minioConfig.nats.clusterID | string | `""` |  |
| minioConfig.nats.clientID | string | `""` |  |
| minioConfig.nats.async | bool | `false` |  |
| minioConfig.nats.maxPubAcksInflight | int | `0` |  |
| minioConfig.elasticsearch.enable | bool | `false` |  |
| minioConfig.elasticsearch.format | string | `"namespace"` |  |
| minioConfig.elasticsearch.url | string | `""` |  |
| minioConfig.elasticsearch.index | string | `""` |  |
| minioConfig.redis.enable | bool | `false` |  |
| minioConfig.redis.format | string | `"namespace"` |  |
| minioConfig.redis.address | string | `""` |  |
| minioConfig.redis.password | string | `""` |  |
| minioConfig.redis.key | string | `""` |  |
| minioConfig.postgresql.enable | bool | `false` |  |
| minioConfig.postgresql.format | string | `"namespace"` |  |
| minioConfig.postgresql.connectionString | string | `""` |  |
| minioConfig.postgresql.table | string | `""` |  |
| minioConfig.postgresql.host | string | `""` |  |
| minioConfig.postgresql.port | string | `""` |  |
| minioConfig.postgresql.user | string | `""` |  |
| minioConfig.postgresql.password | string | `""` |  |
| minioConfig.postgresql.database | string | `""` |  |
| minioConfig.kafka.enable | bool | `false` |  |
| minioConfig.kafka.brokers | string | `"null"` |  |
| minioConfig.kafka.topic | string | `""` |  |
| minioConfig.webhook.enable | bool | `false` |  |
| minioConfig.webhook.endpoint | string | `""` |  |
| minioConfig.mysql.enable | bool | `false` |  |
| minioConfig.mysql.format | string | `"namespace"` |  |
| minioConfig.mysql.dsnString | string | `""` |  |
| minioConfig.mysql.table | string | `""` |  |
| minioConfig.mysql.host | string | `""` |  |
| minioConfig.mysql.port | string | `""` |  |
| minioConfig.mysql.user | string | `""` |  |
| minioConfig.mysql.password | string | `""` |  |
| minioConfig.mysql.database | string | `""` |  |
| minioConfig.mqtt.enable | bool | `false` |  |
| minioConfig.mqtt.broker | string | `""` |  |
| minioConfig.mqtt.topic | string | `""` |  |
| minioConfig.mqtt.qos | int | `0` |  |
| minioConfig.mqtt.clientId | string | `""` |  |
| minioConfig.mqtt.username | string | `""` |  |
| minioConfig.mqtt.password | string | `""` |  |
| networkPolicy.enabled | bool | `false` |  |
| networkPolicy.allowExternal | bool | `true` |  |
| maxUnavailable | int | `1` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| deployment.strategy.type | string | `"Recreate"` |  |
| deployment.strategy.rollingUpdate | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# certmanager-issuer

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: 0.2.2](https://img.shields.io/badge/AppVersion-0.2.2-informational?style=flat-square)

Configuration Job to add LetsEncrypt Issuer to cert-manager

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/certmanager-issuer>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/kubectl>
* <https://github.com/jetstack/cert-manager>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install certmanager-issuer chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| server | string | `"https://acme-v02.api.letsencrypt.org/directory"` |  |
| rbac.create | bool | `true` |  |
| resources.requests.cpu | string | `"50m"` |  |
| priorityClassName | string | `""` |  |
| common.labels | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitaly

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: 16.4.1](https://img.shields.io/badge/AppVersion-16.4.1-informational?style=flat-square)

Git RPC service for handling all the git calls made by GitLab

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/gitaly>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitaly>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install gitaly chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.gitaly.enabled | bool | `true` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| global.gitaly.hooks | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| gitaly | object | `{}` |  |
| internal | object | `{}` |  |
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitaly"` |  |
| service.tls | object | `{}` |  |
| annotations | object | `{}` |  |
| common.labels | object | `{}` |  |
| podLabels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| logging.format | string | `"json"` |  |
| git | object | `{}` |  |
| prometheus | object | `{}` |  |
| workhorse | object | `{}` |  |
| shell.authToken | object | `{}` |  |
| shell.concurrency | list | `[]` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `9236` |  |
| metrics.path | string | `"/metrics"` |  |
| metrics.serviceMonitor.enabled | bool | `false` |  |
| metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| metrics.serviceMonitor.endpointConfig | object | `{}` |  |
| metrics.metricsPort | string | `nil` |  |
| persistence.enabled | bool | `true` |  |
| persistence.accessMode | string | `"ReadWriteOnce"` |  |
| persistence.size | string | `"50Gi"` |  |
| persistence.subPath | string | `""` |  |
| persistence.matchLabels | object | `{}` |  |
| persistence.matchExpressions | list | `[]` |  |
| persistence.annotations | object | `{}` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"200Mi"` |  |
| maxUnavailable | int | `1` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| statefulset.strategy | object | `{}` |  |
| statefulset.livenessProbe.initialDelaySeconds | int | `30` |  |
| statefulset.livenessProbe.periodSeconds | int | `10` |  |
| statefulset.livenessProbe.timeoutSeconds | int | `3` |  |
| statefulset.livenessProbe.successThreshold | int | `1` |  |
| statefulset.livenessProbe.failureThreshold | int | `3` |  |
| statefulset.readinessProbe.initialDelaySeconds | int | `10` |  |
| statefulset.readinessProbe.periodSeconds | int | `10` |  |
| statefulset.readinessProbe.timeoutSeconds | int | `3` |  |
| statefulset.readinessProbe.successThreshold | int | `1` |  |
| statefulset.readinessProbe.failureThreshold | int | `3` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |
| packObjectsCache | object | `{}` |  |
| gpgSigning | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# mailroom

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: v16.4.1](https://img.shields.io/badge/AppVersion-v16.4.1-informational?style=flat-square)

Handling incoming emails

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/mailroom>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-mailroom>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install mailroom chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-mailroom"` |  |
| enabled | bool | `true` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| init.containerSecurityContext | object | `{}` |  |
| tolerations | list | `[]` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| workhorse | object | `{}` |  |
| global.redis.auth | object | `{}` |  |
| global.appConfig.incomingEmail.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.address | string | `nil` |  |
| global.appConfig.incomingEmail.host | string | `nil` |  |
| global.appConfig.incomingEmail.port | int | `993` |  |
| global.appConfig.incomingEmail.ssl | bool | `true` |  |
| global.appConfig.incomingEmail.startTls | bool | `false` |  |
| global.appConfig.incomingEmail.user | string | `nil` |  |
| global.appConfig.incomingEmail.password.secret | string | `""` |  |
| global.appConfig.incomingEmail.password.key | string | `"password"` |  |
| global.appConfig.incomingEmail.deleteAfterDelivery | bool | `true` |  |
| global.appConfig.incomingEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.incomingEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.incomingEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.incomingEmail.idleTimeout | int | `60` |  |
| global.appConfig.incomingEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.incomingEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.incomingEmail.pollInterval | int | `60` |  |
| global.appConfig.incomingEmail.deliveryMethod | string | `"webhook"` |  |
| global.appConfig.incomingEmail.authToken.secret | string | `""` |  |
| global.appConfig.incomingEmail.authToken.key | string | `"authToken"` |  |
| global.appConfig.serviceDeskEmail.enabled | bool | `false` |  |
| global.appConfig.serviceDeskEmail.address | string | `nil` |  |
| global.appConfig.serviceDeskEmail.host | string | `nil` |  |
| global.appConfig.serviceDeskEmail.port | int | `993` |  |
| global.appConfig.serviceDeskEmail.ssl | bool | `true` |  |
| global.appConfig.serviceDeskEmail.startTls | bool | `false` |  |
| global.appConfig.serviceDeskEmail.user | string | `nil` |  |
| global.appConfig.serviceDeskEmail.password.secret | string | `""` |  |
| global.appConfig.serviceDeskEmail.password.key | string | `"password"` |  |
| global.appConfig.serviceDeskEmail.deleteAfterDelivery | bool | `true` |  |
| global.appConfig.serviceDeskEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.serviceDeskEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.serviceDeskEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.serviceDeskEmail.idleTimeout | int | `60` |  |
| global.appConfig.serviceDeskEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.serviceDeskEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.serviceDeskEmail.pollInterval | int | `60` |  |
| global.appConfig.serviceDeskEmail.deliveryMethod | string | `"webhook"` |  |
| global.appConfig.serviceDeskEmail.authToken.secret | string | `""` |  |
| global.appConfig.serviceDeskEmail.authToken.key | string | `"authToken"` |  |
| hpa.minReplicas | int | `1` |  |
| hpa.maxReplicas | int | `2` |  |
| hpa.cpu.targetType | string | `"Utilization"` |  |
| hpa.cpu.targetAverageUtilization | int | `75` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| redis.auth | object | `{}` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"150M"` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| containerSecurityContext.runAsUser | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| deployment.strategy | object | `{}` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |
| priorityClassName | string | `""` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# spamcheck

![Version: 7.4.1](https://img.shields.io/badge/Version-7.4.1-informational?style=flat-square) ![AppVersion: 1.2.3](https://img.shields.io/badge/AppVersion-1.2.3-informational?style=flat-square)

GitLab Anti-Spam Engine

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/spamcheck>
* <https://gitlab.com/gitlab-org/spamcheck>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install spamcheck chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotations | object | `{}` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.minReplicas | int | `1` |  |
| hpa.cpu.targetType | string | `"AverageValue"` |  |
| hpa.cpu.targetAverageValue | string | `"100m"` |  |
| hpa.customMetrics | list | `[]` |  |
| hpa.behavior.scaleDown.stabilizationWindowSeconds | int | `300` |  |
| keda.enabled | bool | `false` |  |
| keda.pollingInterval | int | `30` |  |
| keda.cooldownPeriod | int | `300` |  |
| image.repository | string | `"registry.gitlab.com/gitlab-com/gl-security/engineering-and-research/automation-team/spam/spamcheck"` |  |
| service.type | string | `"ClusterIP"` |  |
| service.externalPort | int | `8001` |  |
| service.internalPort | int | `8001` |  |
| deployment.livenessProbe.initialDelaySeconds | int | `20` |  |
| deployment.livenessProbe.periodSeconds | int | `60` |  |
| deployment.livenessProbe.timeoutSeconds | int | `30` |  |
| deployment.livenessProbe.successThreshold | int | `1` |  |
| deployment.livenessProbe.failureThreshold | int | `3` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `0` |  |
| deployment.readinessProbe.periodSeconds | int | `10` |  |
| deployment.readinessProbe.timeoutSeconds | int | `2` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.strategy | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| logging.level | string | `"info"` |  |
| maxUnavailable | int | `1` |  |
| priorityClassName | string | `""` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"100M"` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| tolerations | list | `[]` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| affinity.podAntiAffinity.topologyKey | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# nginx-ingress

![Version: 4.0.6](https://img.shields.io/badge/Version-4.0.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.4](https://img.shields.io/badge/AppVersion-1.0.4-informational?style=flat-square)

Ingress controller for Kubernetes using NGINX as a reverse proxy and load balancer

## Upstream References
* <https://github.com/kubernetes/ingress-nginx>

* <https://github.com/kubernetes/ingress-nginx>
* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/nginx-ingress>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Kubernetes: `>=1.19.0-0`

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install nginx-ingress chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| controller.name | string | `"controller"` |  |
| controller.image.registry | string | `"registry.gitlab.com"` |  |
| controller.image.image | string | `"gitlab-org/cloud-native/mirror/images/ingress-nginx/controller"` |  |
| controller.image.tag | string | `"v1.3.1"` |  |
| controller.image.digest | string | `"sha256:54f7fe2c6c5a9db9a0ebf1131797109bb7a4d91f56b9b362bde2abd237dd1974"` |  |
| controller.image.pullPolicy | string | `"IfNotPresent"` |  |
| controller.image.runAsUser | int | `101` |  |
| controller.image.allowPrivilegeEscalation | bool | `true` |  |
| controller.existingPsp | string | `""` |  |
| controller.containerName | string | `"controller"` |  |
| controller.containerPort.http | int | `80` |  |
| controller.containerPort.https | int | `443` |  |
| controller.config | object | `{}` |  |
| controller.configAnnotations | object | `{}` |  |
| controller.proxySetHeaders | object | `{}` |  |
| controller.addHeaders | object | `{}` |  |
| controller.dnsConfig | object | `{}` |  |
| controller.hostname | object | `{}` |  |
| controller.dnsPolicy | string | `"ClusterFirst"` |  |
| controller.reportNodeInternalIp | bool | `false` |  |
| controller.watchIngressWithoutClass | bool | `false` |  |
| controller.ingressClassByName | bool | `false` |  |
| controller.allowSnippetAnnotations | bool | `true` |  |
| controller.hostNetwork | bool | `false` |  |
| controller.hostPort.enabled | bool | `false` |  |
| controller.hostPort.ports.http | int | `80` |  |
| controller.hostPort.ports.https | int | `443` |  |
| controller.electionID | string | `"ingress-controller-leader"` |  |
| controller.ingressClassResource.name | string | `"nginx"` |  |
| controller.ingressClassResource.enabled | bool | `true` |  |
| controller.ingressClassResource.default | bool | `false` |  |
| controller.ingressClassResource.controllerValue | string | `"k8s.io/ingress-nginx"` |  |
| controller.ingressClassResource.parameters | object | `{}` |  |
| controller.podLabels | object | `{}` |  |
| controller.podSecurityContext | object | `{}` |  |
| controller.sysctls | object | `{}` |  |
| controller.publishService.enabled | bool | `true` |  |
| controller.publishService.pathOverride | string | `""` |  |
| controller.scope.enabled | bool | `false` |  |
| controller.scope.namespace | string | `""` |  |
| controller.configMapNamespace | string | `""` |  |
| controller.tcp.configMapNamespace | string | `""` |  |
| controller.tcp.annotations | object | `{}` |  |
| controller.udp.configMapNamespace | string | `""` |  |
| controller.udp.annotations | object | `{}` |  |
| controller.maxmindLicenseKey | string | `""` |  |
| controller.extraArgs | object | `{}` |  |
| controller.extraEnvs | list | `[]` |  |
| controller.kind | string | `"Deployment"` |  |
| controller.annotations | object | `{}` |  |
| controller.labels | object | `{}` |  |
| controller.updateStrategy | object | `{}` |  |
| controller.minReadySeconds | int | `0` |  |
| controller.tolerations | list | `[]` |  |
| controller.affinity | object | `{}` |  |
| controller.topologySpreadConstraints | list | `[]` |  |
| controller.terminationGracePeriodSeconds | int | `300` |  |
| controller.livenessProbe.httpGet.path | string | `"/healthz"` |  |
| controller.livenessProbe.httpGet.port | int | `10254` |  |
| controller.livenessProbe.httpGet.scheme | string | `"HTTP"` |  |
| controller.livenessProbe.initialDelaySeconds | int | `10` |  |
| controller.livenessProbe.periodSeconds | int | `10` |  |
| controller.livenessProbe.timeoutSeconds | int | `1` |  |
| controller.livenessProbe.successThreshold | int | `1` |  |
| controller.livenessProbe.failureThreshold | int | `5` |  |
| controller.readinessProbe.httpGet.path | string | `"/healthz"` |  |
| controller.readinessProbe.httpGet.port | int | `10254` |  |
| controller.readinessProbe.httpGet.scheme | string | `"HTTP"` |  |
| controller.readinessProbe.initialDelaySeconds | int | `10` |  |
| controller.readinessProbe.periodSeconds | int | `10` |  |
| controller.readinessProbe.timeoutSeconds | int | `1` |  |
| controller.readinessProbe.successThreshold | int | `1` |  |
| controller.readinessProbe.failureThreshold | int | `3` |  |
| controller.healthCheckPath | string | `"/healthz"` |  |
| controller.healthCheckHost | string | `""` |  |
| controller.podAnnotations | object | `{}` |  |
| controller.replicaCount | int | `1` |  |
| controller.minAvailable | int | `1` |  |
| controller.resources.requests.cpu | string | `"100m"` |  |
| controller.resources.requests.memory | string | `"90Mi"` |  |
| controller.autoscaling.enabled | bool | `false` |  |
| controller.autoscaling.minReplicas | int | `1` |  |
| controller.autoscaling.maxReplicas | int | `11` |  |
| controller.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| controller.autoscaling.targetMemoryUtilizationPercentage | int | `50` |  |
| controller.autoscaling.behavior | object | `{}` |  |
| controller.autoscalingTemplate | list | `[]` |  |
| controller.keda.apiVersion | string | `"keda.sh/v1alpha1"` |  |
| controller.keda.enabled | bool | `false` |  |
| controller.keda.minReplicas | int | `1` |  |
| controller.keda.maxReplicas | int | `11` |  |
| controller.keda.pollingInterval | int | `30` |  |
| controller.keda.cooldownPeriod | int | `300` |  |
| controller.keda.restoreToOriginalReplicaCount | bool | `false` |  |
| controller.keda.scaledObject.annotations | object | `{}` |  |
| controller.keda.triggers | list | `[]` |  |
| controller.keda.behavior | object | `{}` |  |
| controller.enableMimalloc | bool | `true` |  |
| controller.customTemplate.configMapName | string | `""` |  |
| controller.customTemplate.configMapKey | string | `""` |  |
| controller.service.enabled | bool | `true` |  |
| controller.service.annotations | object | `{}` |  |
| controller.service.labels | object | `{}` |  |
| controller.service.externalIPs | list | `[]` |  |
| controller.service.loadBalancerSourceRanges | list | `[]` |  |
| controller.service.enableHttp | bool | `true` |  |
| controller.service.enableHttps | bool | `true` |  |
| controller.service.enableShell | bool | `true` |  |
| controller.service.ipFamilyPolicy | string | `"SingleStack"` |  |
| controller.service.ipFamilies[0] | string | `"IPv4"` |  |
| controller.service.ports.http | int | `80` |  |
| controller.service.ports.https | int | `443` |  |
| controller.service.targetPorts.http | string | `"http"` |  |
| controller.service.targetPorts.https | string | `"https"` |  |
| controller.service.type | string | `"LoadBalancer"` |  |
| controller.service.nodePorts.http | string | `""` |  |
| controller.service.nodePorts.https | string | `""` |  |
| controller.service.nodePorts.tcp | object | `{}` |  |
| controller.service.nodePorts.udp | object | `{}` |  |
| controller.service.internal.enabled | bool | `false` |  |
| controller.service.internal.annotations | object | `{}` |  |
| controller.service.internal.enableShell | bool | `false` |  |
| controller.service.internal.loadBalancerSourceRanges | list | `[]` |  |
| controller.extraContainers | list | `[]` |  |
| controller.extraVolumeMounts | list | `[]` |  |
| controller.extraVolumes | list | `[]` |  |
| controller.extraInitContainers | list | `[]` |  |
| controller.admissionWebhooks.annotations | object | `{}` |  |
| controller.admissionWebhooks.enabled | bool | `true` |  |
| controller.admissionWebhooks.failurePolicy | string | `"Fail"` |  |
| controller.admissionWebhooks.port | int | `8443` |  |
| controller.admissionWebhooks.certificate | string | `"/usr/local/certificates/cert"` |  |
| controller.admissionWebhooks.key | string | `"/usr/local/certificates/key"` |  |
| controller.admissionWebhooks.namespaceSelector | object | `{}` |  |
| controller.admissionWebhooks.objectSelector | object | `{}` |  |
| controller.admissionWebhooks.existingPsp | string | `""` |  |
| controller.admissionWebhooks.service.annotations | object | `{}` |  |
| controller.admissionWebhooks.service.externalIPs | list | `[]` |  |
| controller.admissionWebhooks.service.loadBalancerSourceRanges | list | `[]` |  |
| controller.admissionWebhooks.service.servicePort | int | `443` |  |
| controller.admissionWebhooks.service.type | string | `"ClusterIP"` |  |
| controller.admissionWebhooks.createSecretJob.resources | object | `{}` |  |
| controller.admissionWebhooks.patchWebhookJob.resources | object | `{}` |  |
| controller.admissionWebhooks.patch.enabled | bool | `true` |  |
| controller.admissionWebhooks.patch.image.registry | string | `"registry.k8s.io"` |  |
| controller.admissionWebhooks.patch.image.image | string | `"ingress-nginx/kube-webhook-certgen"` |  |
| controller.admissionWebhooks.patch.image.tag | string | `"v1.1.1"` |  |
| controller.admissionWebhooks.patch.image.digest | string | `"sha256:64d8c73dca984af206adf9d6d7e46aa550362b1d7a01f3a0a91b20cc67868660"` |  |
| controller.admissionWebhooks.patch.image.pullPolicy | string | `"IfNotPresent"` |  |
| controller.admissionWebhooks.patch.priorityClassName | string | `""` |  |
| controller.admissionWebhooks.patch.podAnnotations | object | `{}` |  |
| controller.admissionWebhooks.patch.tolerations | list | `[]` |  |
| controller.admissionWebhooks.patch.runAsUser | int | `2000` |  |
| controller.metrics.port | int | `10254` |  |
| controller.metrics.enabled | bool | `false` |  |
| controller.metrics.service.annotations | object | `{}` |  |
| controller.metrics.service.externalIPs | list | `[]` |  |
| controller.metrics.service.loadBalancerSourceRanges | list | `[]` |  |
| controller.metrics.service.servicePort | int | `10254` |  |
| controller.metrics.service.type | string | `"ClusterIP"` |  |
| controller.metrics.serviceMonitor.enabled | bool | `false` |  |
| controller.metrics.serviceMonitor.additionalLabels | object | `{}` |  |
| controller.metrics.serviceMonitor.namespace | string | `""` |  |
| controller.metrics.serviceMonitor.namespaceSelector | object | `{}` |  |
| controller.metrics.serviceMonitor.scrapeInterval | string | `"30s"` |  |
| controller.metrics.serviceMonitor.targetLabels | list | `[]` |  |
| controller.metrics.serviceMonitor.metricRelabelings | list | `[]` |  |
| controller.metrics.prometheusRule.enabled | bool | `false` |  |
| controller.metrics.prometheusRule.additionalLabels | object | `{}` |  |
| controller.metrics.prometheusRule.rules | list | `[]` |  |
| controller.lifecycle.preStop.exec.command[0] | string | `"/wait-shutdown"` |  |
| controller.priorityClassName | string | `""` |  |
| revisionHistoryLimit | int | `10` |  |
| defaultBackend.enabled | bool | `false` |  |
| defaultBackend.name | string | `"defaultbackend"` |  |
| defaultBackend.image.repository | string | `"registry.gitlab.com/gitlab-org/cloud-native/mirror/images/defaultbackend-amd64"` |  |
| defaultBackend.image.tag | string | `"1.5"` |  |
| defaultBackend.image.digest | string | `"sha256:4dc5e07c8ca4e23bddb3153737d7b8c556e5fb2f29c4558b7cd6e6df99c512c7"` |  |
| defaultBackend.image.pullPolicy | string | `"IfNotPresent"` |  |
| defaultBackend.image.runAsUser | int | `65534` |  |
| defaultBackend.image.runAsNonRoot | bool | `true` |  |
| defaultBackend.image.readOnlyRootFilesystem | bool | `true` |  |
| defaultBackend.image.allowPrivilegeEscalation | bool | `false` |  |
| defaultBackend.existingPsp | string | `""` |  |
| defaultBackend.extraArgs | object | `{}` |  |
| defaultBackend.serviceAccount.create | bool | `true` |  |
| defaultBackend.serviceAccount.name | string | `""` |  |
| defaultBackend.serviceAccount.automountServiceAccountToken | bool | `true` |  |
| defaultBackend.extraEnvs | list | `[]` |  |
| defaultBackend.port | int | `8080` |  |
| defaultBackend.livenessProbe.failureThreshold | int | `3` |  |
| defaultBackend.livenessProbe.initialDelaySeconds | int | `30` |  |
| defaultBackend.livenessProbe.periodSeconds | int | `10` |  |
| defaultBackend.livenessProbe.successThreshold | int | `1` |  |
| defaultBackend.livenessProbe.timeoutSeconds | int | `5` |  |
| defaultBackend.readinessProbe.failureThreshold | int | `6` |  |
| defaultBackend.readinessProbe.initialDelaySeconds | int | `0` |  |
| defaultBackend.readinessProbe.periodSeconds | int | `5` |  |
| defaultBackend.readinessProbe.successThreshold | int | `1` |  |
| defaultBackend.readinessProbe.timeoutSeconds | int | `5` |  |
| defaultBackend.tolerations | list | `[]` |  |
| defaultBackend.affinity | object | `{}` |  |
| defaultBackend.podSecurityContext | object | `{}` |  |
| defaultBackend.podLabels | object | `{}` |  |
| defaultBackend.podAnnotations | object | `{}` |  |
| defaultBackend.replicaCount | int | `1` |  |
| defaultBackend.minAvailable | int | `1` |  |
| defaultBackend.resources | object | `{}` |  |
| defaultBackend.extraVolumeMounts | list | `[]` |  |
| defaultBackend.extraVolumes | list | `[]` |  |
| defaultBackend.autoscaling.annotations | object | `{}` |  |
| defaultBackend.autoscaling.enabled | bool | `false` |  |
| defaultBackend.autoscaling.minReplicas | int | `1` |  |
| defaultBackend.autoscaling.maxReplicas | int | `2` |  |
| defaultBackend.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| defaultBackend.autoscaling.targetMemoryUtilizationPercentage | int | `50` |  |
| defaultBackend.autoscaling.behavior | object | `{}` |  |
| defaultBackend.service.annotations | object | `{}` |  |
| defaultBackend.service.externalIPs | list | `[]` |  |
| defaultBackend.service.loadBalancerSourceRanges | list | `[]` |  |
| defaultBackend.service.servicePort | int | `80` |  |
| defaultBackend.service.type | string | `"ClusterIP"` |  |
| defaultBackend.priorityClassName | string | `""` |  |
| rbac.create | bool | `true` |  |
| rbac.scope | bool | `false` |  |
| podSecurityPolicy.enabled | bool | `false` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| imagePullSecrets | list | `[]` |  |
| tcp | object | `{}` |  |
| udp | object | `{}` |  |
| dhParam | string | `nil` |  |
| tcpExternalConfig | string | `""` |  |
| common.labels | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![AppVersion: master](https://img.shields.io/badge/AppVersion-master-informational?style=flat-square)

Web-based Git-repository manager with wiki and issue-tracking features.

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab>

## Learn More
* [Application Overview](docs/overview.md)
* [Other Documentation](docs/)

## Pre-Requisites

* Kubernetes Cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

* Clone down the repository
* cd into directory
```bash
helm install gitlab chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.edition | string | `"ee"` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.https | bool | `true` |  |
| global.enterpriseImages.migrations.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee"` |  |
| global.enterpriseImages.sidekiq.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ee"` |  |
| global.enterpriseImages.toolbox.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee"` |  |
| global.enterpriseImages.webservice.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ee"` |  |
| global.enterpriseImages.workhorse.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ee"` |  |
| global.enterpriseImages.geo-logcursor.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-geo-logcursor"` |  |
| global.communityImages.migrations.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ce"` |  |
| global.communityImages.sidekiq.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ce"` |  |
| global.communityImages.toolbox.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ce"` |  |
| global.communityImages.webservice.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ce"` |  |
| global.communityImages.workhorse.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ce"` |  |
| global.psql.knownDecompositions[0] | string | `"main"` |  |
| global.psql.knownDecompositions[1] | string | `"ci"` |  |
| global.psql.knownDecompositions[2] | string | `"embedding"` |  |
| gitlab-runner.enabled | bool | `false` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
