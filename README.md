# gitlab

![Version: 5.6.0-bb.0](https://img.shields.io/badge/Version-5.6.0--bb.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| global.istio.enabled | bool | `false` |  |
| global.istio.injection | string | `"disabled"` |  |
| global.common.labels | object | `{}` |  |
| global.image | object | `{}` |  |
| global.operator.enabled | bool | `false` |  |
| global.operator.rollout.autoPause | bool | `true` |  |
| global.pod.labels | object | `{}` |  |
| global.edition | string | `"ee"` |  |
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
| global.gitlab.license | object | `{}` |  |
| global.initialRootPassword | object | `{}` |  |
| global.psql.connectTimeout | string | `nil` |  |
| global.psql.keepalives | string | `nil` |  |
| global.psql.keepalivesIdle | string | `nil` |  |
| global.psql.keepalivesInterval | string | `nil` |  |
| global.psql.keepalivesCount | string | `nil` |  |
| global.psql.tcpUserTimeout | string | `nil` |  |
| global.psql.password | object | `{}` |  |
| global.redis.password.enabled | bool | `true` |  |
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
| global.grafana.enabled | bool | `false` |  |
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
| global.appConfig.dependencyProxy.enabled | bool | `false` |  |
| global.appConfig.dependencyProxy.proxy_download | bool | `true` |  |
| global.appConfig.dependencyProxy.bucket | string | `"gitlab-dependency-proxy"` |  |
| global.appConfig.dependencyProxy.connection | object | `{}` |  |
| global.appConfig.pseudonymizer.configMap | string | `nil` |  |
| global.appConfig.pseudonymizer.bucket | string | `"gitlab-pseudo"` |  |
| global.appConfig.pseudonymizer.connection | object | `{}` |  |
| global.appConfig.backups.bucket | string | `"gitlab-backups"` |  |
| global.appConfig.backups.tmpBucket | string | `"tmp"` |  |
| global.appConfig.incomingEmail.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.address | string | `""` |  |
| global.appConfig.incomingEmail.host | string | `"imap.gmail.com"` |  |
| global.appConfig.incomingEmail.port | int | `993` |  |
| global.appConfig.incomingEmail.ssl | bool | `true` |  |
| global.appConfig.incomingEmail.startTls | bool | `false` |  |
| global.appConfig.incomingEmail.user | string | `""` |  |
| global.appConfig.incomingEmail.password.secret | string | `""` |  |
| global.appConfig.incomingEmail.password.key | string | `"password"` |  |
| global.appConfig.incomingEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.incomingEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.incomingEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.incomingEmail.idleTimeout | int | `60` |  |
| global.appConfig.incomingEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.incomingEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.incomingEmail.pollInterval | int | `60` |  |
| global.appConfig.serviceDeskEmail.enabled | bool | `false` |  |
| global.appConfig.serviceDeskEmail.address | string | `""` |  |
| global.appConfig.serviceDeskEmail.host | string | `"imap.gmail.com"` |  |
| global.appConfig.serviceDeskEmail.port | int | `993` |  |
| global.appConfig.serviceDeskEmail.ssl | bool | `true` |  |
| global.appConfig.serviceDeskEmail.startTls | bool | `false` |  |
| global.appConfig.serviceDeskEmail.user | string | `""` |  |
| global.appConfig.serviceDeskEmail.password.secret | string | `""` |  |
| global.appConfig.serviceDeskEmail.password.key | string | `"password"` |  |
| global.appConfig.serviceDeskEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.serviceDeskEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.serviceDeskEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.serviceDeskEmail.idleTimeout | int | `60` |  |
| global.appConfig.serviceDeskEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.serviceDeskEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.serviceDeskEmail.pollInterval | int | `60` |  |
| global.appConfig.ldap.preventSignin | bool | `false` |  |
| global.appConfig.ldap.servers | object | `{}` |  |
| global.appConfig.gitlab_kas | object | `{}` |  |
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
| global.shell.authToken | object | `{}` |  |
| global.shell.hostKeys | object | `{}` |  |
| global.shell.tcp.proxyProtocol | bool | `false` |  |
| global.railsSecrets | object | `{}` |  |
| global.rails.bootsnap.enabled | bool | `true` |  |
| global.registry.bucket | string | `"registry"` |  |
| global.registry.certificate | object | `{}` |  |
| global.registry.httpSecret | object | `{}` |  |
| global.registry.notificationSecret | object | `{}` |  |
| global.registry.notifications | object | `{}` |  |
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
| global.workhorse.serviceName | string | `"webservice-default"` |  |
| global.webservice.workerTimeout | int | `60` |  |
| global.certificates.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/alpine-certificates"` |  |
| global.certificates.image.tag | string | `"14.6.0"` |  |
| global.certificates.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.certificates.customCAs[0].secret | string | `"ca-certs-dod-intermediate-dod-email-ca"` |  |
| global.certificates.customCAs[1].secret | string | `"ca-certs-dod-intermediate-dod-id-ca"` |  |
| global.certificates.customCAs[2].secret | string | `"ca-certs-dod-intermediate-dod-sw-ca"` |  |
| global.certificates.customCAs[3].secret | string | `"ca-certs-dod-intermediate-dod-derility-ca"` |  |
| global.certificates.customCAs[4].secret | string | `"ca-certs-dod-trust-anchors"` |  |
| global.certificates.customCAs[5].secret | string | `"ca-certs-eca"` |  |
| global.certificates.customCAs[6].secret | string | `"ca-certs-ado-cc-chain"` |  |
| global.certificates.customCAs[7].secret | string | `"ca-certs-ado-dt-chain"` |  |
| global.certificates.customCAs[8].secret | string | `"ca-certs-boeing"` |  |
| global.certificates.customCAs[9].secret | string | `"ca-certs-carillon-federal-services"` |  |
| global.certificates.customCAs[10].secret | string | `"ca-certs-department-of-state-trust-chain-1"` |  |
| global.certificates.customCAs[11].secret | string | `"ca-certs-department-of-state-trust-chain-2"` |  |
| global.certificates.customCAs[12].secret | string | `"ca-certs-digicert-federal-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[13].secret | string | `"ca-certs-digicert-federal-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[14].secret | string | `"ca-certs-digicert-nfi"` |  |
| global.certificates.customCAs[15].secret | string | `"ca-certs-entrust-federal-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[16].secret | string | `"ca-certs-entrust-federal-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[17].secret | string | `"ca-certs-entrust-managed-servcie-nfi"` |  |
| global.certificates.customCAs[18].secret | string | `"ca-certs-exostar-llc"` |  |
| global.certificates.customCAs[19].secret | string | `"ca-certs-identrust-nfi"` |  |
| global.certificates.customCAs[20].secret | string | `"ca-certs-lockheed-martin"` |  |
| global.certificates.customCAs[21].secret | string | `"ca-certs-netherlands-mod"` |  |
| global.certificates.customCAs[22].secret | string | `"ca-certs-northrop-grumman"` |  |
| global.certificates.customCAs[23].secret | string | `"ca-certs-raytheon-trust-chain-1"` |  |
| global.certificates.customCAs[24].secret | string | `"ca-certs-raytheon-trust-chain-2"` |  |
| global.certificates.customCAs[25].secret | string | `"ca-certs-us-treasury-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[26].secret | string | `"ca-certs-us-treasury-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[27].secret | string | `"ca-certs-verizon-cybertrust-federal-ssp"` |  |
| global.certificates.customCAs[28].secret | string | `"ca-certs-widepoint-federal-ssp-trust-chain-1"` |  |
| global.certificates.customCAs[29].secret | string | `"ca-certs-widepoint-federal-ssp-trust-chain-2"` |  |
| global.certificates.customCAs[30].secret | string | `"ca-certs-widepoint-nfi-trust-chain-1"` |  |
| global.certificates.customCAs[31].secret | string | `"ca-certs-widepoint-nfi-trust-chain-2"` |  |
| global.kubectl.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/kubectl"` |  |
| global.kubectl.image.tag | string | `"14.6.0"` |  |
| global.kubectl.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.kubectl.securityContext.runAsUser | int | `65534` |  |
| global.kubectl.securityContext.fsGroup | int | `65534` |  |
| global.busybox.image.repository | string | `"registry1.dso.mil/ironbank/redhat/ubi/ubi8"` |  |
| global.busybox.image.tag | string | `"8.4"` |  |
| global.busybox.image.pullSecrets[0].name | string | `"private-registry"` |  |
| global.serviceAccount.enabled | bool | `false` |  |
| global.serviceAccount.create | bool | `true` |  |
| global.serviceAccount.annotations | object | `{}` |  |
| global.tracing.connection.string | string | `""` |  |
| global.tracing.urlTemplate | string | `""` |  |
| global.extraEnv | object | `{}` |  |
| upgradeCheck.enabled | bool | `true` |  |
| upgradeCheck.image.repository | string | `"registry1.dso.mil/ironbank/redhat/ubi/ubi8"` |  |
| upgradeCheck.image.tag | string | `"8.4"` |  |
| upgradeCheck.image.pullSecrets[0].name | string | `"private-registry"` |  |
| upgradeCheck.securityContext.runAsUser | int | `65534` |  |
| upgradeCheck.securityContext.fsGroup | int | `65534` |  |
| upgradeCheck.tolerations | list | `[]` |  |
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
| nginx-ingress.controller.config.hsts | string | `"false"` |  |
| nginx-ingress.controller.config.hsts-include-subdomains | string | `"false"` |  |
| nginx-ingress.controller.config.hsts-max-age | string | `"63072000"` |  |
| nginx-ingress.controller.config.server-name-hash-bucket-size | string | `"256"` |  |
| nginx-ingress.controller.config.use-http2 | string | `"true"` |  |
| nginx-ingress.controller.config.ssl-ciphers | string | `"ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:ECDHE-RSA-AES128-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4"` |  |
| nginx-ingress.controller.config.ssl-protocols | string | `"TLSv1.3 TLSv1.2"` |  |
| nginx-ingress.controller.config.server-tokens | string | `"false"` |  |
| nginx-ingress.controller.service.externalTrafficPolicy | string | `"Local"` |  |
| nginx-ingress.controller.ingressClassByName | bool | `false` |  |
| nginx-ingress.controller.ingressClassResource.name | string | `"{{ .Release.Name }}-nginx"` |  |
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
| nginx-ingress.defaultBackend.enabled | bool | `true` |  |
| nginx-ingress.defaultBackend.minAvailable | int | `1` |  |
| nginx-ingress.defaultBackend.replicaCount | int | `1` |  |
| nginx-ingress.defaultBackend.resources.requests.cpu | string | `"5m"` |  |
| nginx-ingress.defaultBackend.resources.requests.memory | string | `"5Mi"` |  |
| nginx-ingress.rbac.create | bool | `true` |  |
| nginx-ingress.rbac.scope | bool | `false` |  |
| nginx-ingress.serviceAccount.create | bool | `true` |  |
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
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].source_labels[0] | string | `"__meta_kubernetes_pod_annotation_gitlab_com_prometheus_path"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].target_label | string | `"__metrics_path__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[1].regex | string | `"(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].source_labels[0] | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].source_labels[1] | string | `"__meta_kubernetes_pod_annotation_gitlab_com_prometheus_port"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].regex | string | `"([^:]+)(?::\\d+)?;(\\d+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].replacement | string | `"$1:$2"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[2].target_label | string | `"__address__"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].action | string | `"labelmap"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[3].regex | string | `"__meta_kubernetes_pod_label_(.+)"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[4].source_labels[0] | string | `"__meta_kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[4].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[4].target_label | string | `"kubernetes_namespace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[5].source_labels[0] | string | `"__meta_kubernetes_pod_name"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[5].action | string | `"replace"` |  |
| prometheus.serverFiles."prometheus.yml".scrape_configs[2].relabel_configs[5].target_label | string | `"kubernetes_pod_name"` |  |
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
| redis.install | bool | `true` |  |
| redis.existingSecret | string | `"gitlab-redis-secret"` |  |
| redis.existingSecretKey | string | `"redis-password"` |  |
| redis.usePasswordFile | bool | `true` |  |
| redis.cluster.enabled | bool | `false` |  |
| redis.metrics.enabled | bool | `true` |  |
| redis.metrics.image.registry | string | `"registry1.dso.mil/ironbank/bitnami"` |  |
| redis.metrics.image.repository | string | `"analytics/redis-exporter"` |  |
| redis.metrics.image.tag | string | `"1.18.0"` |  |
| redis.metrics.image.pullSecrets[0] | string | `"private-registry"` |  |
| redis.metrics.resources.limits.cpu | string | `"250m"` |  |
| redis.metrics.resources.limits.memory | string | `"256Mi"` |  |
| redis.metrics.resources.requests.cpu | string | `"250m"` |  |
| redis.metrics.resources.requests.memory | string | `"256Mi"` |  |
| redis.image.registry | string | `"registry1.dso.mil/ironbank/opensource"` |  |
| redis.image.repository | string | `"redis/redis5"` |  |
| redis.image.tag | string | `"5.0.9"` |  |
| redis.image.pullSecrets[0] | string | `"private-registry"` |  |
| redis.master.command | string | `"redis-server"` |  |
| redis.master.resources.limits.cpu | string | `"250m"` |  |
| redis.master.resources.limits.memory | string | `"256Mi"` |  |
| redis.master.resources.requests.cpu | string | `"250m"` |  |
| redis.master.resources.requests.memory | string | `"256Mi"` |  |
| redis.slave.command | string | `"redis-server"` |  |
| redis.slave.resources.limits.cpu | string | `"250m"` |  |
| redis.slave.resources.limits.memory | string | `"256Mi"` |  |
| redis.slave.resources.requests.cpu | string | `"250m"` |  |
| redis.slave.resources.requests.memory | string | `"256Mi"` |  |
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
| postgresql.postgresqlUsername | string | `"gitlab"` |  |
| postgresql.postgresqlPostgresPassword | string | `"bogus"` |  |
| postgresql.install | bool | `true` |  |
| postgresql.postgresqlDatabase | string | `"gitlabhq_production"` |  |
| postgresql.resources.limits.cpu | string | `"500m"` |  |
| postgresql.resources.limits.memory | string | `"500Mi"` |  |
| postgresql.resources.requests.cpu | string | `"500m"` |  |
| postgresql.resources.requests.memory | string | `"500Mi"` |  |
| postgresql.image.registry | string | `"registry.dso.mil"` |  |
| postgresql.image.repository | string | `"platform-one/big-bang/apps/developer-tools/gitlab/postgresql"` |  |
| postgresql.image.tag | string | `"12.7.0"` |  |
| postgresql.usePasswordFile | bool | `true` |  |
| postgresql.existingSecret | string | `"bogus"` |  |
| postgresql.initdbScriptsConfigMap | string | `"bogus"` |  |
| postgresql.master.extraVolumeMounts[0].name | string | `"custom-init-scripts"` |  |
| postgresql.master.extraVolumeMounts[0].mountPath | string | `"/docker-entrypoint-preinitdb.d/init_revision.sh"` |  |
| postgresql.master.extraVolumeMounts[0].subPath | string | `"init_revision.sh"` |  |
| postgresql.master.podAnnotations."postgresql.gitlab/init-revision" | string | `"1"` |  |
| postgresql.metrics.enabled | bool | `false` |  |
| registry.enabled | bool | `true` |  |
| registry.init.resources.limits.cpu | string | `"200m"` |  |
| registry.init.resources.limits.memory | string | `"200Mi"` |  |
| registry.init.resources.requests.cpu | string | `"200m"` |  |
| registry.init.resources.requests.memory | string | `"200Mi"` |  |
| registry.resources.limits.cpu | string | `"200m"` |  |
| registry.resources.limits.memory | string | `"1024Mi"` |  |
| registry.resources.requests.cpu | string | `"200m"` |  |
| registry.resources.requests.memory | string | `"1024Mi"` |  |
| registry.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-container-registry"` |  |
| registry.image.tag | string | `"14.6.0"` |  |
| registry.image.pullSecrets[0].name | string | `"private-registry"` |  |
| registry.ingress.enabled | bool | `false` |  |
| shared-secrets.enabled | bool | `true` |  |
| shared-secrets.rbac.create | bool | `true` |  |
| shared-secrets.selfsign.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/cfssl-self-sign"` |  |
| shared-secrets.selfsign.image.tag | string | `"1.4.1"` |  |
| shared-secrets.selfsign.image.pullSecrets[0].name | string | `"private-registry"` |  |
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
| shared-secrets.tolerations | list | `[]` |  |
| shared-secrets.podLabels | object | `{}` |  |
| shared-secrets.annotations | object | `{}` |  |
| gitlab-runner.install | bool | `false` |  |
| gitlab-runner.rbac.create | bool | `true` |  |
| gitlab-runner.runners.locked | bool | `false` |  |
| gitlab-runner.runners.config | string | `"[[runners]]\n  [runners.kubernetes]\n  image = \"ubuntu:18.04\"\n  {{- if .Values.global.minio.enabled }}\n  [runners.cache]\n    Type = \"s3\"\n    Path = \"gitlab-runner\"\n    Shared = true\n    [runners.cache.s3]\n      ServerAddress = {{ include \"gitlab-runner.cache-tpl.s3ServerAddress\" . }}\n      BucketName = \"runner-cache\"\n      BucketLocation = \"us-east-1\"\n      Insecure = false\n  {{ end }}\n"` |  |
| gitlab-runner.podAnnotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| gitlab-runner.podAnnotations."gitlab.com/prometheus_port" | int | `9252` |  |
| grafana.nameOverride | string | `"grafana-app"` |  |
| grafana.admin.existingSecret | string | `"bogus"` |  |
| grafana.env.GF_SECURITY_ADMIN_USER | string | `"bogus"` |  |
| grafana.env.GF_SECURITY_ADMIN_PASSWORD | string | `"bogus"` |  |
| grafana.command[0] | string | `"sh"` |  |
| grafana.command[1] | string | `"-x"` |  |
| grafana.command[2] | string | `"/tmp/scripts/import-secret.sh"` |  |
| grafana.sidecar.dashboards.enabled | bool | `true` |  |
| grafana.sidecar.dashboards.label | string | `"gitlab_grafana_dashboard"` |  |
| grafana.sidecar.datasources.enabled | bool | `true` |  |
| grafana.sidecar.datasources.label | string | `"gitlab_grafana_datasource"` |  |
| grafana."grafana.ini".server.serve_from_sub_path | bool | `true` |  |
| grafana."grafana.ini".server.root_url | string | `"http://localhost/-/grafana/"` |  |
| grafana."grafana.ini".auth.login_cookie_name | string | `"gitlab_grafana_session"` |  |
| grafana.extraSecretMounts[0].name | string | `"initial-password"` |  |
| grafana.extraSecretMounts[0].mountPath | string | `"/tmp/initial"` |  |
| grafana.extraSecretMounts[0].readOnly | bool | `true` |  |
| grafana.extraSecretMounts[0].secretName | string | `"gitlab-grafana-initial-password"` |  |
| grafana.extraSecretMounts[0].defaultMode | int | `400` |  |
| grafana.extraConfigmapMounts[0].name | string | `"import-secret"` |  |
| grafana.extraConfigmapMounts[0].mountPath | string | `"/tmp/scripts"` |  |
| grafana.extraConfigmapMounts[0].configMap | string | `"gitlab-grafana-import-secret"` |  |
| grafana.extraConfigmapMounts[0].readOnly | bool | `true` |  |
| grafana.testFramework.enabled | bool | `false` |  |
| gitlab.toolbox.replicas | int | `1` |  |
| gitlab.toolbox.antiAffinityLabels.matchLabels.app | string | `"gitaly"` |  |
| gitlab.toolbox.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-toolbox"` |  |
| gitlab.toolbox.image.tag | string | `"14.6.0"` |  |
| gitlab.toolbox.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.toolbox.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.toolbox.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.toolbox.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.toolbox.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.toolbox.resources.requests.cpu | int | `2` |  |
| gitlab.toolbox.resources.requests.memory | string | `"3.5Gi"` |  |
| gitlab.toolbox.resources.limits.cpu | int | `2` |  |
| gitlab.toolbox.resources.limits.memory | string | `"3.5Gi"` |  |
| gitlab.toolbox.backups.cron.resources.requests.cpu | string | `"350m"` |  |
| gitlab.toolbox.backups.cron.resources.requests.memory | string | `"350Mi"` |  |
| gitlab.toolbox.backups.cron.resources.limits.cpu | string | `"350m"` |  |
| gitlab.toolbox.backups.cron.resources.limits.memory | string | `"350Mi"` |  |
| gitlab.gitlab-exporter.enabled | bool | `false` |  |
| gitlab.gitlab-exporter.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.gitlab-exporter.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.gitlab-exporter.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.resources.limits.cpu | string | `"150m"` |  |
| gitlab.gitlab-exporter.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.resources.requests.cpu | string | `"150m"` |  |
| gitlab.gitlab-exporter.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitlab-exporter.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-exporter"` |  |
| gitlab.gitlab-exporter.image.tag | string | `"14.6.0"` |  |
| gitlab.gitlab-exporter.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.gitlab-exporter.metrics.enabled | bool | `true` |  |
| gitlab.gitlab-exporter.metrics.port | int | `9168` |  |
| gitlab.migrations.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.migrations.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.migrations.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.migrations.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.migrations.resources.limits.cpu | string | `"500m"` |  |
| gitlab.migrations.resources.limits.memory | string | `"1G"` |  |
| gitlab.migrations.resources.requests.cpu | string | `"500m"` |  |
| gitlab.migrations.resources.requests.memory | string | `"1G"` |  |
| gitlab.migrations.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-toolbox"` |  |
| gitlab.migrations.image.tag | string | `"14.6.0"` |  |
| gitlab.migrations.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.webservice.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.webservice.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.webservice.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.webservice.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.webservice.resources.limits.cpu | string | `"600m"` |  |
| gitlab.webservice.resources.limits.memory | string | `"2.5G"` |  |
| gitlab.webservice.resources.requests.cpu | string | `"600m"` |  |
| gitlab.webservice.resources.requests.memory | string | `"2.5G"` |  |
| gitlab.webservice.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-webservice"` |  |
| gitlab.webservice.image.tag | string | `"14.6.0"` |  |
| gitlab.webservice.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.webservice.workhorse.resources.limits.cpu | string | `"600m"` |  |
| gitlab.webservice.workhorse.resources.limits.memory | string | `"2.5G"` |  |
| gitlab.webservice.workhorse.resources.requests.cpu | string | `"600m"` |  |
| gitlab.webservice.workhorse.resources.requests.memory | string | `"2.5G"` |  |
| gitlab.webservice.workhorse.image | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-workhorse"` |  |
| gitlab.webservice.workhorse.tag | string | `"14.6.0"` |  |
| gitlab.webservice.workhorse.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.webservice.ingress.enabled | bool | `false` |  |
| gitlab.sidekiq.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-sidekiq"` |  |
| gitlab.sidekiq.image.tag | string | `"14.6.0"` |  |
| gitlab.sidekiq.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.sidekiq.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.sidekiq.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.sidekiq.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.sidekiq.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.sidekiq.resources.requests.memory | string | `"3G"` |  |
| gitlab.sidekiq.resources.requests.cpu | string | `"1500m"` |  |
| gitlab.sidekiq.resources.limits.memory | string | `"3G"` |  |
| gitlab.sidekiq.resources.limits.cpu | string | `"1500m"` |  |
| gitlab.gitaly.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitaly"` |  |
| gitlab.gitaly.image.tag | string | `"14.6.0"` |  |
| gitlab.gitaly.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.gitaly.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.gitaly.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitaly.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.gitaly.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitaly.resources.requests.cpu | string | `"400m"` |  |
| gitlab.gitaly.resources.requests.memory | string | `"600Mi"` |  |
| gitlab.gitaly.resources.limits.cpu | string | `"400m"` |  |
| gitlab.gitaly.resources.limits.memory | string | `"600Mi"` |  |
| gitlab.gitlab-shell.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitlab-shell"` |  |
| gitlab.gitlab-shell.image.tag | string | `"14.6.0"` |  |
| gitlab.gitlab-shell.image.pullSecrets[0].name | string | `"private-registry"` |  |
| gitlab.gitlab-shell.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.gitlab-shell.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.gitlab-shell.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.gitlab-shell.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.gitlab-shell.resources.limits.cpu | string | `"300m"` |  |
| gitlab.gitlab-shell.resources.limits.memory | string | `"300Mi"` |  |
| gitlab.gitlab-shell.resources.requests.cpu | string | `"300m"` |  |
| gitlab.gitlab-shell.resources.requests.memory | string | `"300Mi"` |  |
| gitlab.praefect.image.repository | string | `"registry1.dso.mil/ironbank/gitlab/gitlab/gitaly"` |  |
| gitlab.praefect.image.tag | string | `"14.6.0"` |  |
| gitlab.praefect.init.resources.limits.cpu | string | `"200m"` |  |
| gitlab.praefect.init.resources.limits.memory | string | `"200Mi"` |  |
| gitlab.praefect.init.resources.requests.cpu | string | `"200m"` |  |
| gitlab.praefect.init.resources.requests.memory | string | `"200Mi"` |  |
| gitlab.praefect.resources.requests.cpu | int | `1` |  |
| gitlab.praefect.resources.requests.memory | string | `"1Gi"` |  |
| gitlab.praefect.resources.limits.cpu | int | `1` |  |
| gitlab.praefect.resources.limits.memory | string | `"1Gi"` |  |
| minio.init.resources.limits.cpu | string | `"200m"` |  |
| minio.init.resources.limits.memory | string | `"200Mi"` |  |
| minio.init.resources.requests.cpu | string | `"200m"` |  |
| minio.init.resources.requests.memory | string | `"200Mi"` |  |
| minio.resources.limits.cpu | string | `"200m"` |  |
| minio.resources.limits.memory | string | `"300Mi"` |  |
| minio.resources.requests.cpu | string | `"200m"` |  |
| minio.resources.requests.memory | string | `"300Mi"` |  |
| minio.image | string | `"registry1.dso.mil/ironbank/opensource/minio/minio"` |  |
| minio.imageTag | string | `"RELEASE.2021-04-06T23-11-00Z"` |  |
| minio.pullSecrets[0].name | string | `"private-registry"` |  |
| minio.minioMc.image | string | `"registry1.dso.mil/ironbank/opensource/minio/mc"` |  |
| minio.minioMc.tag | string | `"RELEASE.2021-03-23T05-46-11Z"` |  |
| minio.minioMc.pullSecrets[0].name | string | `"private-registry"` |  |
| hostname | string | `"bigbang.dev"` |  |
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
| monitoring.enabled | bool | `false` |  |
| networkPolicies.enabled | bool | `false` |  |
| networkPolicies.ingressLabels.app | string | `"istio-ingressgateway"` |  |
| networkPolicies.ingressLabels.istio | string | `"ingressgateway"` |  |
| networkPolicies.controlPlaneCidr | string | `"0.0.0.0/0"` |  |
| openshift | bool | `false` |  |
| use_iam_profile | bool | `false` |  |

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
| gitlab-runner.enabled | bool | `false` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# geo-logcursor

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| enabled | bool | `true` |  |
| replicaCount | int | `1` |  |
| global.geo.role | string | `"primary"` |  |
| global.geo.nodeName | string | `nil` |  |
| global.geo.psql.password | object | `{}` |  |
| global.redis.password | object | `{}` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.gitlab | object | `{}` |  |
| global.hosts.registry | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| redis.password | object | `{}` |  |
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
| affinity | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitaly

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| global.redis.password | object | `{}` |  |
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
| tolerations | list | `[]` |  |
| logging.format | string | `"json"` |  |
| git | object | `{}` |  |
| ruby | object | `{}` |  |
| prometheus | object | `{}` |  |
| workhorse | object | `{}` |  |
| shell.authToken | object | `{}` |  |
| shell.concurrency | list | `[]` |  |
| metrics.enabled | bool | `true` |  |
| metrics.metricsPort | int | `9236` |  |
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
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| statefulset.strategy | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab-exporter

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 11.2.0](https://img.shields.io/badge/AppVersion-11.2.0-informational?style=flat-square)

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
| metrics.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| metrics.annotations."gitlab.com/prometheus_port" | string | `"9168"` |  |
| metrics.annotations."gitlab.com/prometheus_path" | string | `"/metrics"` |  |
| metrics.annotations."prometheus.io/scrape" | string | `"true"` |  |
| metrics.annotations."prometheus.io/port" | string | `"9168"` |  |
| metrics.annotations."prometheus.io/path" | string | `"/metrics"` |  |
| enabled | bool | `true` |  |
| tolerations | list | `[]` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| serviceLabels | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| global.redis.password | object | `{}` |  |
| redis.password | object | `{}` |  |
| psql | object | `{}` |  |
| resources.requests.cpu | string | `"75m"` |  |
| resources.requests.memory | string | `"100M"` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| extraEnv.MALLOC_CONF | string | `"dirty_decay_ms:0,muzzy_decay_ms:0"` |  |
| extraEnv.RUBY_GC_HEAP_INIT_SLOTS | int | `80000` |  |
| extraEnv.RUBY_GC_HEAP_FREE_SLOTS_MIN_RATIO | float | `0.055` |  |
| extraEnv.RUBY_GC_HEAP_FREE_SLOTS_MAX_RATIO | float | `0.111` |  |
| deployment.strategy | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab-grafana

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

Adapt the Grafana chart to interface to the GitLab App

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/gitlab-grafana>
* <https://gitlab.com/gitlab-org/build/CNG/tree/master/gitlab-grafana>

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
helm install gitlab-grafana chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.ingress | object | `{}` |  |
| ingress.apiVersion | string | `nil` |  |
| ingress.tls | object | `{}` |  |
| ingress.annotations | object | `{}` |  |
| ingress.path | string | `nil` |  |
| ingress.proxyBodySize | string | `"0"` |  |
| ingress.proxyReadTimeout | int | `180` |  |
| ingress.proxyConnectTimeout | int | `15` |  |
| common.labels | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab-pages

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 1.49.0](https://img.shields.io/badge/AppVersion-1.49.0-informational?style=flat-square)

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
| hpa.targetAverageValue | string | `"100m"` |  |
| hpa.customMetrics | list | `[]` |  |
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
| service.customDomains.type | string | `"LoadBalancer"` |  |
| service.customDomains.internalHttpsPort | int | `8091` |  |
| service.customDomains.nodePort | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
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
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| priorityClassName | string | `""` |  |
| artifactsServerTimeout | int | `10` |  |
| artifactsServerUrl | string | `nil` |  |
| domainConfigSource | string | `"gitlab"` |  |
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
| useHttp2 | bool | `true` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `9235` |  |
| metrics.annotations | object | `{}` |  |
| workhorse | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# gitlab-shell

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 13.22.1](https://img.shields.io/badge/AppVersion-13.22.1-informational?style=flat-square)

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
| tolerations | list | `[]` |  |
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
| hpa.targetAverageValue | string | `"100m"` |  |
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
| logging.format | string | `"text"` |  |
| logging.sshdLogLevel | string | `"ERROR"` |  |
| config.clientAliveInterval | int | `0` |  |
| config.loginGraceTime | int | `120` |  |
| config.maxStartups.start | int | `10` |  |
| config.maxStartups.rate | int | `30` |  |
| config.maxStartups.full | int | `100` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| metrics.enabled | bool | `false` |  |
| metrics.port | int | `9122` |  |
| metrics.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| metrics.annotations."gitlab.com/prometheus_port" | string | `"9122"` |  |
| metrics.annotations."gitlab.com/prometheus_path" | string | `"/metrics"` |  |
| metrics.annotations."prometheus.io/scrape" | string | `"true"` |  |
| metrics.annotations."prometheus.io/port" | string | `"9122"` |  |
| metrics.annotations."prometheus.io/path" | string | `"/metrics"` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| sshDaemon | string | `"openssh"` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# kas

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.5.0](https://img.shields.io/badge/AppVersion-14.5.0-informational?style=flat-square)

GitLab Kubernetes Agent Server

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
| global.kas.enabled | bool | `false` |  |
| global.redis.password | object | `{}` |  |
| init.image | object | `{}` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| hpa.targetAverageValue | string | `"100m"` |  |
| image.repository | string | `"registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/kas"` |  |
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
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"100M"` |  |
| service.externalPort | int | `8150` |  |
| service.internalPort | int | `8150` |  |
| service.apiInternalPort | int | `8153` |  |
| service.kubernetesApiPort | int | `8154` |  |
| service.privateApiPort | int | `8155` |  |
| service.type | string | `"ClusterIP"` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `8151` |  |
| metrics.path | string | `"/metrics"` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| tolerations | list | `[]` |  |
| workhorse | object | `{}` |  |
| customConfig | object | `{}` |  |
| privateApi | object | `{}` |  |
| deployment.strategy | object | `{}` |  |
| securityContext.runAsUser | int | `65532` |  |
| securityContext.runAsGroup | int | `65532` |  |
| securityContext.fsGroup | int | `65532` |  |
| redis.enabled | bool | `true` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# mailroom

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 0.0.14](https://img.shields.io/badge/AppVersion-0.0.14-informational?style=flat-square)

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
| tolerations | list | `[]` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| global.redis.password | object | `{}` |  |
| global.appConfig.incomingEmail.enabled | bool | `false` |  |
| global.appConfig.incomingEmail.address | string | `nil` |  |
| global.appConfig.incomingEmail.host | string | `nil` |  |
| global.appConfig.incomingEmail.port | int | `993` |  |
| global.appConfig.incomingEmail.ssl | bool | `true` |  |
| global.appConfig.incomingEmail.startTls | bool | `false` |  |
| global.appConfig.incomingEmail.user | string | `nil` |  |
| global.appConfig.incomingEmail.password.secret | string | `""` |  |
| global.appConfig.incomingEmail.password.key | string | `"password"` |  |
| global.appConfig.incomingEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.incomingEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.incomingEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.incomingEmail.idleTimeout | int | `60` |  |
| global.appConfig.incomingEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.incomingEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.incomingEmail.pollInterval | int | `60` |  |
| global.appConfig.serviceDeskEmail.enabled | bool | `false` |  |
| global.appConfig.serviceDeskEmail.address | string | `nil` |  |
| global.appConfig.serviceDeskEmail.host | string | `nil` |  |
| global.appConfig.serviceDeskEmail.port | int | `993` |  |
| global.appConfig.serviceDeskEmail.ssl | bool | `true` |  |
| global.appConfig.serviceDeskEmail.startTls | bool | `false` |  |
| global.appConfig.serviceDeskEmail.user | string | `nil` |  |
| global.appConfig.serviceDeskEmail.password.secret | string | `""` |  |
| global.appConfig.serviceDeskEmail.password.key | string | `"password"` |  |
| global.appConfig.serviceDeskEmail.expungeDeleted | bool | `false` |  |
| global.appConfig.serviceDeskEmail.logger.logPath | string | `"/dev/stdout"` |  |
| global.appConfig.serviceDeskEmail.mailbox | string | `"inbox"` |  |
| global.appConfig.serviceDeskEmail.idleTimeout | int | `60` |  |
| global.appConfig.serviceDeskEmail.inboxMethod | string | `"imap"` |  |
| global.appConfig.serviceDeskEmail.clientSecret.key | string | `"secret"` |  |
| global.appConfig.serviceDeskEmail.pollInterval | int | `60` |  |
| hpa.minReplicas | int | `1` |  |
| hpa.maxReplicas | int | `2` |  |
| hpa.cpu.targetAverageUtilization | int | `75` |  |
| hpa.customMetrics | list | `[]` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| redis.password | object | `{}` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"150M"` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| deployment.strategy | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# migrations

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| tolerations | list | `[]` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| enabled | bool | `true` |  |
| initialRootPassword | object | `{}` |  |
| redis.password | object | `{}` |  |
| gitaly.authToken | object | `{}` |  |
| psql | object | `{}` |  |
| global.psql | object | `{}` |  |
| global.redis.password | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| resources.requests.cpu | string | `"250m"` |  |
| resources.requests.memory | string | `"200Mi"` |  |
| activeDeadlineSeconds | int | `3600` |  |
| backoffLimit | int | `6` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# operator

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

Gitlab operator for managing upgrades

## Upstream References
* <https://about.gitlab.com/>

* <https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/gitlab/charts/operator>
* <https://gitlab.com/gitlab-org/charts/components/gitlab-operator>

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
helm install operator chart/
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"registry.gitlab.com/gitlab-org/charts/components/gitlab-operator"` |  |
| image.pullSecrets | list | `[]` |  |
| version | string | `"0.11"` |  |
| init.resources.requests.cpu | string | `"50m"` |  |
| tolerations | list | `[]` |  |
| podLabels | object | `{}` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"64M"` |  |
| common.labels | object | `{}` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# praefect

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| electionStrategy | string | `"sql"` |  |
| image.repository | string | `"registry.gitlab.com/gitlab-org/build/cng/gitaly"` |  |
| service.tls | object | `{}` |  |
| init.resources | object | `{}` |  |
| init.image | object | `{}` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `9236` |  |
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

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# sidekiq

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| tolerations | list | `[]` |  |
| enabled | bool | `true` |  |
| queueSelector | bool | `false` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| logging.format | string | `"default"` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| metrics.enabled | bool | `true` |  |
| metrics.port | int | `3807` |  |
| metrics.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| metrics.annotations."gitlab.com/prometheus_port" | string | `"3807"` |  |
| metrics.annotations."prometheus.io/scrape" | string | `"true"` |  |
| metrics.annotations."prometheus.io/port" | string | `"3807"` |  |
| health_checks.enabled | bool | `true` |  |
| redis.password | object | `{}` |  |
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
| global.redis.password | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| global.webservice | object | `{}` |  |
| global.minio.enabled | string | `nil` |  |
| global.minio.credentials | object | `{}` |  |
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
| global.appConfig.pseudonymizer.configMap | string | `nil` |  |
| global.appConfig.pseudonymizer.bucket | string | `nil` |  |
| global.appConfig.pseudonymizer.connection | object | `{}` |  |
| global.appConfig.sentry.enabled | bool | `false` |  |
| global.appConfig.sentry.dsn | string | `nil` |  |
| global.appConfig.sentry.clientside_dsn | string | `nil` |  |
| global.appConfig.sentry.environment | string | `nil` |  |
| gitaly.authToken | object | `{}` |  |
| minio.serviceName | string | `"minio-svc"` |  |
| minio.port | int | `9000` |  |
| registry.enabled | bool | `true` |  |
| registry.host | string | `nil` |  |
| registry.api.protocol | string | `"http"` |  |
| registry.api.serviceName | string | `"registry"` |  |
| registry.api.port | int | `5000` |  |
| registry.tokenIssuer | string | `"gitlab-issuer"` |  |
| extra | object | `{}` |  |
| extraEnv | object | `{}` |  |
| rack_attack.git_basic_auth.enabled | bool | `false` |  |
| trusted_proxies | list | `[]` |  |
| minReplicas | int | `1` |  |
| maxReplicas | int | `10` |  |
| concurrency | int | `25` |  |
| deployment.strategy | object | `{}` |  |
| deployment.terminationGracePeriodSeconds | int | `30` |  |
| hpa.targetAverageValue | string | `"350m"` |  |
| timeout | int | `25` |  |
| resources.requests.cpu | string | `"900m"` |  |
| resources.requests.memory | string | `"2G"` |  |
| maxUnavailable | int | `1` |  |
| pods[0].name | string | `"all-in-1"` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| priorityClassName | string | `""` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# toolbox

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| tolerations | list | `[]` |  |
| extraEnv | object | `{}` |  |
| antiAffinityLabels.matchLabels | object | `{}` |  |
| common.labels | object | `{}` |  |
| enabled | bool | `true` |  |
| replicas | int | `1` |  |
| annotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| psql | object | `{}` |  |
| global.hosts.domain | string | `"example.com"` |  |
| global.hosts.hostSuffix | string | `nil` |  |
| global.hosts.https | bool | `true` |  |
| global.hosts.gitlab | object | `{}` |  |
| global.hosts.registry | object | `{}` |  |
| global.hosts.minio | object | `{}` |  |
| global.psql.password | object | `{}` |  |
| global.redis.password | object | `{}` |  |
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
| global.appConfig.pseudonymizer.configMap | string | `nil` |  |
| global.appConfig.pseudonymizer.bucket | string | `nil` |  |
| global.appConfig.pseudonymizer.connection | object | `{}` |  |
| backups.cron.enabled | bool | `false` |  |
| backups.cron.concurrencyPolicy | string | `"Replace"` |  |
| backups.cron.failedJobsHistoryLimit | int | `1` |  |
| backups.cron.schedule | string | `"0 1 * * *"` |  |
| backups.cron.successfulJobsHistoryLimit | int | `3` |  |
| backups.cron.extraArgs | string | `""` |  |
| backups.cron.resources.requests.cpu | string | `"50m"` |  |
| backups.cron.resources.requests.memory | string | `"350M"` |  |
| backups.cron.persistence.enabled | bool | `false` |  |
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
| redis.password | object | `{}` |  |
| gitaly.authToken | object | `{}` |  |
| minio.bucket | string | `"git-lfs"` |  |
| minio.serviceName | string | `"minio-svc"` |  |
| minio.port | int | `9000` |  |
| registry.host | string | `nil` |  |
| registry.api.protocol | string | `"http"` |  |
| registry.api.serviceName | string | `"registry"` |  |
| registry.api.port | int | `5000` |  |
| registry.tokenIssuer | string | `"gitlab-issuer"` |  |
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
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| deployment.strategy.type | string | `"Recreate"` |  |
| deployment.strategy.rollingUpdate | string | `nil` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
# webservice

![Version: 5.6.0](https://img.shields.io/badge/Version-5.6.0-informational?style=flat-square) ![AppVersion: 14.6.0](https://img.shields.io/badge/AppVersion-14.6.0-informational?style=flat-square)

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
| tolerations | list | `[]` |  |
| monitoring.ipWhitelist[0] | string | `"0.0.0.0/0"` |  |
| monitoring.exporter.enabled | bool | `false` |  |
| monitoring.exporter.port | int | `8083` |  |
| shutdown.blackoutSeconds | int | `10` |  |
| extraEnv | object | `{}` |  |
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
| metrics.annotations."gitlab.com/prometheus_scrape" | string | `"true"` |  |
| metrics.annotations."gitlab.com/prometheus_port" | string | `"8080"` |  |
| metrics.annotations."gitlab.com/prometheus_path" | string | `"/-/metrics"` |  |
| metrics.annotations."prometheus.io/scrape" | string | `"true"` |  |
| metrics.annotations."prometheus.io/port" | string | `"8080"` |  |
| metrics.annotations."prometheus.io/path" | string | `"/-/metrics"` |  |
| networkpolicy.enabled | bool | `false` |  |
| networkpolicy.egress.enabled | bool | `false` |  |
| networkpolicy.egress.rules | list | `[]` |  |
| networkpolicy.ingress.enabled | bool | `false` |  |
| networkpolicy.ingress.rules | list | `[]` |  |
| networkpolicy.annotations | object | `{}` |  |
| service.type | string | `"ClusterIP"` |  |
| service.externalPort | int | `8080` |  |
| service.internalPort | int | `8080` |  |
| service.workhorseExternalPort | int | `8181` |  |
| service.workhorseInternalPort | int | `8181` |  |
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
| workerProcesses | int | `2` |  |
| puma.workerMaxMemory | int | `1024` |  |
| puma.threads.min | int | `4` |  |
| puma.threads.max | int | `4` |  |
| puma.disableWorkerKiller | bool | `false` |  |
| hpa.targetAverageValue | int | `1` |  |
| hpa.customMetrics | string | `nil` |  |
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
| workhorse.keywatcher | bool | `true` |  |
| workhorse.sentryDSN | string | `""` |  |
| workhorse.extraArgs | string | `""` |  |
| workhorse.logFormat | string | `"json"` |  |
| workhorse.resources.requests.cpu | string | `"100m"` |  |
| workhorse.resources.requests.memory | string | `"100M"` |  |
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
| workhorse.imageScaler.maxProcs | int | `2` |  |
| workhorse.imageScaler.maxFileSizeBytes | int | `250000` |  |
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
| global.redis.password | object | `{}` |  |
| global.gitaly.internal.names[0] | string | `"default"` |  |
| global.gitaly.external | list | `[]` |  |
| global.gitaly.authToken | object | `{}` |  |
| global.minio.enabled | string | `nil` |  |
| global.minio.credentials | object | `{}` |  |
| global.webservice | object | `{}` |  |
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
| redis.password | object | `{}` |  |
| gitaly.authToken | object | `{}` |  |
| minio.serviceName | string | `"minio-svc"` |  |
| minio.port | int | `9000` |  |
| registry.enabled | bool | `true` |  |
| registry.host | string | `nil` |  |
| registry.api.protocol | string | `"http"` |  |
| registry.api.serviceName | string | `"registry"` |  |
| registry.api.port | int | `5000` |  |
| registry.tokenIssuer | string | `"gitlab-issuer"` |  |
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
| serviceAccount.enabled | bool | `false` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.annotations | object | `{}` |  |
| priorityClassName | string | `""` |  |
| deployments | object | `{}` |  |

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
| defaultBuckets[0].name | string | `"registry"` |  |
| defaultBuckets[1].name | string | `"git-lfs"` |  |
| defaultBuckets[2].name | string | `"runner-cache"` |  |
| defaultBuckets[3].name | string | `"gitlab-uploads"` |  |
| defaultBuckets[4].name | string | `"gitlab-artifacts"` |  |
| defaultBuckets[5].name | string | `"gitlab-backups"` |  |
| defaultBuckets[6].name | string | `"gitlab-packages"` |  |
| defaultBuckets[7].name | string | `"tmp"` |  |
| defaultBuckets[8].name | string | `"gitlab-pseudo"` |  |
| defaultBuckets[9].name | string | `"gitlab-mr-diffs"` |  |
| defaultBuckets[10].name | string | `"gitlab-terraform-state"` |  |
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
| controller.image.registry | string | `"k8s.gcr.io"` |  |
| controller.image.repository | string | `"registry.gitlab.com/gitlab-org/cloud-native/mirror/images/ingress-nginx/controller"` |  |
| controller.image.tag | string | `"v1.0.4"` |  |
| controller.image.digest | string | `"sha256:a7fb797e0b1c919a49cf9b3f9bb90ebca39bc85d0edd11c9a5cf897da5eb5a3f"` |  |
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
| controller.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
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
| controller.admissionWebhooks.patch.image.registry | string | `"k8s.gcr.io"` |  |
| controller.admissionWebhooks.patch.image.image | string | `"ingress-nginx/kube-webhook-certgen"` |  |
| controller.admissionWebhooks.patch.image.tag | string | `"v1.1.1"` |  |
| controller.admissionWebhooks.patch.image.digest | string | `"sha256:64d8c73dca984af206adf9d6d7e46aa550362b1d7a01f3a0a91b20cc67868660"` |  |
| controller.admissionWebhooks.patch.image.pullPolicy | string | `"IfNotPresent"` |  |
| controller.admissionWebhooks.patch.priorityClassName | string | `""` |  |
| controller.admissionWebhooks.patch.podAnnotations | object | `{}` |  |
| controller.admissionWebhooks.patch.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
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
| defaultBackend.nodeSelector."kubernetes.io/os" | string | `"linux"` |  |
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
# registry

![Version: 0.7.0](https://img.shields.io/badge/Version-0.7.0-informational?style=flat-square) ![AppVersion: v3.8.0-gitlab](https://img.shields.io/badge/AppVersion-v3.8.0--gitlab-informational?style=flat-square)

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
| image.tag | string | `"v3.19.0-gitlab"` |  |
| deployment.terminationGracePeriodSeconds | int | `30` |  |
| deployment.readinessProbe.enabled | bool | `true` |  |
| deployment.readinessProbe.path | string | `"/debug/health"` |  |
| deployment.readinessProbe.initialDelaySeconds | int | `5` |  |
| deployment.readinessProbe.periodSeconds | int | `5` |  |
| deployment.readinessProbe.timeoutSeconds | int | `1` |  |
| deployment.readinessProbe.successThreshold | int | `1` |  |
| deployment.readinessProbe.failureThreshold | int | `3` |  |
| deployment.livenessProbe.enabled | bool | `true` |  |
| deployment.livenessProbe.path | string | `"/debug/health"` |  |
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
| init.script | string | `"if [ -e /config/accesskey ] ; then\n  sed -e 's@ACCESS_KEY@'\"$(cat /config/accesskey)\"'@' -e 's@SECRET_KEY@'\"$(cat /config/secretkey)\"'@' /config/config.yml > /registry/config.yml\nelse\n  cp -v -r -L /config/config.yml  /registry/config.yml\nfi\n# Place the `http.secret` value from the kubernetes secret\nsed -i -e 's@HTTP_SECRET@'\"$(cat /config/httpSecret)\"'@' /registry/config.yml\n# Populate sensitive registry notification secrets in the config file\nif [ -d /config/notifications ]; then\n  for i in /config/notifications/*; do\n    filename=$(basename $i);\n    sed -i -e 's@'\"${filename}\"'@'\"$(cat $i)\"'@' /registry/config.yml;\n  done\nfi\n# Insert any provided `storage` block from kubernetes secret\nif [ -d /config/storage ]; then\n  # Copy contents of storage secret(s)\n  mkdir -p /registry/storage\n  cp -v -r -L /config/storage/* /registry/storage/\n  # Ensure there is a new line in the end\n  echo '' >> /registry/storage/config\n  # Default `delete.enabled: true` if not present.\n  ## Note: busybox grep doesn't support multiline, so we chain `egrep`.\n  if ! $(egrep -A1 '^delete:\\s*$' /registry/storage/config | egrep -q '\\s{2,4}enabled:') ; then\n    echo 'delete:' >> /registry/storage/config\n    echo '  enabled: true' >> /registry/storage/config\n  fi\n  # Indent /registry/storage/config 2 spaces before inserting into config.yml\n  sed -i 's/^/  /' /registry/storage/config\n  # Insert into /registry/config.yml after `storage:`\n  sed -i '/storage:/ r /registry/storage/config' /registry/config.yml\n  # Remove the now extraneous `config` file\n  rm /registry/storage/config\nfi\n# Set to known path, to used ConfigMap\ncat /config/certificate.crt > /registry/certificate.crt\n# Copy the optional profiling keyfile to the expected location\nif [ -f /config/profiling-key.json ]; then\n  cp /config/profiling-key.json /registry/profiling-key.json\nfi\n# Insert Database password, if enabled\nif [ -f /config/database_password ] ; then\n  sed -i -e 's@DB_PASSWORD_FILE@'\"$(cat /config/database_password)\"'@' /registry/config.yml\nfi\n# Copy the database TLS connection files to the expected location and set permissions\nif [ -d /config/ssl ]; then\n  cp -r /config/ssl/ /registry/ssl\n  chmod 700 /registry/ssl\n  chmod 600 /registry/ssl/*.pem\nfi"` |  |
| resources.requests.cpu | string | `"50m"` |  |
| resources.requests.memory | string | `"32Mi"` |  |
| nodeSelector | object | `{}` |  |
| authEndpoint | string | `nil` |  |
| tokenService | string | `"container_registry"` |  |
| tokenIssuer | string | `"gitlab-issuer"` |  |
| authAutoRedirect | bool | `false` |  |
| maxUnavailable | int | `1` |  |
| hpa.minReplicas | int | `2` |  |
| hpa.maxReplicas | int | `10` |  |
| hpa.cpu.targetAverageUtilization | int | `75` |  |
| hpa.customMetrics | list | `[]` |  |
| storage | object | `{}` |  |
| minio.redirect | bool | `false` |  |
| compatibility.schema1.enabled | bool | `false` |  |
| validation.disabled | bool | `true` |  |
| validation.manifests.referencelimit | int | `0` |  |
| validation.manifests.urls.allow | list | `[]` |  |
| validation.manifests.urls.deny | list | `[]` |  |
| log.level | string | `"info"` |  |
| log.fields.service | string | `"registry"` |  |
| debug.addr.port | int | `5001` |  |
| debug.prometheus.enabled | bool | `false` |  |
| debug.prometheus.path | string | `"/metrics"` |  |
| draintimeout | string | `"0"` |  |
| relativeurls | bool | `false` |  |
| health.storagedriver.enabled | bool | `false` |  |
| health.storagedriver.interval | string | `"10s"` |  |
| health.storagedriver.threshold | int | `3` |  |
| securityContext.runAsUser | int | `1000` |  |
| securityContext.fsGroup | int | `1000` |  |
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
| migration.enabled | bool | `false` |  |
| migration.disablemirrorfs | bool | `false` |  |
| gc.disabled | bool | `true` |  |

## Contributing

Please see the [contributing guide](./CONTRIBUTING.md) if you are interested in contributing.
