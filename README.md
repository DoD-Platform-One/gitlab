<!-- Warning: Do not manually edit this file. See notes on gluon + helm-docs at the end of this file for more information. -->
# gitlab

![Version: 9.4.2-bb.0](https://img.shields.io/badge/Version-9.4.2--bb.0-informational?style=flat-square) ![AppVersion: 18.4.2](https://img.shields.io/badge/AppVersion-18.4.2-informational?style=flat-square) ![Maintenance Track: bb_integrated](https://img.shields.io/badge/Maintenance_Track-bb_integrated-green?style=flat-square)

GitLab is the most comprehensive AI-powered DevSecOps Platform.

## Upstream References

- <https://about.gitlab.com/>
- <https://gitlab.com/gitlab-org/charts/gitlab>

## Upstream Release Notes

The [upstream chart's release notes](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/CHANGELOG.md) may help when reviewing this package.

## Learn More

- [Application Overview](docs/overview.md)
- [Other Documentation](docs/)

## Pre-Requisites

- Kubernetes Cluster deployed
- Kubernetes config installed in `~/.kube/config`
- Helm installed

Install Helm

https://helm.sh/docs/intro/install/

## Deployment

- Clone down the repository
- cd into directory

```bash
helm install gitlab chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.hosts.domain | string | `"dev.bigbang.mil"` |  |
| global.hosts.gitlab.name | string | `"gitlab.dev.bigbang.mil"` |  |
| global.hosts.registry.name | string | `"registry.dev.bigbang.mil"` |  |
| global.ingress.configureCertmanager | bool | `false` |  |
| global.hpa.apiVersion | string | `"autoscaling/v2"` |  |
| global.pdb.apiVersion | string | `"policy/v1"` |  |
| global.batch.cronJob.apiVersion | string | `"batch/v1"` |  |
| global.redis.auth.enabled | bool | `true` |  |
| global.redis.securityContext.runAsUser | int | `1001` |  |
| global.redis.securityContext.fsGroup | int | `1001` |  |
| global.redis.securityContext.runAsNonRoot | bool | `true` |  |
| global.redis.containerSecurityContext.enabled | bool | `true` |  |
| global.redis.containerSecurityContext.runAsUser | int | `1001` |  |
| global.redis.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| global.redis.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| global.minio.enabled | bool | `true` |  |
| global.minio.credentials | object | `{}` |  |
| global.appConfig.defaultCanCreateGroup | bool | `false` |  |
| global.appConfig.omniauth.enabled | bool | `false` |  |
| global.kas.enabled | bool | `false` |  |
| global.certificates.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/certificates"` |  |
| global.certificates.image.tag | string | `"18.4.2"` |  |
| global.certificates.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.certificates.init.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| global.certificates.init.securityContext.runAsUser | int | `65534` |  |
| global.certificates.init.securityContext.runAsNonRoot | bool | `true` |  |
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
| global.certificates.customCAs[13].secret | string | `"ca-certs-entrust-federal-ssp-trust-chain-3"` |  |
| global.certificates.customCAs[14].secret | string | `"ca-certs-entrust-managed-service-nfi"` |  |
| global.certificates.customCAs[15].secret | string | `"ca-certs-exostar-llc"` |  |
| global.certificates.customCAs[16].secret | string | `"ca-certs-identrust-nfi"` |  |
| global.certificates.customCAs[17].secret | string | `"ca-certs-lockheed-martin"` |  |
| global.certificates.customCAs[18].secret | string | `"ca-certs-netherlands-ministry-of-defence"` |  |
| global.certificates.customCAs[19].secret | string | `"ca-certs-northrop-grumman"` |  |
| global.certificates.customCAs[20].secret | string | `"ca-certs-raytheon-trust-chain-1"` |  |
| global.certificates.customCAs[21].secret | string | `"ca-certs-raytheon-trust-chain-2"` |  |
| global.certificates.customCAs[22].secret | string | `"ca-certs-us-treasury-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[23].secret | string | `"ca-certs-us-treasury-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[24].secret | string | `"ca-certs-verizon-cybertrust-federal-ssp"` |  |
| global.certificates.customCAs[25].secret | string | `"ca-certs-widepoint-federal-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[26].secret | string | `"ca-certs-widepoint-federal-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[27].secret | string | `"ca-certs-widepoint-nfi"` |  |
| global.certificates.customCAs[28].secret | string | `"ca-certs-dod-intermediate-and-issuing-ca-certs"` |  |
| global.certificates.customCAs[29].secret | string | `"ca-certs-dod-trust-anchors-self-signed"` |  |
| global.certificates.customCAs[30].secret | string | `"ca-certs-eca"` |  |
| global.kubectl.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/kubectl"` |  |
| global.kubectl.image.tag | string | `"18.4.2"` |  |
| global.kubectl.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.kubectl.securityContext.runAsUser | int | `65534` |  |
| global.kubectl.securityContext.fsGroup | int | `65534` |  |
| global.kubectl.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| global.gitlabBase.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-base"` |  |
| global.gitlabBase.image.tag | string | `"18.4.2"` |  |
| global.gitlabBase.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.serviceAccount.enabled | bool | `true` |  |
| global.serviceAccount.create | bool | `true` |  |
| global.serviceAccount.annotations | object | `{}` |  |
| global.serviceAccount.automountServiceAccountToken | bool | `false` |  |
| upstream.nameOverride | string | `"gitlab"` |  |
| upstream.upgradeCheck.enabled | bool | `true` |  |
| upstream.upgradeCheck.image.repository | string | `"registry1.dso.mil/ironbank/redhat/ubi/ubi9"` |  |
| upstream.upgradeCheck.image.tag | string | `"9.6"` |  |
| upstream.upgradeCheck.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.upgradeCheck.securityContext.runAsUser | int | `65534` |  |
| upstream.upgradeCheck.securityContext.runAsGroup | int | `65534` |  |
| upstream.upgradeCheck.securityContext.fsGroup | int | `65534` |  |
| upstream.upgradeCheck.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| upstream.upgradeCheck.containerSecurityContext.runAsUser | int | `65534` |  |
| upstream.upgradeCheck.containerSecurityContext.runAsGroup | int | `65534` |  |
| upstream.upgradeCheck.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| upstream.upgradeCheck.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| upstream.upgradeCheck.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.upgradeCheck.tolerations | list | `[]` |  |
| upstream.upgradeCheck.annotations."sidecar.istio.io/inject" | string | `"true"` |  |
| upstream.upgradeCheck.configMapAnnotations | object | `{}` |  |
| upstream.upgradeCheck.resources.requests.cpu | string | `"500m"` |  |
| upstream.upgradeCheck.resources.requests.memory | string | `"500Mi"` |  |
| upstream.upgradeCheck.resources.limits.cpu | string | `"500m"` |  |
| upstream.upgradeCheck.resources.limits.memory | string | `"500Mi"` |  |
| upstream.certmanager-issuer.email | string | `"email@example.com"` |  |
| upstream.installCertmanager | bool | `false` |  |
| upstream.certmanager.installCRDs | bool | `false` |  |
| upstream.certmanager.nameOverride | string | `"certmanager"` |  |
| upstream.nginx-ingress.enabled | bool | `false` |  |
| upstream.prometheus.install | bool | `false` |  |
| upstream.redis.global.imagePullSecrets[0] | string | `"private-registry"` |  |
| upstream.redis.install | bool | `true` |  |
| upstream.redis.auth.existingSecret | string | `"gitlab-redis-secret"` |  |
| upstream.redis.auth.existingSecretKey | string | `"secret"` |  |
| upstream.redis.auth.usePasswordFiles | bool | `true` |  |
| upstream.redis.architecture | string | `"standalone"` |  |
| upstream.redis.cluster.enabled | bool | `false` |  |
| upstream.redis.metrics.enabled | bool | `true` |  |
| upstream.redis.metrics.image.registry | string | `"registry1.dso.mil/ironbank/bitnami"` |  |
| upstream.redis.metrics.image.repository | string | `"analytics/redis-exporter"` |  |
| upstream.redis.metrics.image.tag | string | `"v1.78.0"` |  |
| upstream.redis.metrics.image.pullSecrets | list | `[]` |  |
| upstream.redis.metrics.resources.limits.cpu | string | `"250m"` |  |
| upstream.redis.metrics.resources.limits.memory | string | `"256Mi"` |  |
| upstream.redis.metrics.resources.requests.cpu | string | `"250m"` |  |
| upstream.redis.metrics.resources.requests.memory | string | `"256Mi"` |  |
| upstream.redis.metrics.containerSecurityContext.enabled | bool | `true` |  |
| upstream.redis.metrics.containerSecurityContext.runAsUser | int | `1001` |  |
| upstream.redis.metrics.containerSecurityContext.runAsGroup | int | `1001` |  |
| upstream.redis.metrics.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| upstream.redis.metrics.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.redis.serviceAccount.automountServiceAccountToken | bool | `false` |  |
| upstream.redis.securityContext.runAsUser | int | `1001` |  |
| upstream.redis.securityContext.fsGroup | int | `1001` |  |
| upstream.redis.securityContext.runAsNonRoot | bool | `true` |  |
| upstream.redis.image.registry | string | `"registry1.dso.mil/ironbank/bitnami"` |  |
| upstream.redis.image.repository | string | `"redis"` |  |
| upstream.redis.image.tag | string | `"8.2.2"` |  |
| upstream.redis.image.pullSecrets | list | `[]` |  |
| upstream.redis.master.resources.limits.cpu | string | `"250m"` |  |
| upstream.redis.master.resources.limits.memory | string | `"256Mi"` |  |
| upstream.redis.master.resources.requests.cpu | string | `"250m"` |  |
| upstream.redis.master.resources.requests.memory | string | `"256Mi"` |  |
| upstream.redis.master.containerSecurityContext.enabled | bool | `true` |  |
| upstream.redis.master.containerSecurityContext.runAsUser | int | `1001` |  |
| upstream.redis.master.containerSecurityContext.runAsGroup | int | `1001` |  |
| upstream.redis.master.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| upstream.redis.master.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.redis.slave.resources.limits.cpu | string | `"250m"` |  |
| upstream.redis.slave.resources.limits.memory | string | `"256Mi"` |  |
| upstream.redis.slave.resources.requests.cpu | string | `"250m"` |  |
| upstream.redis.slave.resources.requests.memory | string | `"256Mi"` |  |
| upstream.redis.slave.containerSecurityContext.enabled | bool | `true` |  |
| upstream.redis.slave.containerSecurityContext.runAsUser | int | `1001` |  |
| upstream.redis.slave.containerSecurityContext.runAsGroup | int | `1001` |  |
| upstream.redis.slave.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| upstream.redis.slave.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.redis.sentinel.resources.limits.cpu | string | `"250m"` |  |
| upstream.redis.sentinel.resources.limits.memory | string | `"256Mi"` |  |
| upstream.redis.sentinel.resources.requests.cpu | string | `"250m"` |  |
| upstream.redis.sentinel.resources.requests.memory | string | `"256Mi"` |  |
| upstream.redis.volumePermissions.resources.limits.cpu | string | `"250m"` |  |
| upstream.redis.volumePermissions.resources.limits.memory | string | `"256Mi"` |  |
| upstream.redis.volumePermissions.resources.requests.cpu | string | `"250m"` |  |
| upstream.redis.volumePermissions.resources.requests.memory | string | `"256Mi"` |  |
| upstream.redis.sysctlImage.resources.limits.cpu | string | `"250m"` |  |
| upstream.redis.sysctlImage.resources.limits.memory | string | `"256Mi"` |  |
| upstream.redis.sysctlImage.resources.requests.cpu | string | `"250m"` |  |
| upstream.redis.sysctlImage.resources.requests.memory | string | `"256Mi"` |  |
| upstream.postgresql.install | bool | `true` |  |
| upstream.postgresql.postgresqlDatabase | string | `"gitlabhq_production"` |  |
| upstream.postgresql.global.imagePullSecrets[0] | string | `"private-registry"` |  |
| upstream.postgresql.global.security.allowInsecureImages | bool | `true` |  |
| upstream.postgresql.image.registry | string | `"registry1.dso.mil"` |  |
| upstream.postgresql.image.repository | string | `"ironbank/bitnami/postgres"` |  |
| upstream.postgresql.image.tag | string | `"17.4.0"` |  |
| upstream.postgresql.auth.username | string | `"gitlab"` |  |
| upstream.postgresql.auth.password | string | `"bogus-satisfy-upgrade"` |  |
| upstream.postgresql.auth.postgresPassword | string | `"bogus-satisfy-upgrade"` |  |
| upstream.postgresql.auth.database | string | `"gitlabhq_production"` |  |
| upstream.postgresql.auth.usePasswordFiles | bool | `false` |  |
| upstream.postgresql.auth.existingSecret | string | `"{{ include \"gitlab.psql.password.secret\" . }}"` |  |
| upstream.postgresql.auth.secretKeys.adminPasswordKey | string | `"postgresql-postgres-password"` |  |
| upstream.postgresql.auth.secretKeys.userPasswordKey | string | `"{{ include \"gitlab.psql.password.key\" $ }}"` |  |
| upstream.postgresql.primary.resources.limits.cpu | string | `"500m"` |  |
| upstream.postgresql.primary.resources.limits.memory | string | `"500Mi"` |  |
| upstream.postgresql.primary.resources.requests.cpu | string | `"500m"` |  |
| upstream.postgresql.primary.resources.requests.memory | string | `"500Mi"` |  |
| upstream.postgresql.primary.persistence.mountPath | string | `"/var/lib/postgresql"` |  |
| upstream.postgresql.primary.initdb.scriptsConfigMap | string | `"{{ include \"gitlab.psql.initdbscripts\" $}}"` |  |
| upstream.postgresql.primary.initdb.user | string | `"gitlab"` |  |
| upstream.postgresql.primary.extraVolumeMounts[0].mountPath | string | `"/tmp"` |  |
| upstream.postgresql.primary.extraVolumeMounts[0].name | string | `"empty-dir"` |  |
| upstream.postgresql.primary.extraVolumeMounts[0].subPath | string | `"tmp-dir"` |  |
| upstream.postgresql.primary.extraVolumeMounts[1].mountPath | string | `"/opt/bitnami/postgresql/conf"` |  |
| upstream.postgresql.primary.extraVolumeMounts[1].name | string | `"empty-dir"` |  |
| upstream.postgresql.primary.extraVolumeMounts[1].subPath | string | `"app-conf-dir"` |  |
| upstream.postgresql.primary.extraVolumeMounts[2].mountPath | string | `"/opt/bitnami/postgresql/tmp"` |  |
| upstream.postgresql.primary.extraVolumeMounts[2].name | string | `"empty-dir"` |  |
| upstream.postgresql.primary.extraVolumeMounts[2].subPath | string | `"app-tmp-dir"` |  |
| upstream.postgresql.primary.extraVolumeMounts[3].name | string | `"runtime"` |  |
| upstream.postgresql.primary.extraVolumeMounts[3].mountPath | string | `"/var/run/postgresql"` |  |
| upstream.postgresql.primary.extraVolumeMounts[4].name | string | `"custom-init-scripts"` |  |
| upstream.postgresql.primary.extraVolumeMounts[4].mountPath | string | `"/docker-entrypoint-preinitdb.d/init_revision.sh"` |  |
| upstream.postgresql.primary.extraVolumeMounts[4].subPath | string | `"init_revision.sh"` |  |
| upstream.postgresql.primary.extraVolumeMounts[5].name | string | `"registry-database-password"` |  |
| upstream.postgresql.primary.extraVolumeMounts[5].mountPath | string | `"/etc/gitlab/postgres/registry_database_password"` |  |
| upstream.postgresql.primary.extraVolumeMounts[5].subPath | string | `"database_password"` |  |
| upstream.postgresql.primary.extraVolumeMounts[5].readOnly | bool | `true` |  |
| upstream.postgresql.primary.extraVolumes[0].name | string | `"empty-dir"` |  |
| upstream.postgresql.primary.extraVolumes[0].emptyDir | object | `{}` |  |
| upstream.postgresql.primary.extraVolumes[1].name | string | `"runtime"` |  |
| upstream.postgresql.primary.extraVolumes[1].emptyDir | object | `{}` |  |
| upstream.postgresql.primary.extraVolumes[2].name | string | `"registry-database-password"` |  |
| upstream.postgresql.primary.extraVolumes[2].projected.sources[0].secret.name | string | `"{{ include \"gitlab.registry.database.password.secret\" . }}"` |  |
| upstream.postgresql.primary.extraVolumes[2].projected.sources[0].secret.items[0].key | string | `"{{ include \"gitlab.registry.database.password.key\" . }}"` |  |
| upstream.postgresql.primary.extraVolumes[2].projected.sources[0].secret.items[0].path | string | `"database_password"` |  |
| upstream.postgresql.primary.containerSecurityContext.enabled | bool | `true` |  |
| upstream.postgresql.primary.containerSecurityContext.runAsUser | int | `1001` |  |
| upstream.postgresql.primary.containerSecurityContext.runAsGroup | int | `1001` |  |
| upstream.postgresql.primary.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.postgresql.primary.containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| upstream.postgresql.primary.containerSecurityContext.seLinuxOptions | object | `{}` |  |
| upstream.postgresql.primary.podAnnotations."postgresql.gitlab/init-revision" | string | `"1"` |  |
| upstream.postgresql.metrics.enabled | bool | `false` |  |
| upstream.postgresql.metrics.service.annotations."prometheus.io/scrape" | string | `"true"` |  |
| upstream.postgresql.metrics.service.annotations."prometheus.io/port" | string | `"9187"` |  |
| upstream.postgresql.metrics.service.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| upstream.postgresql.metrics.service.annotations."gitlab.com/prometheus_port" | string | `"9187"` |  |
| upstream.postgresql.postgresqlInitdbArgs | string | `"-A scram-sha-256"` |  |
| upstream.postgresql.securityContext.enabled | bool | `true` |  |
| upstream.postgresql.securityContext.fsGroup | int | `26` |  |
| upstream.postgresql.securityContext.runAsUser | int | `26` |  |
| upstream.postgresql.securityContext.runAsGroup | int | `26` |  |
| upstream.postgresql.postgresqlDataDir | string | `"/var/lib/postgresql/pgdata/data"` |  |
| upstream.postgresql.volumePermissions.enabled | bool | `false` |  |
| upstream.registry.enabled | bool | `true` |  |
| upstream.registry.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.registry.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.registry.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.registry.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.registry.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.registry.resources.limits.cpu | string | `"200m"` |  |
| upstream.registry.resources.limits.memory | string | `"1024Mi"` |  |
| upstream.registry.resources.requests.cpu | string | `"200m"` |  |
| upstream.registry.resources.requests.memory | string | `"1024Mi"` |  |
| upstream.registry.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-container-registry"` |  |
| upstream.registry.image.tag | string | `"18.4.2"` |  |
| upstream.registry.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.registry.ingress.enabled | bool | `false` |  |
| upstream.registry.metrics.enabled | bool | `true` |  |
| upstream.registry.metrics.path | string | `"/metrics"` |  |
| upstream.registry.metrics.serviceMonitor.enabled | bool | `true` |  |
| upstream.registry.securityContext.runAsUser | int | `1000` |  |
| upstream.registry.securityContext.runAsGroup | int | `1000` |  |
| upstream.registry.securityContext.fsGroup | int | `1000` |  |
| upstream.registry.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.registry.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.registry.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.shared-secrets.enabled | bool | `true` |  |
| upstream.shared-secrets.rbac.create | bool | `true` |  |
| upstream.shared-secrets.selfsign.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/cfssl-self-sign"` |  |
| upstream.shared-secrets.selfsign.image.tag | string | `"1.6.1"` |  |
| upstream.shared-secrets.selfsign.keyAlgorithm | string | `"rsa"` |  |
| upstream.shared-secrets.selfsign.keySize | string | `"4096"` |  |
| upstream.shared-secrets.selfsign.expiry | string | `"3650d"` |  |
| upstream.shared-secrets.selfsign.caSubject | string | `"GitLab Helm Chart"` |  |
| upstream.shared-secrets.env | string | `"production"` |  |
| upstream.shared-secrets.serviceAccount.enabled | bool | `true` |  |
| upstream.shared-secrets.serviceAccount.create | bool | `true` |  |
| upstream.shared-secrets.serviceAccount.name | string | `nil` |  |
| upstream.shared-secrets.serviceAccount.automountServiceAccountToken | bool | `false` |  |
| upstream.shared-secrets.resources.requests.cpu | string | `"300m"` |  |
| upstream.shared-secrets.resources.requests.memory | string | `"200Mi"` |  |
| upstream.shared-secrets.resources.limits.cpu | string | `"300m"` |  |
| upstream.shared-secrets.resources.limits.memory | string | `"200Mi"` |  |
| upstream.shared-secrets.securityContext.runAsUser | int | `65534` |  |
| upstream.shared-secrets.securityContext.runAsGroup | int | `65534` |  |
| upstream.shared-secrets.securityContext.fsGroup | int | `65534` |  |
| upstream.shared-secrets.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| upstream.shared-secrets.containerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| upstream.shared-secrets.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| upstream.shared-secrets.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.shared-secrets.tolerations | list | `[]` |  |
| upstream.shared-secrets.podLabels | object | `{}` |  |
| upstream.shared-secrets.annotations."sidecar.istio.io/inject" | string | `"true"` |  |
| upstream.gitlab-runner.install | bool | `false` |  |
| upstream.gitlab.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.certificates.init.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.certificates.init.securityContext.runAsUser | int | `65534` |  |
| upstream.gitlab.certificates.init.securityContext.runAsNonRoot | bool | `true` |  |
| upstream.gitlab.toolbox.replicas | int | `1` |  |
| upstream.gitlab.toolbox.antiAffinityLabels.matchLabels.app | string | `"gitaly"` |  |
| upstream.gitlab.toolbox.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-toolbox"` |  |
| upstream.gitlab.toolbox.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.toolbox.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.toolbox.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.gitlab.toolbox.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.toolbox.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.gitlab.toolbox.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.toolbox.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.toolbox.resources.requests.cpu | int | `2` |  |
| upstream.gitlab.toolbox.resources.requests.memory | string | `"3.5Gi"` |  |
| upstream.gitlab.toolbox.resources.limits.cpu | int | `2` |  |
| upstream.gitlab.toolbox.resources.limits.memory | string | `"3.5Gi"` |  |
| upstream.gitlab.toolbox.annotations."sidecar.istio.io/proxyMemory" | string | `"512Mi"` |  |
| upstream.gitlab.toolbox.annotations."sidecar.istio.io/proxyMemoryLimit" | string | `"512Mi"` |  |
| upstream.gitlab.toolbox.backups.cron.resources.requests.cpu | string | `"500m"` |  |
| upstream.gitlab.toolbox.backups.cron.resources.requests.memory | string | `"768Mi"` |  |
| upstream.gitlab.toolbox.backups.cron.resources.limits.cpu | string | `"500m"` |  |
| upstream.gitlab.toolbox.backups.cron.resources.limits.memory | string | `"768Mi"` |  |
| upstream.gitlab.toolbox.backups.cron.istioShutdown | string | `"&& echo \"Backup Complete\" && until curl -fsI http://localhost:15021/healthz/ready; do echo \"Waiting for Istio sidecar proxy...\"; sleep 3; done && sleep 5 && echo \"Stopping the istio proxy...\" && curl -X POST http://localhost:15020/quitquitquit"` |  |
| upstream.gitlab.toolbox.securityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.toolbox.securityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.toolbox.securityContext.fsGroup | int | `1000` |  |
| upstream.gitlab.toolbox.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.toolbox.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.toolbox.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.toolbox.customScripts | string | `nil` |  |
| upstream.gitlab.gitlab-exporter.enabled | bool | `false` |  |
| upstream.gitlab.gitlab-exporter.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.gitlab.gitlab-exporter.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitlab-exporter.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.gitlab.gitlab-exporter.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitlab-exporter.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.gitlab-exporter.resources.limits.cpu | string | `"150m"` |  |
| upstream.gitlab.gitlab-exporter.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitlab-exporter.resources.requests.cpu | string | `"150m"` |  |
| upstream.gitlab.gitlab-exporter.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitlab-exporter.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.gitlab-exporter.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-exporter"` |  |
| upstream.gitlab.gitlab-exporter.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.gitlab-exporter.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.gitlab-exporter.metrics.enabled | bool | `true` |  |
| upstream.gitlab.gitlab-exporter.metrics.port | int | `9168` |  |
| upstream.gitlab.gitlab-exporter.metrics.serviceMonitor.enabled | bool | `true` |  |
| upstream.gitlab.gitlab-exporter.securityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.gitlab-exporter.securityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.gitlab-exporter.securityContext.fsGroup | int | `1000` |  |
| upstream.gitlab.gitlab-exporter.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.gitlab-exporter.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.gitlab-exporter.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.migrations.annotations."sidecar.istio.io/inject" | string | `"true"` |  |
| upstream.gitlab.migrations.init.resources.limits.cpu | string | `"500m"` |  |
| upstream.gitlab.migrations.init.resources.limits.memory | string | `"768Mi"` |  |
| upstream.gitlab.migrations.init.resources.requests.cpu | string | `"500m"` |  |
| upstream.gitlab.migrations.init.resources.requests.memory | string | `"768Mi"` |  |
| upstream.gitlab.migrations.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.migrations.resources.limits.cpu | string | `"500m"` |  |
| upstream.gitlab.migrations.resources.limits.memory | string | `"1.5G"` |  |
| upstream.gitlab.migrations.resources.requests.cpu | string | `"500m"` |  |
| upstream.gitlab.migrations.resources.requests.memory | string | `"1.5G"` |  |
| upstream.gitlab.migrations.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-toolbox"` |  |
| upstream.gitlab.migrations.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.migrations.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.migrations.securityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.migrations.securityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.migrations.securityContext.fsGroup | int | `1000` |  |
| upstream.gitlab.migrations.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.migrations.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.migrations.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.webservice.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.gitlab.webservice.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.webservice.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.gitlab.webservice.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.webservice.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.webservice.securityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.webservice.securityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.webservice.securityContext.fsGroup | int | `1000` |  |
| upstream.gitlab.webservice.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.webservice.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.webservice.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.webservice.resources.limits.cpu | string | `"1500m"` |  |
| upstream.gitlab.webservice.resources.limits.memory | string | `"3G"` |  |
| upstream.gitlab.webservice.resources.requests.cpu | string | `"300m"` |  |
| upstream.gitlab.webservice.resources.requests.memory | string | `"2.5G"` |  |
| upstream.gitlab.webservice.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-webservice"` |  |
| upstream.gitlab.webservice.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.webservice.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.webservice.workhorse.resources.limits.cpu | string | `"600m"` |  |
| upstream.gitlab.webservice.workhorse.resources.limits.memory | string | `"2.5G"` |  |
| upstream.gitlab.webservice.workhorse.resources.requests.cpu | string | `"600m"` |  |
| upstream.gitlab.webservice.workhorse.resources.requests.memory | string | `"2.5G"` |  |
| upstream.gitlab.webservice.workhorse.image | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-workhorse"` |  |
| upstream.gitlab.webservice.workhorse.tag | string | `"18.4.2"` |  |
| upstream.gitlab.webservice.workhorse.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.webservice.workhorse.metrics.enabled | bool | `true` |  |
| upstream.gitlab.webservice.workhorse.metrics.serviceMonitor.enabled | bool | `true` |  |
| upstream.gitlab.webservice.workhorse.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.webservice.ingress.enabled | bool | `false` |  |
| upstream.gitlab.webservice.metrics.enabled | bool | `true` |  |
| upstream.gitlab.webservice.metrics.port | int | `8083` |  |
| upstream.gitlab.webservice.metrics.serviceMonitor.enabled | bool | `true` |  |
| upstream.gitlab.webservice.helmTests.enabled | bool | `false` |  |
| upstream.gitlab.sidekiq.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-sidekiq"` |  |
| upstream.gitlab.sidekiq.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.sidekiq.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.sidekiq.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.gitlab.sidekiq.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.sidekiq.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.gitlab.sidekiq.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.sidekiq.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.sidekiq.resources.requests.memory | string | `"3G"` |  |
| upstream.gitlab.sidekiq.resources.requests.cpu | string | `"1500m"` |  |
| upstream.gitlab.sidekiq.resources.limits.memory | string | `"3G"` |  |
| upstream.gitlab.sidekiq.resources.limits.cpu | string | `"1500m"` |  |
| upstream.gitlab.sidekiq.securityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.sidekiq.securityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.sidekiq.securityContext.fsGroup | int | `1000` |  |
| upstream.gitlab.sidekiq.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.sidekiq.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.sidekiq.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.gitaly.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitaly"` |  |
| upstream.gitlab.gitaly.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.gitaly.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.gitaly.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.gitlab.gitaly.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitaly.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.gitlab.gitaly.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitaly.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.gitaly.resources.requests.cpu | string | `"400m"` |  |
| upstream.gitlab.gitaly.resources.requests.memory | string | `"600Mi"` |  |
| upstream.gitlab.gitaly.resources.limits.cpu | string | `"400m"` |  |
| upstream.gitlab.gitaly.resources.limits.memory | string | `"600Mi"` |  |
| upstream.gitlab.gitaly.metrics.enabled | bool | `true` |  |
| upstream.gitlab.gitaly.metrics.serviceMonitor.enabled | bool | `true` |  |
| upstream.gitlab.gitaly.securityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.gitaly.securityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.gitaly.securityContext.fsGroup | int | `1000` |  |
| upstream.gitlab.gitaly.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.gitaly.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.gitaly.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.gitlab-shell.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-shell"` |  |
| upstream.gitlab.gitlab-shell.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.gitlab-shell.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.gitlab-shell.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.gitlab.gitlab-shell.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitlab-shell.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.gitlab.gitlab-shell.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.gitlab-shell.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.gitlab-shell.resources.limits.cpu | string | `"300m"` |  |
| upstream.gitlab.gitlab-shell.resources.limits.memory | string | `"300Mi"` |  |
| upstream.gitlab.gitlab-shell.resources.requests.cpu | string | `"300m"` |  |
| upstream.gitlab.gitlab-shell.resources.requests.memory | string | `"300Mi"` |  |
| upstream.gitlab.gitlab-shell.securityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.gitlab-shell.securityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.gitlab-shell.securityContext.fsGroup | int | `1000` |  |
| upstream.gitlab.gitlab-shell.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.gitlab.gitlab-shell.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.gitlab.gitlab-shell.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.mailroom.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-mailroom"` |  |
| upstream.gitlab.mailroom.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.mailroom.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.gitlab.mailroom.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.gitlab-pages.service.customDomains.type | string | `"ClusterIP"` |  |
| upstream.gitlab.gitlab-pages.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-pages"` |  |
| upstream.gitlab.gitlab-pages.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.gitlab-pages.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.praefect.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitaly"` |  |
| upstream.gitlab.praefect.image.tag | string | `"18.4.2"` |  |
| upstream.gitlab.praefect.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.gitlab.praefect.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.gitlab.praefect.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.gitlab.praefect.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.gitlab.praefect.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.gitlab.praefect.resources.requests.cpu | int | `1` |  |
| upstream.gitlab.praefect.resources.requests.memory | string | `"1Gi"` |  |
| upstream.gitlab.praefect.resources.limits.cpu | int | `1` |  |
| upstream.gitlab.praefect.resources.limits.memory | string | `"1Gi"` |  |
| upstream.gitlab.praefect.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.minio.ingress.enabled | bool | `false` |  |
| upstream.minio.init.resources.limits.cpu | string | `"200m"` |  |
| upstream.minio.init.resources.limits.memory | string | `"200Mi"` |  |
| upstream.minio.init.resources.requests.cpu | string | `"200m"` |  |
| upstream.minio.init.resources.requests.memory | string | `"200Mi"` |  |
| upstream.minio.init.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.minio.resources.limits.cpu | string | `"200m"` |  |
| upstream.minio.resources.limits.memory | string | `"300Mi"` |  |
| upstream.minio.resources.requests.cpu | string | `"200m"` |  |
| upstream.minio.resources.requests.memory | string | `"300Mi"` |  |
| upstream.minio.securityContext.runAsUser | int | `1000` |  |
| upstream.minio.securityContext.runAsGroup | int | `1000` |  |
| upstream.minio.securityContext.fsGroup | int | `1000` |  |
| upstream.minio.containerSecurityContext.runAsUser | int | `1000` |  |
| upstream.minio.containerSecurityContext.runAsGroup | int | `1000` |  |
| upstream.minio.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| upstream.minio.containerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| upstream.minio.jobAnnotations."sidecar.istio.io/inject" | string | `"true"` |  |
| upstream.minio.image | string | `"registry1.dso.mil/ironbank/opensource/minio/minio"` |  |
| upstream.minio.imageTag | string | `"RELEASE.2024-06-04T19-20-08Z"` |  |
| upstream.minio.pullSecrets[0].name | string | `"private-registry"` |  |
| upstream.minio.minioMc.image | string | `"registry1.dso.mil/ironbank/opensource/minio/mc"` |  |
| upstream.minio.minioMc.tag | string | `"RELEASE.2024-10-02T08-27-28Z"` |  |
| upstream.minio.minioMc.pullSecrets[0].name | string | `"private-registry"` |  |
| domain | string | `"dev.bigbang.mil"` |  |
| sso.enabled | bool | `false` |  |
| sso.host | string | `"login.dso.mil"` |  |
| istio.enabled | bool | `false` |  |
| istio.injection | string | `"disabled"` |  |
| istio.hardened.enabled | bool | `false` |  |
| istio.hardened.outboundTrafficPolicyMode | string | `"REGISTRY_ONLY"` |  |
| istio.hardened.customServiceEntries | list | `[]` |  |
| istio.hardened.customAuthorizationPolicies | list | `[]` |  |
| istio.hardened.gitlabRunner.enabled | bool | `true` |  |
| istio.hardened.gitlabRunner.namespaces[0] | string | `"gitlab-runner"` |  |
| istio.hardened.gcpe.enabled | bool | `true` |  |
| istio.hardened.gcpe.namespaces[0] | string | `"gitlab-ci-pipelines-exporter"` |  |
| istio.hardened.monitoring.enabled | bool | `true` |  |
| istio.hardened.monitoring.namespaces[0] | string | `"monitoring"` |  |
| istio.hardened.monitoring.principals[0] | string | `"cluster.local/ns/monitoring/sa/monitoring-grafana"` |  |
| istio.hardened.monitoring.principals[1] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-alertmanager"` |  |
| istio.hardened.monitoring.principals[2] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-operator"` |  |
| istio.hardened.monitoring.principals[3] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-prometheus"` |  |
| istio.hardened.monitoring.principals[4] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-kube-state-metrics"` |  |
| istio.hardened.monitoring.principals[5] | string | `"cluster.local/ns/monitoring/sa/monitoring-monitoring-prometheus-node-exporter"` |  |
| istio.gitlab.enabled | bool | `true` |  |
| istio.gitlab.annotations | object | `{}` |  |
| istio.gitlab.labels | object | `{}` |  |
| istio.gitlab.gateways[0] | string | `"istio-system/main"` |  |
| istio.gitlab.hosts | string | `nil` |  |
| istio.gitlab.selectorLabels.app | string | `"webservice"` |  |
| istio.registry.enabled | bool | `true` |  |
| istio.registry.annotations | object | `{}` |  |
| istio.registry.labels | object | `{}` |  |
| istio.registry.gateways[0] | string | `"istio-system/main"` |  |
| istio.registry.hosts | string | `nil` |  |
| istio.registry.selectorLabels.app | string | `"registry"` |  |
| istio.pages.enabled | bool | `false` |  |
| istio.pages.annotations | object | `{}` |  |
| istio.pages.ingressLabels.app | string | `"pages-ingressgateway"` |  |
| istio.pages.ingressLabels.istio | string | `"ingressgateway"` |  |
| istio.pages.labels | object | `{}` |  |
| istio.pages.gateways[0] | string | `"istio-system/pages"` |  |
| istio.pages.customDomains.enabled | bool | `true` |  |
| istio.pages.hosts[0] | string | `"*.pages.dev.bigbang.mil"` |  |
| istio.mtls | object | `{"mode":"STRICT"}` | Default peer authentication |
| istio.mtls.mode | string | `"STRICT"` | STRICT = Allow only mutual TLS traffic, PERMISSIVE = Allow both plain text and mutual TLS traffic |
| monitoring.enabled | bool | `false` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.ingressLabels.app | string | `"istio-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.vpcCidr | string | `"0.0.0.0/0"` |  |
| networkPolicies.egressPort | string | `nil` |  |
| networkPolicies.gitalyEgress.enabled | bool | `false` |  |
| networkPolicies.additionalPolicies | list | `[]` |  |
| openshift | bool | `false` |  |
| use_iam_profile | bool | `false` |  |
| bbtests.enabled | bool | `false` |  |
| bbtests.cypress.resources.requests.cpu | int | `1` |  |
| bbtests.cypress.resources.requests.memory | string | `"2Gi"` |  |
| bbtests.cypress.resources.limits.cpu | int | `1` |  |
| bbtests.cypress.resources.limits.memory | string | `"2Gi"` |  |
| bbtests.cypress.artifacts | bool | `true` |  |
| bbtests.cypress.envs.cypress_url | string | `"http://gitlab-webservice-default:8181"` |  |
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
| bbtests.scripts.image | string | `"registry1.dso.mil/bigbang-ci/devops-tester:1.1.2"` |  |
| bbtests.scripts.additionalVolumes[0].name | string | `"docker-config"` |  |
| bbtests.scripts.additionalVolumes[0].secret.secretName | string | `"private-registry"` |  |
| bbtests.scripts.additionalVolumes[0].secret.items[0].key | string | `".dockerconfigjson"` |  |
| bbtests.scripts.additionalVolumes[0].secret.items[0].path | string | `"auth.json"` |  |
| bbtests.scripts.additionalVolumeMounts[0].name | string | `"docker-config"` |  |
| bbtests.scripts.additionalVolumeMounts[0].mountPath | string | `"/.docker/"` |  |
| bbtests.scripts.envs.GITLAB_USER | string | `"root"` |  |
| bbtests.scripts.envs.GITLAB_EMAIL | string | `"gitlab-root-user@example.com"` |  |
| bbtests.scripts.envs.GITLAB_HOST | string | `"gitlab-webservice-default.gitlab.svc.cluster.local:8181"` |  |
| bbtests.scripts.envs.GITLAB_PROJECT | string | `"bigbang-test-project-2"` |  |
| bbtests.scripts.envs.GITLAB_REGISTRY | string | `"gitlab-registry-test-svc.gitlab.svc.cluster.local:80"` |  |
| bbtests.scripts.envs.GITLAB_REPOSITORY | string | `"http://gitlab-webservice-default.gitlab.svc.cluster.local:8181"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.

---

_This file is programatically generated using `helm-docs` and some BigBang-specific templates. The `gluon` repository has [instructions for regenerating package READMEs](https://repo1.dso.mil/big-bang/product/packages/gluon/-/blob/master/docs/bb-package-readme.md)._

