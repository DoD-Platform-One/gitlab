---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GitLab Helm chart deployment options
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

This page lists commonly used values of the GitLab chart. For a complete list of the available options, refer
to the documentation for each subchart.

You can pass values to the `helm install` command by using a YAML file and the `--values <values file>`
flag or by using multiple `--set` flags. It is recommended to use a values file that contains only the
overrides needed for your release.

For the source of the default `values.yaml` file, see the [GitLab chart repository](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/values.yaml).
These contents change over releases, but you can use Helm itself to retrieve these on a per-version basis:

```shell
helm inspect values gitlab/gitlab
```

## Basic configuration

| Parameter                                            | Default                                       | Description |
|------------------------------------------------------|-----------------------------------------------|-------------|
| `gitlab.migrations.initialRootPassword.key`          | `password`                                    | Key pointing to the root account password in the migrations secret |
| `gitlab.migrations.initialRootPassword.secret`       | `{Release.Name}-gitlab-initial-root-password` | Global name of the secret containing the root account password |
| `global.gitlab.license.key`                          | `license`                                     | Key pointing to the Enterprise license in the license secret |
| `global.gitlab.license.secret`                       | _none_                                        | Global name of the secret containing the Enterprise license |
| `global.application.create`                          | `false`                                       | Create an [Application resource](https://github.com/kubernetes-sigs/application) for GitLab |
| `global.edition`                                     | `ee`                                          | The edition of GitLab to install. Enterprise Edition (`ee`) or Community Edition (`ce`) |
| `global.gitaly.enabled`                              | `true`                                        | Gitaly enable flag |
| `global.hosts.domain`                                | Required                                      | Domain name that will be used for all publicly exposed services |
| `global.hosts.externalIP`                            | Required                                      | Static IP to assign to NGINX Ingress Controller |
| `global.hosts.ssh`                                   | `gitlab.{global.hosts.domain}`                | Domain name that will be used for Git SSH access |
| `global.imagePullPolicy`                             | `IfNotPresent`                                | DEPRECATED: Use `global.image.pullPolicy` instead |
| `global.image.pullPolicy`                            | _none_ (default behavior is `IfNotPresent`)   | Set default imagePullPolicy for all charts |
| `global.image.pullSecrets`                           | _none_                                        | Set default imagePullSecrets for all charts (use a list of `name` and value pairs) |
| `global.minio.enabled`                               | `true`                                        | MinIO enable flag |
| `global.psql.host`                                   | _Uses in-cluster non-production PostgreSQL_   | Global hostname of an external psql, overrides subcharts' psql configuration |
| `global.psql.password.key`                           | _Uses in-cluster non-production PostgreSQL_   | Key pointing to the psql password in the psql secret |
| `global.psql.password.secret`                        | _Uses in-cluster non-production PostgreSQL_   | Global name of the secret containing the psql password |
| `global.registry.bucket`                             | `registry`                                    | registry bucket name |
| `global.service.annotations`                         | `{}`                                          | Annotations to add to every `Service` |
| `global.rails.sessionStore.sessionCookieTokenPrefix` | `""`                                          | Prefix for the generated session cookies |
| `global.deployment.annotations`                      | `{}`                                          | Annotations to add to every `Deployment` |
| `global.time_zone`                                   | UTC                                           | Global time zone |

## TLS configuration

| Parameter                                           | Default | Description |
|-----------------------------------------------------|---------|-------------|
| `certmanager-issuer.email`                          | `false` | Email for Let's Encrypt account |
| `gitlab.webservice.ingress.tls.secretName`          | _none_  | Existing `Secret` containing TLS certificate and key for GitLab |
| `gitlab.webservice.ingress.tls.smartcardSecretName` | _none_  | Existing `Secret` containing TLS certificate and key for the GitLab smartcard auth domain |
| `global.hosts.https`                                | `true`  | Serve over https |
| `global.ingress.configureCertmanager`               | `true`  | Configure cert-manager to get certificates from Let's Encrypt |
| `global.ingress.tls.secretName`                     | _none_  | Existing `Secret` containing wildcard TLS certificate and key |
| `minio.ingress.tls.secretName`                      | _none_  | Existing `Secret` containing TLS certificate and key for MinIO |
| `registry.ingress.tls.secretName`                   | _none_  | Existing `Secret` containing TLS certificate and key for registry |

## Outgoing Email configuration

| Parameter                         | Default               | Description |
|-----------------------------------|-----------------------|-------------|
| `global.email.display_name`       | `GitLab`              | Name that appears as the sender for emails from GitLab |
| `global.email.from`               | `gitlab@example.com`  | Email address that appears as the sender for emails from GitLab |
| `global.email.reply_to`           | `noreply@example.com` | Reply-to email listed in emails from GitLab |
| `global.email.smime.certName`     | `tls.crt`             | Secret object key value for locating the S/MIME certificate file |
| `global.email.smime.enabled`      | `false`               | Add the S/MIME signatures to outgoing email |
| `global.email.smime.keyName`      | `tls.key`             | Secret object key value for locating the S/MIME key file |
| `global.email.smime.secretName`   | `""`                  | Kubernetes Secret object to find the X.509 certificate ([S/MIME Cert](secrets.md#smime-certificate) for creation ) |
| `global.email.subject_suffix`     | `""`                  | Suffix on the subject of all outgoing email from GitLab |
| `global.smtp.address`             | `smtp.mailgun.org`    | Hostname or IP of the remote mail server |
| `global.smtp.authentication`      | `plain`               | Type of SMTP authentication ("plain", "login", "cram_md5", or "" for no authentication) |
| `global.smtp.domain`              | `""`                  | Optional HELO domain for SMTP |
| `global.smtp.enabled`             | `false`               | Enable outgoing email |
| `global.smtp.openssl_verify_mode` | `peer`                | TLS verification mode ("none", "peer", "client_once", or "fail_if_no_peer_cert") |
| `global.smtp.password.key`        | `password`            | Key in `global.smtp.password.secret` that contains the SMTP password |
| `global.smtp.password.secret`     | `""`                  | Name of a `Secret` containing the SMTP password |
| `global.smtp.port`                | `2525`                | Port for SMTP |
| `global.smtp.starttls_auto`       | `false`               | Use STARTTLS if enabled on the mail server |
| `global.smtp.tls`                 | _none_                | Enables SMTP/TLS (SMTPS: SMTP over direct TLS connection) |
| `global.smtp.user_name`           | `""`                  | Username for SMTP authentication https |
| `global.smtp.open_timeout`        | `30`                  | Seconds to wait while attempting to open a connection. |
| `global.smtp.read_timeout`        | `60`                  | Seconds to wait while reading one block. |
| `global.smtp.pool`                | `false`               | Enables SMTP connection pooling |

### Microsoft Graph Mailer settings

| Parameter                                                      | Default                             | Description |
|----------------------------------------------------------------|-------------------------------------|-------------|
| `global.appConfig.microsoft_graph_mailer.enabled`              | `false`                             | Enable outgoing email via Microsoft Graph API |
| `global.appConfig.microsoft_graph_mailer.user_id`              | `""`                                | The unique identifier for the user that uses the Microsoft Graph API |
| `global.appConfig.microsoft_graph_mailer.tenant`               | `""`                                | The directory tenant the application plans to operate against, in GUID or domain-name format |
| `global.appConfig.microsoft_graph_mailer.client_id`            | `""`                                | The application ID that's assigned to your app. You can find this information in the portal where you registered your app |
| `global.appConfig.microsoft_graph_mailer.client_secret.key`    | `secret`                            | Key in `global.appConfig.microsoft_graph_mailer.client_secret.secret` that contains the client secret that you generated for your app in the app registration portal |
| `global.appConfig.microsoft_graph_mailer.client_secret.secret` | `""`                                | Name of a `Secret` containing the client secret that you generated for your app in the app registration portal |
| `global.appConfig.microsoft_graph_mailer.azure_ad_endpoint`    | `https://login.microsoftonline.com` | The URL of the Azure Active Directory endpoint |
| `global.appConfig.microsoft_graph_mailer.graph_endpoint`       | `https://graph.microsoft.com`       | The URL of the Microsoft Graph endpoint |

## Incoming Email configuration

### Common settings

See [incoming email configuration examples documentation](https://docs.gitlab.com/administration/incoming_email/#configuration-examples)
for more information.

| Parameter                                            | Default                                    | Description |
|------------------------------------------------------|--------------------------------------------|-------------|
| `global.appConfig.incomingEmail.address`             | empty                                      | The email address to reference the item being replied to (example: `gitlab-incoming+%{key}@gmail.com`). Note that the `+%{key}` suffix should be included in its entirety within the email address and not replaced by another value. |
| `global.appConfig.incomingEmail.enabled`             | `false`                                    | Enable incoming email |
| `global.appConfig.incomingEmail.deleteAfterDelivery` | `true`                                     | Whether to mark messages as deleted. For IMAP, messages that are marked as deleted are expunged if `expungedDeleted` is set to `true`. For Microsoft Graph, set this to false to retain messages in the inbox because deleted messages are auto-expunged after some time. |
| `global.appConfig.incomingEmail.expungeDeleted`      | `false`                                    | Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery. Only relevant to IMAP because Microsoft Graph will auto-expunge deleted messages. |
| `global.appConfig.incomingEmail.logger.logPath`      | `/dev/stdout`                              | Path to write JSON structured logs to; set to "" to disable this logging |
| `global.appConfig.incomingEmail.inboxMethod`         | `imap`                                     | Read mail with IMAP (`imap`) or Microsoft Graph API with OAuth2 (`microsoft_graph`) |
| `global.appConfig.incomingEmail.deliveryMethod`      | `webhook`                                  | How mailroom can send an email content to Rails app for processing. Either `sidekiq` or `webhook` |
| `gitlab.appConfig.incomingEmail.authToken.key`       | `authToken`                                | Key to incoming email token in incoming email secret. Effective when the delivery method is webhook. |
| `gitlab.appConfig.incomingEmail.authToken.secret`    | `{Release.Name}-incoming-email-auth-token` | Incoming email authentication secret. Effective when the delivery method is webhook. |

### IMAP settings

| Parameter                                        | Default    | Description |
|--------------------------------------------------|------------|-------------|
| `global.appConfig.incomingEmail.host`            | empty      | Host for IMAP |
| `global.appConfig.incomingEmail.idleTimeout`     | `60`       | The IDLE command timeout |
| `global.appConfig.incomingEmail.mailbox`         | `inbox`    | Mailbox where incoming mail will end up. |
| `global.appConfig.incomingEmail.password.key`    | `password` | Key in `global.appConfig.incomingEmail.password.secret` that contains the IMAP password |
| `global.appConfig.incomingEmail.password.secret` | empty      | Name of a `Secret` containing the IMAP password |
| `global.appConfig.incomingEmail.port`            | `993`      | Port for IMAP |
| `global.appConfig.incomingEmail.ssl`             | `true`     | Whether IMAP server uses SSL |
| `global.appConfig.incomingEmail.startTls`        | `false`    | Whether IMAP server uses StartTLS |
| `global.appConfig.incomingEmail.user`            | empty      | Username for IMAP authentication |

### Microsoft Graph settings

| Parameter                                            | Default | Description |
|------------------------------------------------------|---------|-------------|
| `global.appConfig.incomingEmail.tenantId`            | empty   | The tenant ID for your Microsoft Azure Active Directory |
| `global.appConfig.incomingEmail.clientId`            | empty   | The client ID for your OAuth2 app |
| `global.appConfig.incomingEmail.clientSecret.key`    | empty   | Key in `appConfig.incomingEmail.clientSecret.secret` that contains the OAuth2 client secret |
| `global.appConfig.incomingEmail.clientSecret.secret` | secret  | Name of a `Secret` containing the OAuth2 client secret |
| `global.appConfig.incomingEmail.pollInterval`        | `60`    | The interval in seconds how often to poll for new mail |
| `global.appConfig.incomingEmail.azureAdEndpoint`     | empty   | The URL of the Azure Active Directory endpoint (example: `https://login.microsoftonline.com`) |
| `global.appConfig.incomingEmail.graphEndpoint`       | empty   | The URL of the Microsoft Graph endpoint (example: `https://graph.microsoft.com`) |

See the [instructions for creating secrets](secrets.md).

## Service Desk Email configuration

As a requirement for Service Desk, the Incoming Mail must be [configured](#incoming-email-configuration).
Note that the email address for both Incoming Mail and Service Desk must use
[email sub-addressing](https://docs.gitlab.com/administration/incoming_email/#email-sub-addressing).
When setting the email addresses in each section the tag added to the username
must be `+%{key}`.

### Common settings

| Parameter                                               | Default                                        | Description |
|---------------------------------------------------------|------------------------------------------------|-------------|
| `global.appConfig.serviceDeskEmail.address`             | empty                                          | The email address to reference the item being replied to (example: `project_contact+%{key}@gmail.com`) |
| `global.appConfig.serviceDeskEmail.enabled`             | `false`                                        | Enable Service Desk email |
| `global.appConfig.serviceDeskEmail.deleteAfterDelivery` | `true`                                         | Whether to mark messages as deleted. For IMAP, messages that are marked as deleted are expunged if `expungedDeleted` is set to `true`. For Microsoft Graph, set this to false to retain messages in the inbox because deleted messages are auto-expunged after some time. |
| `global.appConfig.serviceDeskEmail.expungeDeleted`      | `false`                                        | Whether to expunge (permanently remove) messages from the mailbox when they are marked as deleted after delivery. Only relevant to IMAP because Microsoft Graph auto-expunges deleted messages. |
| `global.appConfig.serviceDeskEmail.logger.logPath`      | `/dev/stdout`                                  | Path to write JSON structured logs to; set to "" to disable this logging |
| `global.appConfig.serviceDeskEmail.inboxMethod`         | `imap`                                         | Read mail with IMAP (`imap`) or Microsoft Graph API with OAuth2 (`microsoft_graph`) |
| `global.appConfig.serviceDeskEmail.deliveryMethod`      | `webhook`                                      | How mailroom can send an email content to Rails app for processing. Either `sidekiq` or `webhook` |
| `gitlab.appConfig.serviceDeskEmail.authToken.key`       | `authToken`                                    | Key to Service Desk email token in Service Desk email secret. Effective when the delivery method is webhook. |
| `gitlab.appConfig.serviceDeskEmail.authToken.secret`    | `{Release.Name}-service-desk-email-auth-token` | service-desk email authentication secret. Effective when the delivery method is webhook. |

### IMAP settings

| Parameter                                           | Default    | Description |
|-----------------------------------------------------|------------|-------------|
| `global.appConfig.serviceDeskEmail.host`            | empty      | Host for IMAP |
| `global.appConfig.serviceDeskEmail.idleTimeout`     | `60`       | The IDLE command timeout |
| `global.appConfig.serviceDeskEmail.mailbox`         | `inbox`    | Mailbox where Service Desk mail will end up. |
| `global.appConfig.serviceDeskEmail.password.key`    | `password` | Key in `global.appConfig.serviceDeskEmail.password.secret` that contains the IMAP password |
| `global.appConfig.serviceDeskEmail.password.secret` | empty      | Name of a `Secret` containing the IMAP password |
| `global.appConfig.serviceDeskEmail.port`            | `993`      | Port for IMAP |
| `global.appConfig.serviceDeskEmail.ssl`             | `true`     | Whether IMAP server uses SSL |
| `global.appConfig.serviceDeskEmail.startTls`        | `false`    | Whether IMAP server uses StartTLS |
| `global.appConfig.serviceDeskEmail.user`            | empty      | Username for IMAP authentication |

### Microsoft Graph settings

| Parameter                                               | Default | Description |
|---------------------------------------------------------|---------|-------------|
| `global.appConfig.serviceDeskEmail.tenantId`            | empty   | The tenant ID for your Microsoft Azure Active Directory |
| `global.appConfig.serviceDeskEmail.clientId`            | empty   | The client ID for your OAuth2 app |
| `global.appConfig.serviceDeskEmail.clientSecret.key`    | empty   | Key in `appConfig.serviceDeskEmail.clientSecret.secret` that contains the OAuth2 client secret |
| `global.appConfig.serviceDeskEmail.clientSecret.secret` | secret  | Name of a `Secret` containing the OAuth2 client secret |
| `global.appConfig.serviceDeskEmail.pollInterval`        | `60`    | The interval in seconds how often to poll for new mail |
| `global.appConfig.serviceDeskEmail.azureAdEndpoint`     | empty   | The URL of the Azure Active Directory endpoint (example: `https://login.microsoftonline.com`) |
| `global.appConfig.serviceDeskEmail.graphEndpoint`       | empty   | The URL of the Microsoft Graph endpoint (example: `https://graph.microsoft.com`) |

See the [instructions for creating secrets](secrets.md).

## Default Project Features configuration

| Parameter                                                    | Default | Description |
|--------------------------------------------------------------|---------|-------------|
| `global.appConfig.defaultProjectsFeatures.builds`            | `true`  | Enable project builds |
| `global.appConfig.defaultProjectsFeatures.containerRegistry` | `true`  | Enable container registry project features |
| `global.appConfig.defaultProjectsFeatures.issues`            | `true`  | Enable project issues |
| `global.appConfig.defaultProjectsFeatures.mergeRequests`     | `true`  | Enable project merge requests |
| `global.appConfig.defaultProjectsFeatures.snippets`          | `true`  | Enable project snippets |
| `global.appConfig.defaultProjectsFeatures.wiki`              | `true`  | Enable project wikis |

## GitLab Shell

| Parameter                        | Default | Description |
|----------------------------------|---------|-------------|
| `global.shell.authToken`         |         | Secret containing shared secret |
| `global.shell.hostKeys`          |         | Secret containing SSH host keys |
| `global.shell.port`              |         | Port number to expose on Ingress for SSH |
| `global.shell.tcp.proxyProtocol` | `false` | Enable ProxyProtocol in SSH Ingress |

## RBAC Settings

| Parameter                              | Default | Description |
|----------------------------------------|---------|-------------|
| `certmanager.rbac.create`              | `true`  | Create and use RBAC resources |
| `gitlab-runner.rbac.create`            | `true`  | Create and use RBAC resources |
| `nginx-ingress.rbac.create`            | `false` | Create and use default RBAC resources |
| `nginx-ingress.rbac.createClusterRole` | `false` | Create and use Cluster role |
| `nginx-ingress.rbac.createRole`        | `true`  | Create and use namespaced role |
| `prometheus.rbac.create`               | `true`  | Create and use RBAC resources |

If you're setting `nginx-ingress.rbac.create` to `false` to configure the RBAC rules by yourself, you
might need to add specific RBAC rules
[depending on your chart version](../releases/8_0.md#upgrade-to-86x-851-843-836).

## Advanced NGINX Ingress configuration

Prefix NGINX Ingress values with `nginx-ingress`. For example, set the controller image tag using `nginx-ingress.controller.image.tag`.

See [`nginx-ingress` chart](../charts/nginx/_index.md).

## Advanced in-cluster Redis configuration

| Parameter                 | Default               | Description |
|---------------------------|-----------------------|-------------|
| `redis.install`           | `true`                | Install the `bitnami/redis` chart |
| `redis.existingSecret`    | `gitlab-redis-secret` | Specify the Secret for Redis servers to use |
| `redis.existingSecretKey` | `redis-password`      | Secret key where password is stored |

Any additional configuration of the Redis service should use the configuration
settings from the [Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis).

## Advanced registry configuration

| Parameter                                           | Default                                     | Description |
|-----------------------------------------------------|---------------------------------------------|-------------|
| `registry.authEndpoint`                             | Undefined by default                        | Auth endpoint |
| `registry.enabled`                                  | `true`                                      | Enable Docker registry |
| `registry.httpSecret`                               |                                             | Https secret |
| `registry.minio.bucket`                             | `registry`                                  | MinIO registry bucket name |
| `registry.service.annotations`                      | `{}`                                        | Annotations to add to the `Service` |
| `registry.securityContext.fsGroup`                  | `1000`                                      | Group ID under which the pod should be started |
| `registry.securityContext.runAsUser`                | `1000`                                      | User ID under which the pod should be started |
| `registry.tokenIssuer`                              | `gitlab-issuer`                             | JWT token issuer |
| `registry.tokenService`                             | `container_registry`                        | JWT token service |
| `registry.profiling.stackdriver.enabled`            | `false`                                     | Enable continuous profiling using Stackdriver |
| `registry.profiling.stackdriver.credentials.secret` | `gitlab-registry-profiling-creds`           | Name of the secret containing credentials |
| `registry.profiling.stackdriver.credentials.key`    | `credentials`                               | Secret key in which the credentials are stored |
| `registry.profiling.stackdriver.service`            | `RELEASE-registry` (templated Service name) | Name of the Stackdriver service to record profiles under |
| `registry.profiling.stackdriver.projectid`          | GCP project where running                   | GCP project to report profiles to |

## Advanced MinIO configuration

| Parameter                            | Default                        | Description |
|--------------------------------------|--------------------------------|-------------|
| `minio.defaultBuckets`               | `[{"name": "registry"}]`       | MinIO default buckets |
| `minio.image`                        | `minio/minio`                  | MinIO image |
| `minio.imagePullPolicy`              |                                | MinIO image pull policy |
| `minio.imageTag`                     | `RELEASE.2017-12-28T01-21-00Z` | MinIO image tag |
| `minio.minioConfig.browser`          | `on`                           | MinIO browser flag |
| `minio.minioConfig.domain`           |                                | MinIO domain |
| `minio.minioConfig.region`           | `us-east-1`                    | MinIO region |
| `minio.mountPath`                    | `/export`                      | MinIO configuration file mount path |
| `minio.persistence.accessMode`       | `ReadWriteOnce`                | MinIO persistence access mode |
| `minio.persistence.enabled`          | `true`                         | MinIO enable persistence flag |
| `minio.persistence.matchExpressions` |                                | MinIO label-expression matches to bind |
| `minio.persistence.matchLabels`      |                                | MinIO label-value matches to bind |
| `minio.persistence.size`             | `10Gi`                         | MinIO persistence volume size |
| `minio.persistence.storageClass`     |                                | MinIO storageClassName for provisioning |
| `minio.persistence.subPath`          |                                | MinIO persistence volume mount path |
| `minio.persistence.volumeName`       |                                | MinIO existing persistent volume name |
| `minio.resources.requests.cpu`       | `250m`                         | MinIO minimum CPU requested |
| `minio.resources.requests.memory`    | `256Mi`                        | MinIO minimum memory requested |
| `minio.service.annotations`          | `{}`                           | Annotations to add to the `Service` |
| `minio.servicePort`                  | `9000`                         | MinIO service port |
| `minio.serviceType`                  | `ClusterIP`                    | MinIO service type |

## Advanced GitLab configuration

| Parameter                                                  | Default                                                         | Description |
|------------------------------------------------------------|-----------------------------------------------------------------|-------------|
| `gitlab-runner.checkInterval`                              | `30s`                                                           | polling interval |
| `gitlab-runner.concurrent`                                 | `20`                                                            | number of concurrent jobs |
| `gitlab-runner.imagePullPolicy`                            | `IfNotPresent`                                                  | image pull policy |
| `gitlab-runner.image`                                      | `gitlab/gitlab-runner:alpine-v10.5.0`                           | runner image |
| `gitlab-runner.gitlabUrl`                                  | GitLab external URL                                             | URL that the Runner uses to register to GitLab Server |
| `gitlab-runner.install`                                    | `true`                                                          | install the `gitlab-runner` chart |
| `gitlab-runner.rbac.clusterWideAccess`                     | `false`                                                         | deploy containers of jobs cluster-wide |
| `gitlab-runner.rbac.create`                                | `true`                                                          | whether to create RBAC service account |
| `gitlab-runner.rbac.serviceAccountName`                    | `default`                                                       | name of the RBAC service account to create |
| `gitlab-runner.resources.limits.cpu`                       |                                                                 | runner resources |
| `gitlab-runner.resources.limits.memory`                    |                                                                 | runner resources |
| `gitlab-runner.resources.requests.cpu`                     |                                                                 | runner resources |
| `gitlab-runner.resources.requests.memory`                  |                                                                 | runner resources |
| `gitlab-runner.runners.privileged`                         | `false`                                                         | run in privileged mode, needed for `dind` |
| `gitlab-runner.runners.cache.secretName`                   | `gitlab-minio`                                                  | secret to get `accesskey` and `secretkey` from |
| `gitlab-runner.runners.config`                             | See [Chart documentation](../charts/gitlab/gitlab-runner/_index.md#default-runner-configuration) | Runner configuration as string |
| `gitlab-runner.unregisterRunners`                          | `true`                                                          | Unregisters all runners in the local `config.toml` when the chart is installed. If the token is prefixed with `glrt-`, the runner manager is deleted, not the runner. The runner manager is identified by the runner and the machine that contains the `config.toml`. If the runner was registered with a registration token, the runner is deleted. |
| `gitlab.geo-logcursor.securityContext.fsGroup`             | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.geo-logcursor.securityContext.runAsUser`           | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.gitaly.authToken.key`                              | `token`                                                         | Key to Gitaly token in the secret |
| `gitlab.gitaly.authToken.secret`                           | `{.Release.Name}-gitaly-secret`                                 | Gitaly secret name |
| `gitlab.gitaly.image.pullPolicy`                           |                                                                 | Gitaly image pull policy |
| `gitlab.gitaly.image.repository`                           | `registry.gitlab.com/gitlab-org/build/cng/gitaly`               | Gitaly image repository |
| `gitlab.gitaly.image.tag`                                  | `master`                                                        | Gitaly image tag |
| `gitlab.gitaly.persistence.accessMode`                     | `ReadWriteOnce`                                                 | Gitaly persistence access mode |
| `gitlab.gitaly.persistence.enabled`                        | `true`                                                          | Gitaly enable persistence flag |
| `gitlab.gitaly.persistence.matchExpressions`               |                                                                 | Label-expression matches to bind |
| `gitlab.gitaly.persistence.matchLabels`                    |                                                                 | Label-value matches to bind |
| `gitlab.gitaly.persistence.size`                           | `50Gi`                                                          | Gitaly persistence volume size |
| `gitlab.gitaly.persistence.storageClass`                   |                                                                 | storageClassName for provisioning |
| `gitlab.gitaly.persistence.subPath`                        |                                                                 | Gitaly persistence volume mount path |
| `gitlab.gitaly.persistence.volumeName`                     |                                                                 | Existing persistent volume name |
| `gitlab.gitaly.securityContext.fsGroup`                    | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.gitaly.securityContext.runAsUser`                  | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.gitaly.service.annotations`                        | `{}`                                                            | Annotations to add to the `Service` |
| `gitlab.gitaly.service.externalPort`                       | `8075`                                                          | Gitaly service exposed port |
| `gitlab.gitaly.service.internalPort`                       | `8075`                                                          | Gitaly internal port |
| `gitlab.gitaly.service.name`                               | `gitaly`                                                        | Gitaly service name |
| `gitlab.gitaly.service.type`                               | `ClusterIP`                                                     | Gitaly service type |
| `gitlab.gitaly.serviceName`                                | `gitaly`                                                        | Gitaly service name |
| `gitlab.gitaly.shell.authToken.key`                        | `secret`                                                        | Shell key   |
| `gitlab.gitaly.shell.authToken.secret`                     | `{Release.Name}-gitlab-shell-secret`                            | Shell secret |
| `gitlab.gitlab-exporter.securityContext.fsGroup`           | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.gitlab-exporter.securityContext.runAsUser`         | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.gitlab-shell.authToken.key`                        | `secret`                                                        | Shell auth secret key |
| `gitlab.gitlab-shell.authToken.secret`                     | `{Release.Name}-gitlab-shell-secret`                            | Shell auth secret |
| `gitlab.gitlab-shell.enabled`                              | `true`                                                          | Shell enable flag |
| `gitlab.gitlab-shell.image.pullPolicy`                     |                                                                 | Shell image pull policy |
| `gitlab.gitlab-shell.image.repository`                     | `registry.gitlab.com/gitlab-org/build/cng/gitlab-shell`         | Shell image repository |
| `gitlab.gitlab-shell.image.tag`                            | `master`                                                        | Shell image tag |
| `gitlab.gitlab-shell.replicaCount`                         | `1`                                                             | Shell replicas |
| `gitlab.gitlab-shell.securityContext.fsGroup`              | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.gitlab-shell.securityContext.runAsUser`            | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.gitlab-shell.service.annotations`                  | `{}`                                                            | Annotations to add to the `Service` |
| `gitlab.gitlab-shell.service.internalPort`                 | `2222`                                                          | Shell internal port |
| `gitlab.gitlab-shell.service.name`                         | `gitlab-shell`                                                  | Shell service name |
| `gitlab.gitlab-shell.service.type`                         | `ClusterIP`                                                     | Shell service type |
| `gitlab.gitlab-shell.webservice.serviceName`               | inherited from `global.webservice.serviceName`                  | Webservice service name |
| `gitlab.mailroom.securityContext.fsGroup`                  | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.mailroom.securityContext.runAsUser`                | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.migrations.bootsnap.enabled`                       | `true`                                                          | Migrations Bootsnap enable flag |
| `gitlab.migrations.enabled`                                | `true`                                                          | Migrations enable flag |
| `gitlab.migrations.image.pullPolicy`                       |                                                                 | Migrations pull policy |
| `gitlab.migrations.image.repository`                       | `registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee`    | Migrations image repository |
| `gitlab.migrations.image.tag`                              | `master`                                                        | Migrations image tag |
| `gitlab.migrations.psql.password.key`                      | `psql-password`                                                 | key to psql password in psql secret |
| `gitlab.migrations.psql.password.secret`                   | `gitlab-postgres`                                               | psql secret |
| `gitlab.migrations.psql.port`                              |                                                                 | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `gitlab.migrations.securityContext.fsGroup`                | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.migrations.securityContext.runAsUser`              | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.sidekiq.concurrency`                               | `20`                                                            | Sidekiq default concurrency |
| `gitlab.sidekiq.enabled`                                   | `true`                                                          | Sidekiq enabled flag |
| `gitlab.sidekiq.gitaly.authToken.key`                      | `token`                                                         | key to Gitaly token in Gitaly secret |
| `gitlab.sidekiq.gitaly.authToken.secret`                   | `{.Release.Name}-gitaly-secret`                                 | Gitaly secret |
| `gitlab.sidekiq.gitaly.serviceName`                        | `gitaly`                                                        | Gitaly service name |
| `gitlab.sidekiq.image.pullPolicy`                          |                                                                 | Sidekiq image pull policy |
| `gitlab.sidekiq.image.repository`                          | `registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ee`    | Sidekiq image repository |
| `gitlab.sidekiq.image.tag`                                 | `master`                                                        | Sidekiq image tag |
| `gitlab.sidekiq.psql.password.key`                         | `psql-password`                                                 | key to psql password in psql secret |
| `gitlab.sidekiq.psql.password.secret`                      | `gitlab-postgres`                                               | psql password secret |
| `gitlab.sidekiq.psql.port`                                 |                                                                 | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `gitlab.sidekiq.replicas`                                  | `1`                                                             | Sidekiq replicas |
| `gitlab.sidekiq.resources.requests.cpu`                    | `100m`                                                          | Sidekiq minimum needed CPU |
| `gitlab.sidekiq.resources.requests.memory`                 | `600M`                                                          | Sidekiq minimum needed memory |
| `gitlab.sidekiq.securityContext.fsGroup`                   | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.sidekiq.securityContext.runAsUser`                 | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.sidekiq.timeout`                                   | `5`                                                             | Sidekiq job timeout |
| `gitlab.toolbox.annotations`                               | `{}`                                                            | Annotations to add to the toolbox |
| `gitlab.toolbox.backups.cron.enabled`                      | `false`                                                         | Backup CronJob enabled flag |
| `gitlab.toolbox.backups.cron.extraArgs`                    |                                                                 | String of arguments to pass to the backup utility |
| `gitlab.toolbox.backups.cron.persistence.accessMode`       | `ReadWriteOnce`                                                 | Backup cron persistence access mode |
| `gitlab.toolbox.backups.cron.persistence.enabled`          | `false`                                                         | Backup cron enable persistence flag |
| `gitlab.toolbox.backups.cron.persistence.matchExpressions` |                                                                 | Label-expression matches to bind |
| `gitlab.toolbox.backups.cron.persistence.matchLabels`      |                                                                 | Label-value matches to bind |
| `gitlab.toolbox.backups.cron.persistence.size`             | `10Gi`                                                          | Backup cron persistence volume size |
| `gitlab.toolbox.backups.cron.persistence.storageClass`     |                                                                 | storageClassName for provisioning |
| `gitlab.toolbox.backups.cron.persistence.subPath`          |                                                                 | Backup cron persistence volume mount path |
| `gitlab.toolbox.backups.cron.persistence.volumeName`       |                                                                 | Existing persistent volume name |
| `gitlab.toolbox.backups.cron.resources.requests.cpu`       | `50m`                                                           | Backup cron minimum needed CPU |
| `gitlab.toolbox.backups.cron.resources.requests.memory`    | `350M`                                                          | Backup cron minimum needed memory |
| `gitlab.toolbox.backups.cron.schedule`                     | `0 1 * * *`                                                     | Cron style schedule string |
| `gitlab.toolbox.backups.objectStorage.backend`             | `s3`                                                            | Object storage provider to use (`s3`, `gcs`, or `azure`) |
| `gitlab.toolbox.backups.objectStorage.config.gcpProject`   | `""`                                                            | GCP Project to use when backend is `gcs` |
| `gitlab.toolbox.backups.objectStorage.config.key`          | `""`                                                            | key containing credentials in secret |
| `gitlab.toolbox.backups.objectStorage.config.secret`       | `""`                                                            | Object storage credentials secret |
| `gitlab.toolbox.backups.objectStorage.config`              | `{}`                                                            | Authentication information for object storage |
| `gitlab.toolbox.bootsnap.enabled`                          | `true`                                                          | Enable Bootsnap cache in Toolbox |
| `gitlab.toolbox.enabled`                                   | `true`                                                          | Toolbox enabled flag |
| `gitlab.toolbox.image.pullPolicy`                          | `IfNotPresent`                                                  | Toolbox image pull policy |
| `gitlab.toolbox.image.repository`                          | `registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee`    | Toolbox image repository |
| `gitlab.toolbox.image.tag`                                 | `master`                                                        | Toolbox image tag |
| `gitlab.toolbox.init.image.repository`                     |                                                                 | Toolbox init image repository |
| `gitlab.toolbox.init.image.tag`                            |                                                                 | Toolbox init image tag |
| `gitlab.toolbox.init.resources.requests.cpu`               | `50m`                                                           | Toolbox init minimum needed CPU |
| `gitlab.toolbox.persistence.accessMode`                    | `ReadWriteOnce`                                                 | Toolbox persistence access mode |
| `gitlab.toolbox.persistence.enabled`                       | `false`                                                         | Toolbox enable persistence flag |
| `gitlab.toolbox.persistence.matchExpressions`              |                                                                 | Label-expression matches to bind |
| `gitlab.toolbox.persistence.matchLabels`                   |                                                                 | Label-value matches to bind |
| `gitlab.toolbox.persistence.size`                          | `10Gi`                                                          | Toolbox persistence volume size |
| `gitlab.toolbox.persistence.storageClass`                  |                                                                 | storageClassName for provisioning |
| `gitlab.toolbox.persistence.subPath`                       |                                                                 | Toolbox persistence volume mount path |
| `gitlab.toolbox.persistence.volumeName`                    |                                                                 | Existing persistent volume name |
| `gitlab.toolbox.psql.port`                                 |                                                                 | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `gitlab.toolbox.resources.requests.cpu`                    | `50m`                                                           | Toolbox minimum needed CPU |
| `gitlab.toolbox.resources.requests.memory`                 | `350M`                                                          | Toolbox minimum needed memory |
| `gitlab.toolbox.securityContext.fsGroup`                   | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.toolbox.securityContext.runAsUser`                 | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.webservice.enabled`                                | `true`                                                          | webservice enabled flag |
| `gitlab.webservice.gitaly.authToken.key`                   | `token`                                                         | Key to Gitaly token in Gitaly secret |
| `gitlab.webservice.gitaly.authToken.secret`                | `{.Release.Name}-gitaly-secret`                                 | Gitaly secret name |
| `gitlab.webservice.gitaly.serviceName`                     | `gitaly`                                                        | Gitaly service name |
| `gitlab.webservice.image.pullPolicy`                       |                                                                 | webservice image pull policy |
| `gitlab.webservice.image.repository`                       | `registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ee` | webservice image repository |
| `gitlab.webservice.image.tag`                              | `master`                                                        | webservice image tag |
| `gitlab.webservice.psql.password.key`                      | `psql-password`                                                 | Key to psql password in psql secret |
| `gitlab.webservice.psql.password.secret`                   | `gitlab-postgres`                                               | psql secret name |
| `gitlab.webservice.psql.port`                              |                                                                 | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `global.registry.enabled`                                  | `true`                                                          | Enable registry. Mirrors `registry.enabled` |
| `global.registry.api.port`                                 | `5000`                                                          | Registry port |
| `global.registry.api.protocol`                             | `http`                                                          | Registry protocol |
| `global.registry.api.serviceName`                          | `registry`                                                      | Registry service name |
| `global.registry.tokenIssuer`                              | `gitlab-issuer`                                                 | Registry token issuer |
| `gitlab.webservice.replicaCount`                           | `1`                                                             | webservice number of replicas |
| `gitlab.webservice.resources.requests.cpu`                 | `200m`                                                          | webservice minimum CPU |
| `gitlab.webservice.resources.requests.memory`              | `1.4G`                                                          | webservice minimum memory |
| `gitlab.webservice.securityContext.fsGroup`                | `1000`                                                          | Group ID under which the pod should be started |
| `gitlab.webservice.securityContext.runAsUser`              | `1000`                                                          | User ID under which the pod should be started |
| `gitlab.webservice.service.annotations`                    | `{}`                                                            | Annotations to add to the `Service` |
| `gitlab.webservice.http.enabled`                           | `true`                                                          | webservice HTTP enabled |
| `gitlab.webservice.service.externalPort`                   | `8080`                                                          | webservice exposed port |
| `gitlab.webservice.service.internalPort`                   | `8080`                                                          | webservice internal port |
| `gitlab.webservice.tls.enabled`                            | `false`                                                         | webservice TLS enabled |
| `gitlab.webservice.tls.secretName`                         | `{Release.Name}-webservice-tls`                                 | webservice secret name of TLS key |
| `gitlab.webservice.service.tls.externalPort`               | `8081`                                                          | webservice TLS exposed port |
| `gitlab.webservice.service.tls.internalPort`               | `8081`                                                          | webservice TLS internal port |
| `gitlab.webservice.service.type`                           | `ClusterIP`                                                     | webservice service type |
| `gitlab.webservice.service.workhorseExternalPort`          | `8181`                                                          | Workhorse exposed port |
| `gitlab.webservice.service.workhorseInternalPort`          | `8181`                                                          | Workhorse internal port |
| `gitlab.webservice.shell.authToken.key`                    | `secret`                                                        | Key to shell token in shell secret |
| `gitlab.webservice.shell.authToken.secret`                 | `{Release.Name}-gitlab-shell-secret`                            | Shell token secret |
| `gitlab.webservice.workerProcesses`                        | `2`                                                             | webservice number of workers |
| `gitlab.webservice.workerTimeout`                          | `60`                                                            | webservice worker timeout |
| `gitlab.webservice.workhorse.extraArgs`                    | `""`                                                            | String of extra parameters for workhorse |
| `gitlab.webservice.workhorse.image`                        | `registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ee`  | Workhorse image repository |
| `gitlab.webservice.workhorse.sentryDSN`                    | `""`                                                            | DSN for Sentry instance for error reporting |
| `gitlab.webservice.workhorse.tag`                          |                                                                 | Workhorse image tag |

## External charts

GitLab makes use of several other charts. These are [treated as parent-child relationships](https://helm.sh/docs/topics/charts/#chart-dependencies).
Ensure that any properties you wish to configure are provided as `chart-name.property`.

### Prometheus

Prefix Prometheus values with `prometheus`. For example, set the persistence
storage value using `prometheus.server.persistentVolume.size`. To disable Prometheus set `prometheus.install=false`.

Refer to the [Prometheus chart documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus)
for the exhaustive list of configuration options.

### PostgreSQL

Prefix PostgreSQL values with `postgresql`. For example, set the storage class of the
primary by using `postgresql.primary.persistence.storageClass`.

Refer to the [Bitnami PostgreSQL chart documentation](https://artifacthub.io/packages/helm/bitnami/postgresql)
for the exhaustive list of configuration options.

## Bringing your own images

In certain scenarios (i.e. offline environment), you may want to bring your own images rather than pulling them down from the Internet. This requires specifying your own Docker image registry/repository for each of the charts that make up the GitLab release.

Refer to the [custom images documentation](../advanced/custom-images/_index.md) for more information.
