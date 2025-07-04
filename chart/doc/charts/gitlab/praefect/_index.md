---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Using the Praefect chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed
- Status: Experiment

{{< /details >}}

{{< alert type="warning" >}}

The Praefect chart is still under development. This experimental version is not yet suitable for production use. Upgrades may require significant manual intervention.
See our [Praefect GA release Epic](https://gitlab.com/groups/gitlab-org/charts/-/epics/33) for more information.

{{< /alert >}}

The Praefect chart is used to manage a [Gitaly cluster](https://docs.gitlab.com/administration/gitaly/praefect/) inside a GitLab installment deployed with the Helm charts.

## Known limitations and issues

1. The database has to be [manually created](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2310).
1. The cluster size is fixed: [Gitaly Cluster does not currently support autoscaling](https://gitlab.com/gitlab-org/gitaly/-/issues/2997).
1. Using a Praefect instance in the cluster to manage Gitaly instances outside the cluster is [not supported](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2662).

## Requirements

This chart consumes the Gitaly chart. Settings from `global.gitaly` are used to configure the instances created by this chart. Documentation of these settings can be found in [Gitaly chart documentation](../gitaly/_index.md).

_Important_: `global.gitaly.tls` is independent of `global.praefect.tls`. They are configured separately.

By default, this chart will create 3 Gitaly Replicas.

## Configuration

The chart is disabled by default. To enable it as part of a chart deploy set `global.praefect.enabled=true`.

### Replicas

The default number of replicas to deploy is 3. This can be changed by setting `global.praefect.virtualStorages[].gitalyReplicas` with the desired number of replicas. For example:

```yaml
global:
  praefect:
    enabled: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
```

### Multiple virtual storages

Multiple virtual storages can be configured (see [Gitaly Cluster](https://docs.gitlab.com/administration/gitaly/praefect/) documentation). For example:

```yaml
global:
  praefect:
    enabled: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
    - name: vs2
      gitalyReplicas: 5
      maxUnavailable: 2
```

This will create two sets of resources for Gitaly. This includes two Gitaly StatefulSets (one per virtual storage).

Administrators can then [configure where new repositories are stored](https://docs.gitlab.com/administration/repository_storage_paths/#configure-where-new-repositories-are-stored).

### Persistence

It is possible to provide persistence configuration per virtual storage.

```yaml
global:
  praefect:
    enabled: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
      persistence:
        enabled: true
        size: 50Gi
        accessMode: ReadWriteOnce
        storageClass: storageclass1
    - name: vs2
      gitalyReplicas: 5
      maxUnavailable: 2
      persistence:
        enabled: true
        size: 100Gi
        accessMode: ReadWriteOnce
        storageClass: storageclass2
```

## defaultReplicationFactor

`defaultReplicationFactor` can be configured on each virtual storages. (see [configure replication-factor](https://docs.gitlab.com/administration/gitaly/praefect/#configure-replication-factor) documentation).

```yaml
global:
  praefect:
    enabled: true
    virtualStorages:
    - name: default
      gitalyReplicas: 5
      maxUnavailable: 2
      defaultReplicationFactor: 3
    - name: secondary
      gitalyReplicas: 4
      maxUnavailable: 1
      defaultReplicationFactor: 2
```

### Migrating to Praefect

{{< alert type="note" >}}

Group wikis [cannot be moved by using the API](https://docs.gitlab.com/api/project_repository_storage_moves/).

{{< /alert >}}

When migrating from standalone Gitaly instances to a Praefect setup, `global.praefect.replaceInternalGitaly` can be set to `false`.
This ensures that the existing Gitaly instances are preserved while the new Praefect-managed Gitaly instances are created.

```yaml
global:
  praefect:
    enabled: true
    replaceInternalGitaly: false
    virtualStorages:
    - name: virtualStorage2
      gitalyReplicas: 5
      maxUnavailable: 2
```

{{< alert type="note" >}}

When migrating to Praefect, none of Praefect's virtual storages can be named `default`.
This is because there must be at least one storage named `default` at all times,
therefore the name is already taken by the non-Praefect configuration.

{{< /alert >}}

The instructions to [migrate to Gitaly Cluster](https://docs.gitlab.com/administration/gitaly/#migrating-to-gitaly-cluster)
can then be followed to move data from the `default` storage to `virtualStorage2`. If additional storages
were defined under `global.gitaly.internal.names`, be sure to migrate repositories from those storages as well.

After the repositories have been migrated to `virtualStorage2`, `replaceInternalGitaly` can be set back to `true` if a storage named
`default` is added in the Praefect configuration.

```yaml
global:
  praefect:
    enabled: true
    replaceInternalGitaly: true
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
    - name: virtualStorage2
      gitalyReplicas: 5
      maxUnavailable: 2
```

The instructions to [migrate to Gitaly Cluster](https://docs.gitlab.com/administration/gitaly/#migrating-to-gitaly-cluster)
can be followed again to move data from `virtualStorage2` to the newly-added `default` storage if desired.

Finally, see the [repository storage paths documentation](https://docs.gitlab.com/administration/repository_storage_paths/#choose-where-new-repositories-are-stored)
to configure where new repositories are stored.

### Creating the database

Praefect uses its own database to track its state. This has to be manually created in order for Praefect to be functional.

{{< alert type="note" >}}

These instructions assume you are using the bundled PostgreSQL server. If you are using your own server,
there will be some variation in how you connect.

{{< /alert >}}

1. Log into your database instance:

   ```shell
   kubectl exec -it $(kubectl get pods -l app.kubernetes.io/name=postgresql -o custom-columns=NAME:.metadata.name --no-headers) -- bash
   ```

   ```shell
   PGPASSWORD=$(echo $POSTGRES_POSTGRES_PASSWORD) psql -U postgres -d template1
   ```

1. Create the database user:

   ```sql
   CREATE ROLE praefect WITH LOGIN;
   ```

1. Set the database user password.

   By default, the `shared-secrets` Job will generate a secret for you.

   1. Fetch the password:

      ```shell
      kubectl get secret RELEASE_NAME-praefect-dbsecret -o jsonpath="{.data.secret}" | base64 --decode
      ```

   1. Set the password in the `psql` prompt:

      ```sql
      \password praefect
      ```

1. Create the database:

   ```sql
   CREATE DATABASE praefect WITH OWNER praefect;
   ```

### Running Praefect over TLS

Praefect supports communicating with client and Gitaly nodes over TLS. This is
controlled by the settings `global.praefect.tls.enabled` and `global.praefect.tls.secretName`.
To run Praefect over TLS follow these steps:

1. The Helm chart expects a certificate to be provided for communicating over
   TLS with Praefect. This certificate should apply to all the Praefect nodes that
   are present. Hence all hostnames of each of these nodes should be added as a
   Subject Alternate Name (SAN) to the certificate or alternatively, you can use wildcards.

   To know the hostnames to use, check the file `/srv/gitlab/config/gitlab.yml`
   file in the Toolbox Pod and check the various `gitaly_address` fields specified
   under `repositories.storages` key within it.

   ```shell
   kubectl exec -it <Toolbox Pod> -- grep gitaly_address /srv/gitlab/config/gitlab.yml
   ```

{{< alert type="note" >}}

A basic script for generating custom signed certificates for internal Praefect Pods
[can be found in this repository](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/generate_certificates.sh).
Users can use or refer that script to generate certificates with proper SAN attributes.

{{< /alert >}}

1. Create a TLS Secret using the certificate created.

   ```shell
   kubectl create secret tls <secret name> --cert=praefect.crt --key=praefect.key
   ```

1. Redeploy the Helm chart by passing `--set global.praefect.tls.enabled=true`.

When running Gitaly over TLS, a secret name must be provided for each virtual storage.

```yaml
global:
  gitaly:
    tls:
      enabled: true
  praefect:
    enabled: true
    tls:
      enabled: true
      secretName: praefect-tls
    virtualStorages:
    - name: default
      gitalyReplicas: 4
      maxUnavailable: 1
      tlsSecretName: default-tls
    - name: vs2
      gitalyReplicas: 5
      maxUnavailable: 2
      tlsSecretName: vs2-tls
```

### Installation command line options

The table below contains all the possible charts configurations that can be supplied to
the `helm install` command using the `--set` flags.

| Parameter                                                | Default                                           | Description |
|----------------------------------------------------------|---------------------------------------------------|-------------|
| common.labels                                            | `{}`                                              | Supplemental labels that are applied to all objects created by this chart. |
| failover.enabled                                         | true                                              | Whether Praefect should perform failover on node failure |
| failover.readonlyAfter                                   | false                                             | Whether the nodes should be in read-only mode after failover |
| autoMigrate                                              | true                                              | Automatically run migrations on startup |
| image.repository                                         | `registry.gitlab.com/gitlab-org/build/cng/gitaly` | The default image repository to use. Praefect is bundled as part of the Gitaly image |
| podLabels                                                | `{}`                                              | Supplemental Pod labels. Will not be used for selectors. |
| ntpHost                                                  | `pool.ntp.org`                                    | Configure the NTP server Praefect should ask the for the current time. |
| service.name                                             | `praefect`                                        | The name of the service to create |
| service.type                                             | ClusterIP                                         | The type of service to create |
| service.internalPort                                     | 8075                                              | The internal port number that the Praefect pod will be listening on |
| service.externalPort                                     | 8075                                              | The port number the Praefect service should expose in the cluster |
| init.resources                                           |                                                   |             |
| init.image                                               |                                                   |             |
| `init.containerSecurityContext.allowPrivilegeEscalation` | `false`                                           | initContainer specific: Controls whether a process can gain more privileges than its parent process |
| `init.containerSecurityContext.runAsNonRoot`             | `true`                                            | initContainer specific: Controls whether the container runs with a non-root user |
| `init.containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                                       | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container |
| extraEnvFrom                                             |                                                   | List of extra environment variables from other data sources to expose |
| logging.level                                            |                                                   | Log level   |
| logging.format                                           | `json`                                            | Log format  |
| logging.sentryDsn                                        |                                                   | Sentry DSN URL - Exceptions from Go server |
| logging.sentryEnvironment                                |                                                   | Sentry environment to be used for logging |
| `metrics.enabled`                                        | `true`                                            | If a metrics endpoint should be made available for scraping |
| `metrics.port`                                           | `9236`                                            | Metrics endpoint port |
| `metrics.separate_database_metrics`                      | `true`                                            | If true then metrics scrapes will not perform database queries, setting to false [may cause performance problems](https://gitlab.com/gitlab-org/gitaly/-/issues/3796) |
| `metrics.path`                                           | `/metrics`                                        | Metrics endpoint path |
| `metrics.serviceMonitor.enabled`                         | `false`                                           | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping, note that enabling this removes the `prometheus.io` scrape annotations |
| `affinity`                                               | `{}`                                              | [Affinity rules](../_index.md#affinity) for pod assignment |
| `metrics.serviceMonitor.additionalLabels`                | `{}`                                              | Additional labels to add to the ServiceMonitor |
| `metrics.serviceMonitor.endpointConfig`                  | `{}`                                              | Additional endpoint configuration for the ServiceMonitor |
| securityContext.runAsUser                                | 1000                                              |             |
| securityContext.fsGroup                                  | 1000                                              |             |
| securityContext.fsGroupChangePolicy                      |                                                   | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23) |
| `securityContext.seccompProfile.type`                    | `RuntimeDefault`                                  | Seccomp profile to use |
| `containerSecurityContext.allowPrivilegeEscalation`      | `false`                                           | Controls whether a process of the container can gain more privileges than its parent process |
| `containerSecurityContext.runAsNonRoot`                  | `true`                                            | Controls whether the container runs with a non-root user |
| `containerSecurityContext.capabilities.drop`             | `[ "ALL" ]`                                       | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container |
| `serviceAccount.annotations`                             | `{}`                                              | ServiceAccount annotations |
| `serviceAccount.automountServiceAccountToken`            | `false`                                           | Indicates whether or not the default ServiceAccount access token should be mounted in pods |
| `serviceAccount.create`                                  | `false`                                           | Indicates whether or not a ServiceAccount should be created |
| `serviceAccount.enabled`                                 | `false`                                           | Indicates whether or not to use a ServiceAccount |
| `serviceAccount.name`                                    |                                                   | Name of the ServiceAccount. If not set, the full chart name is used |
| serviceLabels                                            | `{}`                                              | Supplemental service labels |
| statefulset.strategy                                     | `{}`                                              | Allows one to configure the update strategy utilized by the statefulset |

### serviceAccount

This section controls if a ServiceAccount should be created and if the default access token should be mounted in pods.

| Name                           |  Type   | Default | Description |
|:-------------------------------|:-------:|:--------|:------------|
| `annotations`                  |   Map   | `{}`    | ServiceAccount annotations. |
| `automountServiceAccountToken` | Boolean | `false` | Controls if the default ServiceAccount access token should be mounted in pods. You should not enable this unless it is required by certain sidecars to work properly (for example, Istio). |
| `create`                       | Boolean | `false` | Indicates whether or not a ServiceAccount should be created. |
| `enabled`                      | Boolean | `false` | Indicates whether or not to use a ServiceAccount. |
| `name`                         | String  |         | Name of the ServiceAccount. If not set, the full chart name is used. |

### affinity

For more information, see [`affinity`](../_index.md#affinity).
