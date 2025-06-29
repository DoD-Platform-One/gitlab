---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Using the GitLab-Exporter chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

The `gitlab-exporter` sub-chart provides Prometheus metrics for GitLab
application-specific data. It talks to PostgreSQL directly to perform
queries to retrieve data for CI builds, pull mirrors, etc. In addition,
it uses the Sidekiq API, which talks to Redis to gather different
metrics around the state of the Sidekiq queues (e.g. number of jobs).

## Requirements

This chart depends on Redis and PostgreSQL services, either as part of
the complete GitLab chart or provided as external services reachable
from the Kubernetes cluster on which this chart is deployed.

## Configuration

The `gitlab-exporter` chart is configured as follows:
[Global settings](#global-settings) and [Chart settings](#chart-settings).

## Installation command line options

The table below contains all the possible chart configurations that can be supplied
to the `helm install` command using the `--set` flags.

| Parameter                                                | Default                                                    | Description |
|----------------------------------------------------------|------------------------------------------------------------|-------------|
| `affinity`                                               | `{}`                                                       | [Affinity rules](../_index.md#affinity) for pod assignment |
| `annotations`                                            |                                                            | Pod annotations |
| `common.labels`                                          | `{}`                                                       | Supplemental labels that are applied to all objects created by this chart. |
| `podLabels`                                              |                                                            | Supplemental Pod labels. Will not be used for selectors. |
| `common.labels`                                          |                                                            | Supplemental labels that are applied to all objects created by this chart. |
| `deployment.strategy`                                    | `{}`                                                       | Allows one to configure the update strategy utilized by the deployment |
| `enabled`                                                | `true`                                                     | GitLab Exporter enabled flag |
| `extraContainers`                                        |                                                            | Multiline literal style string containing a list of containers to include |
| `extraInitContainers`                                    |                                                            | List of extra init containers to include |
| `extraVolumeMounts`                                      |                                                            | List of extra volumes mounts to do |
| `extraVolumes`                                           |                                                            | List of extra volumes to create |
| `extraEnv`                                               |                                                            | List of extra environment variables to expose |
| `extraEnvFrom`                                           |                                                            | List of extra environment variables from other data sources to expose |
| `image.pullPolicy`                                       | `IfNotPresent`                                             | GitLab image pull policy |
| `image.pullSecrets`                                      |                                                            | Secrets for the image repository |
| `image.repository`                                       | `registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter` | GitLab Exporter image repository |
| `image.tag`                                              |                                                            | image tag   |
| `init.image.repository`                                  |                                                            | initContainer image |
| `init.image.tag`                                         |                                                            | initContainer image tag |
| `init.containerSecurityContext`                          |                                                            | initContainer specific [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) |
| `init.containerSecurityContext.allowPrivilegeEscalation` | `false`                                                    | initContainer specific: Controls whether a process can gain more privileges than its parent process |
| `init.containerSecurityContext.runAsNonRoot`             | `true`                                                     | initContainer specific: Controls whether the container runs with a non-root user |
| `init.containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                                                | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container |
| `metrics.enabled`                                        | `true`                                                     | If a metrics endpoint should be made available for scraping |
| `metrics.port`                                           | `9168`                                                     | Metrics endpoint port |
| `metrics.path`                                           | `/metrics`                                                 | Metrics endpoint path |
| `metrics.serviceMonitor.enabled`                         | `false`                                                    | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping, note that enabling this removes the `prometheus.io` scrape annotations |
| `metrics.serviceMonitor.additionalLabels`                | `{}`                                                       | Additional labels to add to the ServiceMonitor |
| `metrics.serviceMonitor.endpointConfig`                  | `{}`                                                       | Additional endpoint configuration for the ServiceMonitor |
| `metrics.annotations`                                    |                                                            | **DEPRECATED** Set explicit metrics annotations. Replaced by template content. |
| `priorityClassName`                                      |                                                            | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods. |
| `resources.requests.cpu`                                 | `75m`                                                      | GitLab Exporter minimum CPU |
| `resources.requests.memory`                              | `100M`                                                     | GitLab Exporter minimum memory |
| `serviceLabels`                                          | `{}`                                                       | Supplemental service labels |
| `service.externalPort`                                   | `9168`                                                     | GitLab Exporter exposed port |
| `service.internalPort`                                   | `9168`                                                     | GitLab Exporter internal port |
| `service.name`                                           | `gitlab-exporter`                                          | GitLab Exporter service name |
| `service.type`                                           | `ClusterIP`                                                | GitLab Exporter service type |
| `serviceAccount.annotations`                             | `{}`                                                       | ServiceAccount annotations |
| `serviceAccount.automountServiceAccountToken`            | `false`                                                    | Indicates whether or not the default ServiceAccount access token should be mounted in pods |
| `serviceAccount.create`                                  | `false`                                                    | Indicates whether or not a ServiceAccount should be created |
| `serviceAccount.enabled`                                 | `false`                                                    | Indicates whether or not to use a ServiceAccount |
| `serviceAccount.name`                                    |                                                            | Name of the ServiceAccount. If not set, the full chart name is used |
| `securityContext.fsGroup`                                | `1000`                                                     | Group ID under which the pod should be started |
| `securityContext.runAsUser`                              | `1000`                                                     | User ID under which the pod should be started |
| `securityContext.fsGroupChangePolicy`                    |                                                            | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23) |
| `securityContext.seccompProfile.type`                    | `RuntimeDefault`                                           | Seccomp profile to use |
| `containerSecurityContext`                               |                                                            | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started |
| `containerSecurityContext.runAsUser`                     | `1000`                                                     | Allows overwriting of the specific security context user ID under which the container is started |
| `containerSecurityContext.allowPrivilegeEscalation`      | `false`                                                    | Controls whether a process of the container can gain more privileges than its parent process |
| `containerSecurityContext.runAsNonRoot`                  | `false`                                                    | Controls whether the container runs with a non-root user |
| `containerSecurityContext.capabilities.drop`             | `[ "ALL" ]`                                                | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container |
| `tolerations`                                            | `[]`                                                       | Toleration labels for pod assignment |
| `psql.port`                                              |                                                            | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `tls.enabled`                                            | `false`                                                    | GitLab Exporter TLS enabled |
| `tls.secretName`                                         | `{Release.Name}-gitlab-exporter-tls`                       | GitLab Exporter TLS secret. Must point to a [Kubernetes TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets). |

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
found in [the Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```YAML
image:
  repository: my.image.repository
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
| `create`                       | Boolean | `false` | Indicates whether or not a ServiceAccount should be created. |
| `enabled`                      | Boolean | `false` | Indicates whether or not to use a ServiceAccount. |
| `name`                         | String  |         | Name of the ServiceAccount. If not set, the full chart name is used. |

### affinity

For more information, see [`affinity`](../_index.md#affinity).

### annotations

`annotations` allows you to add annotations to the GitLab Exporter pods. For example:

```YAML
annotations:
  kubernetes.io/example-annotation: annotation-value
```

## Global settings

We share some common global settings among our charts. See the [Globals Documentation](../../globals.md)
for common configuration options, such as GitLab and Registry hostnames.

## Chart settings

The following values are used to configure the GitLab Exporter pod.

### metrics.enabled

By default, the pod exposes a metrics endpoint at `/metrics`. When
metrics are enabled, annotations are added to each pod allowing a
Prometheus server to discover and scrape the exposed metrics.
