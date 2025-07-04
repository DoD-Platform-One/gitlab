---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Using MinIO for Object storage
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

This chart is based on [`stable/minio`](https://github.com/helm/charts/tree/master/stable/minio)
version [`0.4.3`](https://github.com/helm/charts/tree/aaaf98b5d25c26cc2d483925f7256f2ce06be080/stable/minio),
and inherits most settings from there.

## Design Choices

Design choices related to the [upstream chart](https://github.com/helm/charts/tree/master/stable/minio)
can be found in the project's README.

GitLab chose to alter that chart in order to simplify configuration of the secrets,
and to remove all use of secrets in environment variables. GitLab added `initContainer`s
to control the population of secrets into the `config.json`, and a chart-wide `enabled` flag.

This chart makes use of only one secret:

- `global.minio.credentials.secret`: A global secret containing the `accesskey` and
  `secretkey` values that will be used for authentication to the bucket(s).

## Configuration

We will describe all the major sections of the configuration below. When configuring
from the parent chart, these values will be:

```yaml
minio:
  init:
  ingress:
    enabled:
    apiVersion:
    tls:
      enabled:
      secretName:
    annotations:
    configureCertmanager:
    proxyReadTimeout:
    proxyBodySize:
    proxyBuffering:
  tolerations:
  persistence:  # Upstream
    volumeName:
    matchLabels:
    matchExpressions:
    annotations:
  serviceType:  # Upstream
  servicePort:  # Upstream
  defaultBuckets:
  minioConfig:  # Upstream
```

### Installation command line options

The table below contains all the possible charts configurations that can be supplied
to the `helm install` command using the `--set` flags:

| Parameter                                                | Default                        | Description |
|----------------------------------------------------------|--------------------------------|-------------|
| `common.labels`                                          | `{}`                           | Supplemental labels that are applied to all objects created by this chart. |
| `init.containerSecurityContext.allowPrivilegeEscalation` | `false`                        | initContainer specific: Controls whether a process can gain more privileges than its parent process |
| `init.containerSecurityContext.runAsNonRoot`             | `true`                         | initContainer specific: Controls whether the container runs with a non-root user |
| `init.containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                    | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container |
| `defaultBuckets`                                         | `[{"name": "registry"}]`       | MinIO default buckets |
| `deployment.strategy`                                    | ``{ `type`: `Recreate` }``     | Allows one to configure the update strategy utilized by the deployment |
| `image`                                                  | `minio/minio`                  | MinIO image |
| `imagePullPolicy`                                        | `Always`                       | MinIO image pull policy |
| `imageTag`                                               | `RELEASE.2017-12-28T01-21-00Z` | MinIO image tag |
| `minioConfig.browser`                                    | `on`                           | MinIO browser flag |
| `minioConfig.domain`                                     |                                | MinIO domain |
| `minioConfig.region`                                     | `us-east-1`                    | MinIO region |
| `minioMc.image`                                          | `minio/mc`                     | MinIO mc image |
| `minioMc.tag`                                            | `latest`                       | MinIO mc image tag |
| `mountPath`                                              | `/export`                      | MinIO configuration file mount path |
| `persistence.accessMode`                                 | `ReadWriteOnce`                | MinIO persistence access mode |
| `persistence.annotations`                                |                                | MinIO PersistentVolumeClaim annotations |
| `persistence.enabled`                                    | `true`                         | MinIO enable persistence flag |
| `persistence.matchExpressions`                           |                                | MinIO label-expression matches to bind |
| `persistence.matchLabels`                                |                                | MinIO label-value matches to bind |
| `persistence.size`                                       | `10Gi`                         | MinIO persistence volume size |
| `persistence.storageClass`                               |                                | MinIO storageClassName for provisioning |
| `persistence.subPath`                                    |                                | MinIO persistence volume mount path |
| `persistence.volumeName`                                 |                                | MinIO existing persistent volume name |
| `priorityClassName`                                      |                                | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods. |
| `pullSecrets`                                            |                                | Secrets for the image repository |
| `resources.requests.cpu`                                 | `250m`                         | MinIO minimum CPU requested |
| `resources.requests.memory`                              | `256Mi`                        | MinIO minimum memory requested |
| `securityContext.fsGroup`                                | `1000`                         | Group ID to start the pod with |
| `securityContext.runAsUser`                              | `1000`                         | User ID to start the pod with |
| `securityContext.fsGroupChangePolicy`                    |                                | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23) |
| `securityContext.seccompProfile.type`                    | `RuntimeDefault`               | Seccomp profile to use |
| `containerSecurityContext.runAsUser`                     | `1000`                         | Allow to overwrite the specific security context under which the container is started |
| `containerSecurityContext.allowPrivilegeEscalation`      | `false`                        | Controls whether a process of the Gitaly container can gain more privileges than its parent process |
| `containerSecurityContext.runAsNonRoot`                  | `true`                         | Controls whether the container runs with a non-root user |
| `containerSecurityContext.capabilities.drop`             | `[ "ALL" ]`                    | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container |
| `serviceAccount.automountServiceAccountToken`            | `false`                        | Indicates whether or not the default ServiceAccount access token should be mounted in pods |
| `servicePort`                                            | `9000`                         | MinIO service port |
| `serviceType`                                            | `ClusterIP`                    | MinIO service type |
| `tolerations`                                            | `[]`                           | Toleration labels for pod assignment |
| `jobAnnotations`                                         | `{}`                           | Annotations for the job spec |

## Chart configuration examples

### `pullSecrets`

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in [the Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```yaml
image: my.minio.repository
imageTag: latest
imagePullPolicy: Always
pullSecrets:
- name: my-secret-name
- name: my-secondary-secret-name
```

### `serviceAccount`

This section controls if the default ServiceAccount access token should be mounted in pods.

| Name                           |  Type   | Default | Description |
|:-------------------------------|:-------:|:--------|:------------|
| `automountServiceAccountToken` | Boolean | `false` | Controls if the default ServiceAccount access token should be mounted in pods. You should not enable this unless it is required by certain sidecars to work properly (for example, Istio). |

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

## Enable the sub-chart

They way we've chosen to implement compartmentalized sub-charts includes the ability
to disable the components that you may not want in a given deployment. For this reason,
the first setting you should decide on is `enabled:`.

By default, MinIO is enabled out of the box, but is not recommended for production use.
When you are ready to disable it, run `--set global.minio.enabled: false`.

## Configure the `initContainer`

While rarely altered, the `initContainer` behaviors can be changed via the following items:

```yaml
init:
  image:
    repository:
    tag:
    pullPolicy: IfNotPresent
  script:
```

### initContainer image

The initContainer image settings are just as with a normal image configuration.
By default, chart-local values are left empty, and the global settings
`global.gitlabBase.image.repository` and the image tag associated with the current
`global.gitlabVersion` will be used to populate the initContainer image.
The global configuration can be overridden by chart-local values (e.g. `minio.init.image.tag`).

### initContainer script

The initContainer is passed the following items:

- The secret containing authentication items mounted in `/config`, usually `accesskey`
  and `secretkey`.
- The ConfigMap containing the `config.json` template, and `configure` containing a
  script to be executed with `sh`, mounted in `/config`.
- An `emptyDir` mounted at `/minio` that will be passed to the daemon's container.

The initContainer is expected to populate `/minio/config.json` with a completed configuration,
using `/config/configure` script. When the `minio-config` container has completed
that task, the `/minio` directory will be passed to the `minio` container, and used
to provide the `config.json` to the [MinIO](https://min.io) server.

## Configuring the Ingress

These settings control the MinIO Ingress.

| Name                   |  Type   | Default | Description |
|:-----------------------|:-------:|:--------|:------------|
| `apiVersion`           | String  |         | Value to use in the `apiVersion` field. |
| `annotations`          | String  |         | This field is an exact match to the standard `annotations` for [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/). |
| `enabled`              | Boolean | `false` | Setting that controls whether to create Ingress objects for services that support them. When `false` the `global.ingress.enabled` setting is used. |
| `configureCertmanager` | Boolean |         | Toggles Ingress annotation `cert-manager.io/issuer` and `acme.cert-manager.io/http01-edit-in-place`.. For more information see the [TLS requirement for GitLab Pages](../../installation/tls.md). |
| `tls.enabled`          | Boolean | `true`  | When set to `false`, you disable TLS for MinIO. This is mainly useful when you cannot use TLS termination at Ingress-level, like when you have a TLS-terminating proxy before the Ingress Controller. |
| `tls.secretName`       | String  |         | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the MinIO URL. When not set, the `global.ingress.tls.secretName` is used instead. |

## Configuring the image

The `image`, `imageTag` and `imagePullPolicy` defaults are
[documented upstream](https://github.com/helm/charts/tree/master/stable/minio#configuration).

## Persistence

This chart provisions a `PersistentVolumeClaim` and mounts a corresponding persistent
volume to default location `/export`. You'll need physical storage available in the
Kubernetes cluster for this to work. If you'd rather use `emptyDir`, disable `PersistentVolumeClaim`
by: `persistence.enabled: false`.

The behaviors for [`persistence`](https://github.com/helm/charts/tree/master/stable/minio#persistence)
are [documented upstream](https://github.com/helm/charts/tree/master/stable/minio#configuration).

GitLab has added a few items:

```yaml
persistence:
  volumeName:
  matchLabels:
  matchExpressions:
```

| Name               |  Type  | Default | Description |
|:-------------------|:------:|:--------|:------------|
| `volumeName`       | String | `false` | When `volumeName` is provided, the `PersistentVolumeClaim` will use the provided `PersistentVolume` by name, in place of creating a `PersistentVolume` dynamically. This overrides the upstream behavior. |
| `matchLabels`      |  Map   | `true`  | Accepts a Map of label names and label values to match against when choosing a volume to bind. This is used in the `PersistentVolumeClaim` `selector` section. See the [volumes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector). |
| `matchExpressions` | Array  |         | Accepts an array of label condition objects to match against when choosing a volume to bind. This is used in the `PersistentVolumeClaim` `selector` section. See the [volumes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#selector). |

## `defaultBuckets`

`defaultBuckets` provides a mechanism to automatically create buckets on the MinIO
pod at *installation*. This property contains an array of items, each with up to three
properties: `name`, `policy`, and `purge`.

```yaml
defaultBuckets:
  - name: public
    policy: public
    purge: true
  - name: private
  - name: public-read
    policy: download
```

<<<<<<< HEAD
| Name     | Type    | Default | Description |
|:-------- |:-------:|:--------|:------------|
| `name`   | String  |         | The name of the bucket that is created. The provided value should conform to [AWS bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html), meaning that it should be compliant with DNS and contain only the characters a-z, 0-9, and – (hyphen) in strings between 3 and 63 characters in length. The `name` property is *required* for all entries. |
=======
| Name     |  Type   | Default | Description |
|:---------|:-------:|:--------|:------------|
| `name`   | String  |         | The name of the bucket that is created. The provided value should conform to [AWS bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/dev/BucketRestrictions.html), meaning that it should be compliant with DNS and contain only the characters a-z, 0-9, and - (hyphen) in strings between 3 and 63 characters in length. The `name` property is _required_ for all entries. |
>>>>>>> update "chart" (https://gitlab.com/gitlab-org/charts/gitlab) from "v9.0.2" (5e1e1c247f8094368555a6a03c2ccd6d54a06568) to "v9.1.0" (8a18dded579efa254bd24fee1b9d5d0112a3fd0a)
| `policy` |         | `none`  | The value of `policy` controls the access policy of the bucket on MinIO. The `policy` property is not required, and the default value is `none`. In regards to **anonymous** access, possible values are: `none` (no anonymous access), `download` (anonymous read-only access), `upload` (anonymous write-only access) or `public` (anonymous read/write access). |
| `purge`  | Boolean |         | The `purge` property is provided as a means to cause any existing bucket to be removed with force, at installation time. This only comes into play when using a pre-existing `PersistentVolume` for the volumeName property of [persistence](#persistence). If you make use of a dynamically created `PersistentVolume`, this will have no valuable effect as it only happens at chart installation and there will be no data in the `PersistentVolume` that was just created. This property is not required, but you may specify this property with a value of `true` in order to cause a bucket to purged with force `mc rm -r --force`. |

## Security Context

These options allow control over which `user` and/or `group` is used to start the pod.

For in-depth information about security context, please refer to the official
[Kubernetes documentation](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/).

## Service Type and Port

These are [documented upstream](https://github.com/helm/charts/tree/master/stable/minio#configuration),
and the key summary is:

```yaml
## Expose the MinIO service to be accessed from outside the cluster (LoadBalancer service).
## or access it from within the cluster (ClusterIP service). Set the service type and the port to serve it.
## ref: http://kubernetes.io/docs/user-guide/services/
##
serviceType: LoadBalancer
servicePort: 9000
```

The chart does not expect to be of the `type: NodePort`, so **do not** set it as such.

## Upstream items

The [upstream documentation](https://github.com/helm/charts/tree/master/stable/minio)
for the following also applies completely to this chart:

- `resources`
- `nodeSelector`
- `minioConfig`

Further explanation of the `minioConfig` settings can be found in the
[MinIO notify documentation](https://min.io/docs/minio/kubernetes/upstream/index.html).
This includes details on publishing notifications when Bucket Objects are accessed or changed.
