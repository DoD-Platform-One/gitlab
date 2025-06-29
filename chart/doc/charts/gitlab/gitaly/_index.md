---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Using the GitLab-Gitaly chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

The `gitaly` sub-chart provides a configurable deployment of Gitaly Servers.

## Requirements

This chart depends on access to the Workhorse service, either as part of the
complete GitLab chart or provided as an external service reachable from the Kubernetes
cluster this chart is deployed onto.

## Design Choices

The Gitaly container used in this chart also contains the GitLab Shell codebase in
order to perform the actions on the Git repositories that have not yet been ported into Gitaly.
The Gitaly container includes a copy of the GitLab Shell container within it, and
as a result we also need to configure GitLab Shell within this chart.

## Configuration

The `gitaly` chart is configured in two parts: [external services](#external-services),
and [chart settings](#chart-settings).

Gitaly is by default deployed as a component when deploying the GitLab
chart. If deploying Gitaly separately, `global.gitaly.enabled` needs to
be set to `false` and additional configuration will need to be performed
as described in the [external Gitaly documentation](../../../advanced/external-gitaly/_index.md).

### Installation command line options

The table below contains all the possible charts configurations that can be supplied to
the `helm install` command using the `--set` flags.

| Parameter                                                | Default                                                 | Description |
|----------------------------------------------------------|---------------------------------------------------------|-------------|
| `annotations`                                            |                                                         | Pod annotations |
| `backup.goCloudUrl`                                      |                                                         | Object storage URL for [server side Gitaly backups](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#configure-server-side-backups). |
| `common.labels`                                          | `{}`                                                    | Supplemental labels that are applied to all objects created by this chart. |
| `podLabels`                                              |                                                         | Supplemental Pod labels. Will not be used for selectors. |
| `external[].hostname`                                    | `- ""`                                                  | hostname of external node |
| `external[].name`                                        | `- ""`                                                  | name of external node storage |
| `external[].port`                                        | `- ""`                                                  | port of external node |
| `extraContainers`                                        |                                                         | Multiline literal style string containing a list of containers to include |
| `extraInitContainers`                                    |                                                         | List of extra init containers to include |
| `extraVolumeMounts`                                      |                                                         | List of extra volumes mounts to do |
| `extraVolumes`                                           |                                                         | List of extra volumes to create |
| `extraEnv`                                               |                                                         | List of extra environment variables to expose |
| `extraEnvFrom`                                           |                                                         | List of extra environment variables from other data sources to expose |
| `gitaly.serviceName`                                     |                                                         | The name of the generated Gitaly service. Overrides `global.gitaly.serviceName`, and defaults to `<RELEASE-NAME>-gitaly` |
| `gpgSigning.enabled`                                     | `false`                                                 | If [Gitaly GPG signing](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#configure-commit-signing-for-gitlab-ui-commits) should be used. |
| `gpgSigning.secret`                                      |                                                         | The name of the secret used for Gitaly GPG signing. |
| `gpgSigning.key`                                         |                                                         | The key in the GPG secret containing Gitaly's GPG signing key. |
| `image.pullPolicy`                                       | `Always`                                                | Gitaly image pull policy |
| `image.pullSecrets`                                      |                                                         | Secrets for the image repository |
| `image.repository`                                       | `registry.gitlab.com/gitlab-org/build/cng/gitaly`       | Gitaly image repository |
| `image.tag`                                              | `master`                                                | Gitaly image tag |
| `init.image.repository`                                  |                                                         | initContainer image |
| `init.image.tag`                                         |                                                         | initContainer image tag |
| `init.containerSecurityContext`                          |                                                         | initContainer specific [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) |
| `init.containerSecurityContext.allowPrivilegeEscalation` | `false`                                                 | initContainer specific: Controls whether a process can gain more privileges than its parent process |
| `init.containerSecurityContext.runAsNonRoot`             | `true`                                                  | initContainer specific: Controls whether the container runs with a non-root user |
| `init.containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                                             | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container |
| `internal.names[]`                                       | `- default`                                             | Ordered names of StatefulSet storages |
| `serviceLabels`                                          | `{}`                                                    | Supplemental service labels |
| `service.externalPort`                                   | `8075`                                                  | Gitaly service exposed port |
| `service.internalPort`                                   | `8075`                                                  | Gitaly internal port |
| `service.name`                                           | `gitaly`                                                | The name of the Service port that Gitaly is behind in the Service object. |
| `service.type`                                           | `ClusterIP`                                             | Gitaly service type |
| `service.clusterIP`                                      | `None`                                                  | You can specify your own cluster IP address as part of a Service creation request. This follows the same conventions as the Kubernetes' Service object's clusterIP. This must not be set if `service.type` is LoadBalancer. |
| `service.loadBalancerIP`                                 |                                                         | An ephemeral IP address will be created if not set. This follows the same conventions as the Kubernetes' Service object's loadbalancerIP configuration. |
| `serviceAccount.annotations`                             | `{}`                                                    | ServiceAccount annotations |
| `serviceAccount.automountServiceAccountToken`            | `false`                                                 | Indicates whether or not the default ServiceAccount access token should be mounted in pods |
| `serviceAccount.create`                                  | `false`                                                 | Indicates whether or not a ServiceAccount should be created |
| `serviceAccount.enabled`                                 | `false`                                                 | Indicates whether or not to use a ServiceAccount |
| `serviceAccount.name`                                    |                                                         | Name of the ServiceAccount. If not set, the full chart name is used |
| `securityContext.fsGroup`                                | `1000`                                                  | Group ID under which the pod should be started |
| `securityContext.fsGroupChangePolicy`                    |                                                         | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23) |
| `securityContext.runAsUser`                              | `1000`                                                  | User ID under which the pod should be started |
| `securityContext.seccompProfile.type`                    | `RuntimeDefault`                                        | Seccomp profile to use |
| `shareProcessNamespace`                                  | `false`                                                 | Allows making container processes visible to all other contains in the same pod |
| `containerSecurityContext`                               |                                                         | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the Gitaly container is started |
| `containerSecurityContext.runAsUser`                     | `1000`                                                  | Allow overwriting of the specific security context user ID under which the Gitaly container is started |
| `containerSecurityContext.allowPrivilegeEscalation`      | `false`                                                 | Controls whether a process of the Gitaly container can gain more privileges than its parent process |
| `containerSecurityContext.runAsNonRoot`                  | `true`                                                  | Controls whether the Gitaly container runs with a non-root user |
| `containerSecurityContext.capabilities.drop`             | `[ "ALL" ]`                                             | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container |
| `tolerations`                                            | `[]`                                                    | Toleration labels for pod assignment |
| `affinity`                                               | `{}`                                                    | [Affinity rules](../_index.md#affinity) for pod assignment |
| `persistence.accessMode`                                 | `ReadWriteOnce`                                         | Gitaly persistence access mode |
| `persistence.annotations`                                |                                                         | Gitaly persistence annotations |
| `persistence.enabled`                                    | `true`                                                  | Gitaly enable persistence flag |
| `persistance.labels`                                     |                                                         | Gitaly persistence labels |
| `persistence.matchExpressions`                           |                                                         | Label-expression matches to bind |
| `persistence.matchLabels`                                |                                                         | Label-value matches to bind |
| `persistence.size`                                       | `50Gi`                                                  | Gitaly persistence volume size |
| `persistence.storageClass`                               |                                                         | storageClassName for provisioning |
| `persistence.subPath`                                    |                                                         | Gitaly persistence volume mount path |
| `priorityClassName`                                      |                                                         | Gitaly StatefulSet priorityClassName |
| `logging.level`                                          |                                                         | Log level   |
| `logging.format`                                         | `json`                                                  | Log format  |
| `logging.sentryDsn`                                      |                                                         | Sentry DSN URL - Exceptions from Go server |
| `logging.sentryEnvironment`                              |                                                         | Sentry environment to be used for logging |
| `shell.concurrency[]`                                    |                                                         | Concurrency of each RPC endpoint. See [Limit RPC concurrency](https://docs.gitlab.com/administration/gitaly/concurrency_limiting/#limit-rpc-concurrency) and [Enable adaptiveness for RPC concurrency](https://docs.gitlab.com/administration/gitaly/concurrency_limiting/#enable-adaptiveness-for-rpc-concurrency) for the configuration keys. |
| `packObjectsCache.enabled`                               | `false`                                                 | Enable the Gitaly pack-objects cache |
| `packObjectsCache.dir`                                   | `/home/git/repositories/+gitaly/PackObjectsCache`       | Directory where cache files get stored |
| `packObjectsCache.max_age`                               | `5m`                                                    | Cache entries lifespan |
| `packObjectsCache.min_occurrences`                       | `1`                                                     | Minimum count requiredto create a cache entry |
| `git.catFileCacheSize`                                   |                                                         | Cache size used by Git cat-file process |
| `git.config[]`                                           | `[]`                                                    | Git configuration that Gitaly should set when spawning Git commands |
| `prometheus.grpcLatencyBuckets`                          |                                                         | Buckets corresponding to histogram latencies on GRPC method calls to be recorded by Gitaly. A string form of the array (for example, `"[1.0, 1.5, 2.0]"`) is required as input |
| `statefulset.strategy`                                   | `{}`                                                    | Allows one to configure the update strategy utilized by the StatefulSet |
| `statefulset.livenessProbe.initialDelaySeconds`          | `0`                                                     | Delay before liveness probe is initiated. If startupProbe is enabled, this will be set to 0. |
| `statefulset.livenessProbe.periodSeconds`                | `10`                                                    | How often to perform the liveness probe |
| `statefulset.livenessProbe.timeoutSeconds`               | `3`                                                     | When the liveness probe times out |
| `statefulset.livenessProbe.successThreshold`             | `1`                                                     | Minimum consecutive successes for the liveness probe to be considered successful after having failed |
| `statefulset.livenessProbe.failureThreshold`             | `3`                                                     | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded |
| `statefulset.readinessProbe.initialDelaySeconds`         | `0`                                                     | Delay before readiness probe is initiated. If startupProbe is enabled, this will be set to 0. |
| `statefulset.readinessProbe.periodSeconds`               | `5`                                                     | How often to perform the readiness probe |
| `statefulset.readinessProbe.timeoutSeconds`              | `3`                                                     | When the readiness probe times out |
| `statefulset.readinessProbe.successThreshold`            | `1`                                                     | Minimum consecutive successes for the readiness probe to be considered successful after having failed |
| `statefulset.readinessProbe.failureThreshold`            | `3`                                                     | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded |
| `statefulset.startupProbe.enabled`                       | `true`                                                  | Whether a startup probe is enabled. |
| `statefulset.startupProbe.initialDelaySeconds`           | `1`                                                     | Delay before startup probe is initiated |
| `statefulset.startupProbe.periodSeconds`                 | `1`                                                     | How often to perform the startup probe |
| `statefulset.startupProbe.timeoutSeconds`                | `1`                                                     | When the startup probe times out |
| `statefulset.startupProbe.successThreshold`              | `1`                                                     | Minimum consecutive successes for the startup probe to be considered successful after having failed |
| `statefulset.startupProbe.failureThreshold`              | `60`                                                    | Minimum consecutive failures for the startup probe to be considered failed after having succeeded |
| `metrics.enabled`                                        | `false`                                                 | If a metrics endpoint should be made available for scraping |
| `metrics.port`                                           | `9236`                                                  | Metrics endpoint port |
| `metrics.path`                                           | `/metrics`                                              | Metrics endpoint path |
| `metrics.serviceMonitor.enabled`                         | `false`                                                 | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping, note that enabling this removes the `prometheus.io` scrape annotations |
| `metrics.serviceMonitor.additionalLabels`                | `{}`                                                    | Additional labels to add to the ServiceMonitor |
| `metrics.serviceMonitor.endpointConfig`                  | `{}`                                                    | Additional endpoint configuration for the ServiceMonitor |
| `metrics.metricsPort`                                    |                                                         | **DEPRECATED** Use `metrics.port` |
| `gomemlimit.enabled`                                     | `true`                                                  | This will automatically set the `GOMEMLIMIT` environment variable for the Gitaly container to `resources.limits.memory`, if that limit is also set. Users can override this value by setting this value false and setting `GOMEMLIMIT` in `extraEnv`. This must meet [documented format criteria](https://pkg.go.dev/runtime#hdr-Environment_Variables). |
| `cgroups.enabled`                                        | `false`                                                 | Gitaly has built-in cgroups control. When configured, Gitaly assigns Git processes to a cgroup based on the repository the Git command is operating in. This parameter will enable repository cgroups. Note only cgroups v2 will be supported if enabled. |
| `cgroups.initContainer.image.repository`                 | `registry.com/gitlab-org/build/cng/gitaly-init-cgroups` | Gitaly image repository |
| `cgroups.initContainer.image.tag`                        | `master`                                                | Gitaly image tag |
| `cgroups.initContainer.image.pullPolicy`                 | `IfNotPresent`                                          | Gitaly image pull policy |
| `cgroups.mountpoint`                                     | `/etc/gitlab-secrets/gitaly-pod-cgroup`                 | Where the parent cgroup directory is mounted. |
| `cgroups.hierarchyRoot`                                  | `gitaly`                                                | Parent cgroup under which Gitaly creates groups, and is expected to be owned by the user and group Gitaly runs as. |
| `cgroups.memoryBytes`                                    |                                                         | The total memory limit that is imposed collectively on all Git processes that Gitaly spawns. 0 implies no limit. |
| `cgroups.cpuShares`                                      |                                                         | The CPU limit that is imposed collectively on all Git processes that Gitaly spawns. 0 implies no limit. The maximum is 1024 shares, which represents 100% of CPU. |
| `cgroups.cpuQuotaUs`                                     |                                                         | Used to throttle the cgroups' processes if they exceed this quota value. We set cpuQuotaUs to 100ms so 1 core is 100000. 0 implies no limit. |
| `cgroups.repositories.count`                             |                                                         | The number of cgroups in the cgroups pool. Each time a new Git command is spawned, Gitaly assigns it to one of these cgroups based on the repository the command is for. A circular hashing algorithm assigns Git commands to these cgroups, so a Git command for a repository is always assigned to the same cgroup. |
| `cgroups.repositories.memoryBytes`                       |                                                         | The total memory limit imposed on all Git processes contained in a repository cgroup. 0 implies no limit. This value cannot exceed that of the top level memoryBytes. |
| `cgroups.repositories.cpuShares`                         |                                                         | The CPU limit that is imposed on all Git processes contained in a repository cgroup. 0 implies no limit. The maximum is 1024 shares, which represents 100% of CPU. This value cannot exceed that of the top level cpuShares. |
| `cgroups.repositories.cpuQuotaUs`                        |                                                         | The cpuQuotaUs that is imposed on all Git processes contained in a repository cgroup. A Git process can't use more then the given quota. We set cpuQuotaUs to 100ms so 1 core is 100000. 0 implies no limit. |
| `cgroups.repositories.maxCgroupsPerRepo`                 | `1`                                                     | The number of repository cgroups that Git processes targeting a specific repository can be distributed across. This enables more conservative CPU and memory limits to be configured for repository cgroups while still allowing for bursty workloads. For instance, with a `maxCgroupsPerRepo` of `2` and a `memoryBytes` limit of 10GB, independent Git operations against a specific repository can consume up to 20GB of memory. |
| `gracefulRestartTimeout`                                 | `25`                                                    | Gitaly shutdown grace period, how long to wait for in-flight requests to complete (seconds). Pod `terminationGracePeriodSeconds` is set to this value + 5 seconds. |
| `timeout.uploadPackNegotiation`                          |                                                         | See [Configure the negotiation timeouts](https://docs.gitlab.com/administration/settings/gitaly_timeouts/#configure-the-negotiation-timeouts). |
| `timeout.uploadArchiveNegotiation`                       |                                                         | See [Configure the negotiation timeouts](https://docs.gitlab.com/administration/settings/gitaly_timeouts/#configure-the-negotiation-timeouts). |
| `dailyMaintenance.disabled`                              |                                                         | Allows to disable the daily background maintenance. |
| `dailyMaintenance.duration`                              |                                                         | Maximum duration of the daily background maintenance. For example "1h" or "45m". |
| `dailyMaintenance.startHour`                             |                                                         | Start minute of the daily background maintenance. |
| `dailyMaintenance.startMinute`                           |                                                         | Start minute of the daily background maintenance. |
| `dailyMaintenance.storages`                              |                                                         | Array of storage names to perform the daily background maintenance. For example [ "default" ]. |
| `bundleUri.goCloudUrl`                                   |                                                         | See the [Bundle URIs documentation](https://docs.gitlab.com/administration/gitaly/bundle_uris/). |

## Chart configuration examples

### extraEnv

`extraEnv` allows you to expose additional environment variables in all containers in the pods.

Below is an example use of `extraEnv`:

```yaml
extraEnv:
  SOME_KEY: some_value
  SOME_OTHER_KEY: some_other_value
```

When the container is started, you can confirm that the environment variables are exposed:

```shell
env | grep SOME
SOME_KEY=some_value
SOME_OTHER_KEY=some_other_value
```

### extraEnvFrom

`extraEnvFrom` allows you to expose additional environment variables from other data sources in all containers in the pods.

Below is an example use of `extraEnvFrom`:

```yaml
extraEnvFrom:
  MY_NODE_NAME:
    fieldRef:
      fieldPath: spec.nodeName
  MY_CPU_REQUEST:
    resourceFieldRef:
      containerName: test-container
      resource: requests.cpu
  SECRET_THING:
    secretKeyRef:
      name: special-secret
      key: special_token
      # optional: boolean
  CONFIG_STRING:
    configMapKeyRef:
      name: useful-config
      key: some-string
      # optional: boolean
```

### image.pullSecrets

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in the [Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`

```yaml
image:
  repository: my.gitaly.repository
  tag: latest
  pullPolicy: Always
  pullSecrets:
  - name: my-secret-name
  - name: my-secondary-secret-name
```

### serviceAccount

This section controls if a ServiceAccount should be created and if the default access token should be mounted in pods.

| Name                           |  Type   | Default | Description |
|:-------------------------------|:-------:|:--------|:------------|
| `annotations`                  |   Map   | `{}`    | ServiceAccount annotations. |
| `automountServiceAccountToken` | Boolean | `false` | Controls if the default ServiceAccount access token should be mounted in pods. You should not enable this unless it is required by certain sidecars to work properly (for example, Istio). |
| `create`                       | Boolean | `false` | Indicates whether or not to create a ServiceAccount. |
| `enabled`                      | Boolean | `false` | Indicates whether or not to use a ServiceAccount. |
| `name`                         | String  |         | Name of the ServiceAccount. If not set, the full chart name is used. |

### tolerations

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

### affinity

For more information, see [`affinity`](../_index.md#affinity).

### annotations

`annotations` allows you to add annotations to the Gitaly pods.

Below is an example use of `annotations`:

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

### priorityClassName

`priorityClassName` allows you to assign a [PriorityClass](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/)
to the Gitaly pods.

Below is an example use of `priorityClassName`:

```yaml
priorityClassName: persistence-enabled
```

### `git.config`

`git.config` allows you to add configuration to all Git commands spawned by
Gitaly. Accepts configuration as documented in `git-config(1)` in `key` /
`value` pairs, as shown below.

```yaml
git:
  config:
    - key: "pack.threads"
      value: 4
    - key: "fsck.missingSpaceBeforeDate"
      value: ignore
```

### cgroups

To prevent exhaustion, Gitaly uses **cgroups** to assign Git processes to a
cgroup based on the repository being operated on. Each cgroup has memory
and CPU limits, ensuring system stability and preventing resource saturation.

Please note that the `initContainer` that runs before Gitaly starts requires to be
**executed as root**. This container will configure the permissions so that Gitaly can manage cgroups.
Hence, it will mount a volume on the filesystem to have write access to `/sys/fs/cgroup`.

[Example of Oversubscription](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#configuring-oversubscription)

```yaml
cgroups:
  enabled: true
  # Total limit across all repository cgroups
  memoryBytes: 64424509440 # 60GiB
  cpuShares: 1024
  cpuQuotaUs: 1200000 # 12 cores
  # Per repository limits, 1000 repository cgroups
  repositories:
    count: 1000
    memoryBytes: 32212254720 # 30GiB
    cpuShares: 512
    cpuQuotaUs: 400000 # 4 cores
```

## External Services

This chart should be attached the Workhorse service.

### Workhorse

```yaml
workhorse:
  host: workhorse.example.com
  serviceName: webservice
  port: 8181
```

| Name          |  Type   | Default      | Description |
|:--------------|:-------:|:-------------|:------------|
| `host`        | String  |              | The hostname of the Workhorse server. This can be omitted in lieu of `serviceName`. |
| `port`        | Integer | `8181`       | The port on which to connect to the Workhorse server. |
| `serviceName` | String  | `webservice` | The name of the `service` which is operating the Workhorse server. If this is present, and `host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `host` value. This is convenient when using Workhorse as a part of the overall GitLab chart. |

## Chart settings

The following values are used to configure the Gitaly Pods.

{{< alert type="note" >}}

Gitaly uses an Auth Token to authenticate with the Workhorse and Sidekiq
services. The Auth Token secret and key are sourced from the `global.gitaly.authToken`
value. Additionally, the Gitaly container has a copy of GitLab Shell, which has some configuration
that can be set. The Shell authToken is sourced from the `global.shell.authToken`
values.

{{< /alert >}}

### Git Repository Persistence

This chart provisions a PersistentVolumeClaim and mounts a corresponding persistent
volume for the Git repository data. You'll need physical storage available in the
Kubernetes cluster for this to work. If you'd rather use emptyDir, disable PersistentVolumeClaim
with: `persistence.enabled: false`.

{{< alert type="note" >}}

The persistence settings for Gitaly are used in a volumeClaimTemplate
that should be valid for all your Gitaly pods. You should *not* include settings
that are meant to reference a single specific volume (such as `volumeName`). If you want
to reference a specific volume, you need to manually create the PersistentVolumeClaim.

{{< /alert >}}

{{< alert type="note" >}}

You can't change these through our settings once you've deployed. In [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
the `VolumeClaimTemplate` is immutable.
{{< /alert >}}

```yaml
persistence:
  enabled: true
  storageClass: standard
  accessMode: ReadWriteOnce
  size: 50Gi
  matchLabels: {}
  matchExpressions: []
  subPath: "data"
  annotations: {}
```

| Name               |  Type   | Default         | Description |
|:-------------------|:-------:|:----------------|:------------|
| `accessMode`       | String  | `ReadWriteOnce` | Sets the accessMode requested in the PersistentVolumeClaim. See [Kubernetes Access Modes Documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes) for details. |
| `enabled`          | Boolean | `true`          | Sets whether or not to use a PersistentVolumeClaims for the repository data. If `false`, an emptyDir volume is used. |
| `matchExpressions` |  Array  |                 | Accepts an array of label condition objects to match against when choosing a volume to bind. This is used in the `PersistentVolumeClaim` `selector` section. See the [volumes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector). |
| `matchLabels`      |   Map   |                 | Accepts a Map of label names and label values to match against when choosing a volume to bind. This is used in the `PersistentVolumeClaim` `selector` section. See the [volumes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector). |
| `size`             | String  | `50Gi`          | The minimum volume size to request for the data persistence. |
| `storageClass`     | String  |                 | Sets the storageClassName on the Volume Claim for dynamic provisioning. When unset or null, the default provisioner will be used. If set to a hyphen, dynamic provisioning is disabled. |
| `subPath`          | String  |                 | Sets the path within the volume to mount, rather than the volume root. The root is used if the subPath is empty. |
| `annotations`      |   Map   |                 | Sets the annotations on the Volume Claim for dynamic provisioning. See [Kubernetes Annotations Documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) for details. |

### Running Gitaly over TLS

{{< alert type="note" >}}

This section refers to Gitaly being run inside the cluster using
the Helm charts. If you are using an external Gitaly instance and want to use
TLS for communicating with it, refer [the external Gitaly documentation](../../../advanced/external-gitaly/_index.md#connecting-to-external-gitaly-over-tls)

{{< /alert >}}

Gitaly supports communicating with other components over TLS. This is controlled
by the settings `global.gitaly.tls.enabled` and `global.gitaly.tls.secretName`.
Follow the steps to run Gitaly over TLS:

1. The Helm chart expects a certificate to be provided for communicating over
   TLS with Gitaly. This certificate should apply to all the Gitaly nodes that
   are present. Hence all hostnames of each of these Gitaly nodes should be
   added as a Subject Alternate Name (SAN) to the certificate.

   To know the hostnames to use, check the file `/srv/gitlab/config/gitlab.yml`
   file in the Toolbox pod and check the various
   `gitaly_address` fields specified under `repositories.storages` key within it.

   ```shell
   kubectl exec -it <Toolbox pod> -- grep gitaly_address /srv/gitlab/config/gitlab.yml
   ```

{{< alert type="note" >}}

A basic script for generating custom signed certificates for
internal Gitaly pods [can be found in this repository](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/generate_certificates.sh).
Users can use or refer that script to generate certificates with proper
SAN attributes.

{{< /alert >}}

1. Create a k8s TLS secret using the certificate created.

   ```shell
   kubectl create secret tls gitaly-server-tls --cert=gitaly.crt --key=gitaly.key
   ```

1. Redeploy the Helm chart by passing `--set global.gitaly.tls.enabled=true`.

### Global server hooks

The Gitaly StatefulSet has support for [Global server hooks](https://docs.gitlab.com/administration/server_hooks/#create-a-global-server-hook-for-all-repositories). The hook scripts run on the Gitaly pod, and are therefore limited to the tools available in the [Gitaly container](https://gitlab.com/gitlab-org/build/CNG/-/blob/master/gitaly/Dockerfile).

The hooks are populated using [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/), and can be used by setting the following values as appropriate:

1. `global.gitaly.hooks.preReceive.configmap`
1. `global.gitaly.hooks.postReceive.configmap`
1. `global.gitaly.hooks.update.configmap`

To populate the ConfigMap, you can point `kubectl` to a directory of scripts:

```shell
kubectl create configmap MAP_NAME --from-file /PATH/TO/SCRIPT/DIR
```

### GPG signing commits created by GitLab

Gitaly has the ability to [GPG sign all commits](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#configure-commit-signing-for-gitlab-ui-commits) created via the GitLab UI, e.g. the WebIDE,
as well as commits created by GitLab, such as merge commits and squashes.

1. Create a k8s secret using your GPG private key.

   ```shell
   kubectl create secret generic gitaly-gpg-signing-key --from-file=signing_key=/path/to/gpg_signing_key.gpg
   ```

1. Enable GPG signing in your `values.yaml`.

   ```yaml
   gitlab:
     gitaly:
       gpgSigning:
         enabled: true
         secret: gitaly-gpg-signing-key
         key: signing_key
   ```

### Server-side backups

The chart supports [Gitaly server-side backups](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#configure-server-side-backups).
To use them:

1. Create a bucket to store the backups.
1. Configure the object store credentials and the storage URL.

   ```yaml
   gitlab:
     gitaly:
       extraEnvFrom:
          # Mount the exisitign object store secret to the expected environment variables.
          AWS_ACCESS_KEY_ID:
            secretKeyRef:
              name: <Rails object store secret>
              key: aws_access_key_id
          AWS_SECRET_ACCESS_KEY:
            secretKeyRef:
              name: <Rails object store secret>
              key: aws_secret_access_key
       backup:
         # This is the connection string for Gitaly server side backups.
         goCloudUrl: <object store connection URL>
   ```

   For the expected environment variables and storage URL format for your object storage backend, see
   the [Gitaly documentation](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#configure-server-side-backups).

1. [Enable server-side backups with `backup-utility`](../../../backup-restore/backup.md#server-side-repository-backups).
