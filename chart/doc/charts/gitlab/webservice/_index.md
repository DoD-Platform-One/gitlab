---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Using the GitLab Webservice chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

The `webservice` sub-chart provides the GitLab Rails webserver with two Webservice workers
per pod, which is the minimum necessary for a single pod to be able to serve any web request in GitLab.

The pods of this chart make use of two containers: `gitlab-workhorse` and `webservice`.
[GitLab Workhorse](https://gitlab.com/gitlab-org/gitlab/-/tree/master/workhorse) listens on
port `8181`, and should _always_ be the destination for inbound traffic to the pod.
The `webservice` houses the GitLab [Rails codebase](https://gitlab.com/gitlab-org/gitlab),
listens on `8080`, and is accessible for metrics collection purposes.
`webservice` should never receive normal traffic directly.

## Requirements

This chart depends on Redis, PostgreSQL, Gitaly, and Registry services, either as
part of the complete GitLab chart or provided as external services reachable from
the Kubernetes cluster this chart is deployed onto.

## Configuration

The `webservice` chart is configured as follows: [Global settings](#global-settings),
[Deployments settings](#deployments-settings), [Ingress settings](#ingress-settings), [External services](#external-services), and
[Chart settings](#chart-settings).

## Installation command line options

The table below contains all the possible chart configurations that can be supplied
to the `helm install` command using the `--set` flags.

| Parameter                                                     | Default                                                         | Description |
|---------------------------------------------------------------|-----------------------------------------------------------------|-------------|
| `annotations`                                                 |                                                                 | Pod annotations |
| `podLabels`                                                   |                                                                 | Supplemental Pod labels. Will not be used for selectors. |
| `common.labels`                                               |                                                                 | Supplemental labels that are applied to all objects created by this chart. |
| `deployment.terminationGracePeriodSeconds`                    | `30`                                                            | Seconds that Kubernetes will wait for a pod to exit, note this must be longer than `shutdown.blackoutSeconds` |
| `deployment.livenessProbe.initialDelaySeconds`                | `20`                                                            | Delay before liveness probe is initiated |
| `deployment.livenessProbe.periodSeconds`                      | `60`                                                            | How often to perform the liveness probe |
| `deployment.livenessProbe.timeoutSeconds`                     | `30`                                                            | When the liveness probe times out |
| `deployment.livenessProbe.successThreshold`                   | `1`                                                             | Minimum consecutive successes for the liveness probe to be considered successful after having failed |
| `deployment.livenessProbe.failureThreshold`                   | `3`                                                             | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded |
| `deployment.readinessProbe.initialDelaySeconds`               | `0`                                                             | Delay before readiness probe is initiated |
| `deployment.readinessProbe.periodSeconds`                     | `10`                                                            | How often to perform the readiness probe |
| `deployment.readinessProbe.timeoutSeconds`                    | `2`                                                             | When the readiness probe times out |
| `deployment.readinessProbe.successThreshold`                  | `1`                                                             | Minimum consecutive successes for the readiness probe to be considered successful after having failed |
| `deployment.readinessProbe.failureThreshold`                  | `3`                                                             | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded |
| `deployment.strategy`                                         | `{}`                                                            | Allows one to configure the update strategy used by the deployment. When not provided, the cluster default is used. |
| `enabled`                                                     | `true`                                                          | Webservice enabled flag |
| `extraContainers`                                             |                                                                 | Multiline literal style string containing a list of containers to include |
| `extraInitContainers`                                         |                                                                 | List of extra init containers to include |
| `extras.google_analytics_id`                                  | `nil`                                                           | Google Analytics ID for frontend |
| `extraVolumeMounts`                                           |                                                                 | List of extra volumes mounts to do |
| `extraVolumes`                                                |                                                                 | List of extra volumes to create |
| `extraEnv`                                                    |                                                                 | List of extra environment variables to expose |
| `extraEnvFrom`                                                |                                                                 | List of extra environment variables from other data sources to expose |
| `gitlab.webservice.workhorse.image`                           | `registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ee`  | Workhorse image repository |
| `gitlab.webservice.workhorse.tag`                             |                                                                 | Workhorse image tag |
| `hpa.behavior`                                                | `{scaleDown: {stabilizationWindowSeconds: 300 }}`               | Behavior contains the specifications for up- and downscaling behavior (requires `autoscaling/v2beta2` or higher) |
| `hpa.customMetrics`                                           | `[]`                                                            | Custom metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) |
| `hpa.cpu.targetType`                                          | `AverageValue`                                                  | Set the autoscaling CPU target type, must be either `Utilization` or `AverageValue` |
| `hpa.cpu.targetAverageValue`                                  | `1`                                                             | Set the autoscaling CPU target value |
| `hpa.cpu.targetAverageUtilization`                            |                                                                 | Set the autoscaling CPU target utilization |
| `hpa.memory.targetType`                                       |                                                                 | Set the autoscaling memory target type, must be either `Utilization` or `AverageValue` |
| `hpa.memory.targetAverageValue`                               |                                                                 | Set the autoscaling memory target value |
| `hpa.memory.targetAverageUtilization`                         |                                                                 | Set the autoscaling memory target utilization |
| `hpa.targetAverageValue`                                      |                                                                 | **DEPRECATED** Set the autoscaling CPU target value |
| `sshHostKeys.mount`                                           | `false`                                                         | Whether to mount the GitLab Shell secret containing the public SSH keys. |
| `sshHostKeys.mountName`                                       | `ssh-host-keys`                                                 | Name of the mounted volume. |
| `sshHostKeys.types`                                           | `[dsa,rsa,ecdsa,ed25519]`                                       | List of SSH key types to mount. |
| `image.pullPolicy`                                            | `Always`                                                        | Webservice image pull policy |
| `image.pullSecrets`                                           |                                                                 | Secrets for the image repository |
| `image.repository`                                            | `registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ee` | Webservice image repository |
| `image.tag`                                                   |                                                                 | Webservice image tag |
| `init.image.repository`                                       |                                                                 | initContainer image |
| `init.image.tag`                                              |                                                                 | initContainer image tag |
| `init.containerSecurityContext.runAsUser`                     | `1000`                                                          | initContainer specific: User ID under which the container should be started |
| `init.containerSecurityContext.allowPrivilegeEscalation`      | `false`                                                         | initContainer specific: Controls whether a process can gain more privileges than its parent process |
| `init.containerSecurityContext.runAsNonRoot`                  | `true`                                                          | initContainer specific: Controls whether the container runs with a non-root user |
| `init.containerSecurityContext.capabilities.drop`             | `[ "ALL" ]`                                                     | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container |
| `keda.enabled`                                                | `false`                                                         | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers` |
| `keda.pollingInterval`                                        | `30`                                                            | The interval to check each trigger on |
| `keda.cooldownPeriod`                                         | `300`                                                           | The period to wait after the last trigger reported active before scaling the resource back to 0 |
| `keda.minReplicaCount`                                        | `minReplicas`                                                   | Minimum number of replicas KEDA will scale the resource down to. |
| `keda.maxReplicaCount`                                        | `maxReplicas`                                                   | Maximum number of replicas KEDA will scale the resource up to. |
| `keda.fallback`                                               |                                                                 | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback) |
| `keda.hpaName`                                                | `keda-hpa-{scaled-object-name}`                                 | The name of the HPA resource KEDA will create. |
| `keda.restoreToOriginalReplicaCount`                          |                                                                 | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted |
| `keda.behavior`                                               | `hpa.behavior`                                                  | The specifications for up- and downscaling behavior. |
| `keda.triggers`                                               |                                                                 | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory` |
| `metrics.enabled`                                             | `true`                                                          | If a metrics endpoint should be made available for scraping |
| `metrics.port`                                                | `8083`                                                          | Metrics endpoint port |
| `metrics.path`                                                | `/metrics`                                                      | Metrics endpoint path |
| `metrics.serviceMonitor.enabled`                              | `false`                                                         | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping, note that enabling this removes the `prometheus.io` scrape annotations |
| `metrics.serviceMonitor.additionalLabels`                     | `{}`                                                            | Additional labels to add to the ServiceMonitor |
| `metrics.serviceMonitor.endpointConfig`                       | `{}`                                                            | Additional endpoint configuration for the ServiceMonitor |
| `metrics.annotations`                                         |                                                                 | **DEPRECATED** Set explicit metrics annotations. Replaced by template content. |
| `metrics.tls.enabled`                                         |                                                                 | TLS enabled for the metrics/web_exporter endpoint. Defaults to `tls.enabled`. |
| `metrics.tls.secretName`                                      |                                                                 | Secret for the metrics/web_exporter endpoint TLS cert and key. Defaults to `tls.secretName`. |
| `minio.bucket`                                                | `git-lfs`                                                       | Name of storage bucket, when using MinIO |
| `minio.port`                                                  | `9000`                                                          | Port for MinIO service |
| `minio.serviceName`                                           | `minio-svc`                                                     | Name of MinIO service |
| `monitoring.ipWhitelist`                                      | `[0.0.0.0/0]`                                                   | List of IPs to whitelist for the monitoring endpoints |
| `monitoring.exporter.enabled`                                 | `false`                                                         | Enable webserver to expose Prometheus metrics, this is overridden by `metrics.enabled` if the metrics port is set to the monitoring exporter port |
| `monitoring.exporter.port`                                    | `8083`                                                          | Port number to use for the metrics exporter |
| `psql.password.key`                                           | `psql-password`                                                 | Key to psql password in psql secret |
| `psql.password.secret`                                        | `gitlab-postgres`                                               | psql secret name |
| `psql.port`                                                   |                                                                 | Set PostgreSQL server port. Takes precedence over `global.psql.port` |
| `puma.disableWorkerKiller`                                    | `true`                                                          | Disables Puma worker memory killer |
| `puma.workerMaxMemory`                                        |                                                                 | The maximum memory (in megabytes) for the Puma worker killer |
| `puma.threads.min`                                            | `4`                                                             | The minimum amount of Puma threads |
| `puma.threads.max`                                            | `4`                                                             | The maximum amount of Puma threads |
| `rack_attack.git_basic_auth`                                  | `{}`                                                            | See [GitLab documentation](https://docs.gitlab.com/administration/settings/protected_paths/) for details |
| `redis.serviceName`                                           | `redis`                                                         | Redis service name |
| `global.registry.api.port`                                    | `5000`                                                          | Registry port |
| `global.registry.api.protocol`                                | `http`                                                          | Registry protocol |
| `global.registry.api.serviceName`                             | `registry`                                                      | Registry service name |
| `global.registry.enabled`                                     | `true`                                                          | Add/Remove registry link in all projects menu |
| `global.registry.tokenIssuer`                                 | `gitlab-issuer`                                                 | Registry token issuer |
| `replicaCount`                                                | `1`                                                             | Webservice number of replicas |
| `resources.requests.cpu`                                      | `300m`                                                          | Webservice minimum CPU |
| `resources.requests.memory`                                   | `1.5G`                                                          | Webservice minimum memory |
| `service.externalPort`                                        | `8080`                                                          | Webservice exposed port |
| `securityContext.fsGroup`                                     | `1000`                                                          | Group ID under which the pod should be started |
| `securityContext.runAsUser`                                   | `1000`                                                          | User ID under which the pod should be started |
| `securityContext.fsGroupChangePolicy`                         |                                                                 | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23) |
| `securityContext.seccompProfile.type`                         | `RuntimeDefault`                                                | Seccomp profile to use |
| `containerSecurityContext`                                    |                                                                 | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started |
| `containerSecurityContext.runAsUser`                          | `1000`                                                          | Allow to overwrite the specific security context user ID under which the container is started |
| `containerSecurityContext.allowPrivilegeEscalation`           | `false`                                                         | Controls whether a process of the Gitaly container can gain more privileges than its parent process |
| `containerSecurityContext.runAsNonRoot`                       | `true`                                                          | Controls whether the Gitaly container runs with a non-root user |
| `containerSecurityContext.capabilities.drop`                  | `[ "ALL" ]`                                                     | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container |
| `serviceAccount.automountServiceAccountToken`                 | `false`                                                         | Indicates whether or not the default ServiceAccount access token should be mounted in pods |
| `serviceAccount.create`                                       | `false`                                                         | Indicates whether or not a ServiceAccount should be created |
| `serviceAccount.enabled`                                      | `false`                                                         | Indicates whether or not to use a ServiceAccount |
| `serviceAccount.name`                                         |                                                                 | Name of the ServiceAccount. If not set, the full chart name is used |
| `serviceLabels`                                               | `{}`                                                            | Supplemental service labels |
| `service.internalPort`                                        | `8080`                                                          | Webservice internal port |
| `service.type`                                                | `ClusterIP`                                                     | Webservice service type |
| `service.workhorseExternalPort`                               | `8181`                                                          | Workhorse exposed port |
| `service.workhorseInternalPort`                               | `8181`                                                          | Workhorse internal port |
| `service.loadBalancerIP`                                      |                                                                 | IP address to assign to LoadBalancer (if supported by cloud provider) |
| `service.loadBalancerSourceRanges`                            |                                                                 | List of IP CIDRs allowed access to LoadBalancer (if supported) Required for service.type = LoadBalancer |
| `shell.authToken.key`                                         | `secret`                                                        | Key to shell token in shell secret |
| `shell.authToken.secret`                                      | `{Release.Name}-gitlab-shell-secret`                            | Shell token secret |
| `shell.port`                                                  | `nil`                                                           | Port number to use in SSH URLs generated by UI |
| `shutdown.blackoutSeconds`                                    | `10`                                                            | Number of seconds to keep Webservice running after receiving shutdown, note this must shorter than `deployment.terminationGracePeriodSeconds` |
| `tls.enabled`                                                 | `false`                                                         | Webservice TLS enabled |
| `tls.secretName`                                              | `{Release.Name}-webservice-tls`                                 | Webservice TLS secrets. `secretName` must point to a [Kubernetes TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets). |
| `tolerations`                                                 | `[]`                                                            | Toleration labels for pod assignment |
| `trusted_proxies`                                             | `[]`                                                            | See [GitLab documentation](https://docs.gitlab.com/install/installation/#adding-your-trusted-proxies) for details |
| `workhorse.logFormat`                                         | `json`                                                          | Logging format. Valid formats: `json`, `structured`, `text` |
| `workerProcesses`                                             | `2`                                                             | Webservice number of workers |
| `workhorse.keywatcher`                                        | `true`                                                          | Subscribe workhorse to Redis. This is **required** by any deployment servicing request to `/api/*`, but can be safely disabled for other deployments |
| `workhorse.shutdownTimeout`                                   | `global.webservice.workerTimeout + 1` (seconds)                 | Time to wait for all Web requests to clear from Workhorse. Examples: `1min`, `65s`. |
| `workhorse.trustedCIDRsForPropagation`                        |                                                                 | A list of CIDR blocks that can be trusted for propagating a correlation ID. The `-propagateCorrelationID` option must also be used in `workhorse.extraArgs` for this to work. See the [Workhorse documentation](https://docs.gitlab.com/development/workhorse/configuration/#propagate-correlation-ids) for more details. |
| `workhorse.trustedCIDRsForXForwardedFor`                      |                                                                 | A list of CIDR blocks that can be used to resolve the actual client IP via the `X-Forwarded-For` HTTP header. This is used with `workhorse.trustedCIDRsForPropagation`. See the [Workhorse documentation](https://docs.gitlab.com/development/workhorse/configuration/#trusted-proxies) for more details. |
| `workhorse.metadata.zipReaderLimitBytes`                      |                                                                 | The optional number of bytes to limit the zip reader to. Introduced in GitLab 16.9. See the [Workhorse documentation](https://docs.gitlab.com/development/workhorse/configuration/#metadata-options) for more details. |
| `workhorse.containerSecurityContext`                          |                                                                 | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started |
| `workhorse.containerSecurityContext.runAsUser`                | `1000`                                                          | User ID under which the container should be started |
| `workhorse.containerSecurityContext.allowPrivilegeEscalation` | `false`                                                         | Controls whether a process of the container can gain more privileges than its parent process |
| `workhorse.containerSecurityContext.runAsNonRoot`             | `true`                                                          | Controls whether the container runs with a non-root user |
| `workhorse.containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                                                     | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container |
| `workhorse.livenessProbe.initialDelaySeconds`                 | `20`                                                            | Delay before liveness probe is initiated |
| `workhorse.livenessProbe.periodSeconds`                       | `60`                                                            | How often to perform the liveness probe |
| `workhorse.livenessProbe.timeoutSeconds`                      | `30`                                                            | When the liveness probe times out |
| `workhorse.livenessProbe.successThreshold`                    | `1`                                                             | Minimum consecutive successes for the liveness probe to be considered successful after having failed |
| `workhorse.livenessProbe.failureThreshold`                    | `3`                                                             | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded |
| `workhorse.monitoring.exporter.enabled`                       | `false`                                                         | Enable workhorse to expose Prometheus metrics, this is overridden by `workhorse.metrics.enabled` |
| `workhorse.monitoring.exporter.port`                          | `9229`                                                          | Port number to use for workhorse Prometheus metrics |
| `workhorse.monitoring.exporter.tls.enabled`                   | `false`                                                         | When set to `true`, enables TLS on metrics endpoint. It requires [TLS to be enabled for Workhorse](#gitlab-workhorse). |
| `workhorse.metrics.enabled`                                   | `true`                                                          | If a workhorse metrics endpoint should be made available for scraping |
| `workhorse.metrics.port`                                      | `8083`                                                          | Workhorse metrics endpoint port |
| `workhorse.metrics.path`                                      | `/metrics`                                                      | Workhorse metrics endpoint path |
| `workhorse.metrics.serviceMonitor.enabled`                    | `false`                                                         | If a ServiceMonitor should be created to enable Prometheus Operator to manage the Workhorse metrics scraping |
| `workhorse.metrics.serviceMonitor.additionalLabels`           | `{}`                                                            | Additional labels to add to the Workhorse ServiceMonitor |
| `workhorse.metrics.serviceMonitor.endpointConfig`             | `{}`                                                            | Additional endpoint configuration for the Workhorse ServiceMonitor |
| `workhorse.readinessProbe.initialDelaySeconds`                | `0`                                                             | Delay before readiness probe is initiated |
| `workhorse.readinessProbe.periodSeconds`                      | `10`                                                            | How often to perform the readiness probe |
| `workhorse.readinessProbe.timeoutSeconds`                     | `2`                                                             | When the readiness probe times out |
| `workhorse.readinessProbe.successThreshold`                   | `1`                                                             | Minimum consecutive successes for the readiness probe to be considered successful after having failed |
| `workhorse.readinessProbe.failureThreshold`                   | `3`                                                             | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded |
| `workhorse.imageScaler.maxProcs`                              | `2`                                                             | The maximum number of image scaling processes that may run concurrently |
| `workhorse.imageScaler.maxFileSizeBytes`                      | `250000`                                                        | The maximum file size in bytes for images to be processed by the scaler |
| `workhorse.tls.verify`                                        | `true`                                                          | When set to `true` forces NGINX Ingress to verify the TLS certificate of Workhorse. For custom CA you need to set `workhorse.tls.caSecretName` as well. Must be set to `false` for self-signed certificates. |
| `workhorse.tls.secretName`                                    | `{Release.Name}-workhorse-tls`                                  | The name of the [TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) that contains the TLS key and certificate pair. This is required when Workhorse TLS is enabled. |
| `workhorse.tls.caSecretName`                                  |                                                                 | The name of the Secret that contains the CA certificate. This **is not** a [TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets), and must have only `ca.crt` key. This is used for TLS verification by NGINX. |
| `webServer`                                                   | `puma`                                                          | Selects web server (Webservice/Puma) that would be used for request handling |
| `priorityClassName`                                           | `""`                                                            | Allow configuring pods `priorityClassName`, this is used to control pod priority in case of eviction |

## Chart configuration examples

### `extraEnv`

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

### `extraEnvFrom`

`extraEnvFrom` allows you to expose additional environment variables from other data sources in all containers in the pods.
Subsequent variables can be overridden per [deployment](#deployments-settings).

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
deployments:
  default:
    extraEnvFrom:
      CONFIG_STRING:
        configMapKeyRef:
          name: useful-config
          key: some-string
          # optional: boolean
```

### `image.pullSecrets`

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in [the Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```yaml
image:
  repository: my.webservice.repository
  pullPolicy: Always
  pullSecrets:
  - name: my-secret-name
  - name: my-secondary-secret-name
```

### `serviceAccount`

This section controls if a ServiceAccount should be created and if the default access token should be mounted in pods.

| Name                           |  Type   | Default | Description |
|:-------------------------------|:-------:|:--------|:------------|
| `annotations`                  |   Map   | `{}`    | ServiceAccount annotations. |
| `automountServiceAccountToken` | Boolean | `false` | Controls if the default ServiceAccount access token should be mounted in pods. You should not enable this unless it is required by certain sidecars to work properly (for example, Istio). |
| `create`                       | Boolean | `false` | Indicates whether or not a ServiceAccount should be created. |
| `enabled`                      | Boolean | `false` | Indicates whether or not to use a ServiceAccount. |
| `name`                         | String  |         | Name of the ServiceAccount. If not set, the full chart name is used. |

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

### `annotations`

`annotations` allows you to add annotations to the Webservice pods. For example:

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

### `strategy`

`deployment.strategy` allows you to change the deployment update strategy. It defines how the pods will be recreated when deployment is updated. When not provided, the cluster default is used.
For example, if you don't want to create extra pods when the rolling update starts and change max unavailable pods to 50%:

```yaml
deployment:
  strategy:
    rollingUpdate:
      maxSurge: 0
      maxUnavailable: 50%
```

You can also change the type of update strategy to `Recreate`, but be careful as it will kill all pods before scheduling new ones, and the web UI will be unavailable until the new pods are started. In this case, you don't need to define `rollingUpdate`, only `type`:

```yaml
deployment:
  strategy:
    type: Recreate
```

For more details, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy).

### TLS

A Webservice pod runs two containers:

- `gitlab-workhorse`
- `webservice`

#### `gitlab-workhorse`

Workhorse supports TLS for both web and metrics endpoints. This will secure the
communication between Workhorse and other components, in particular `nginx-ingress`,
`gitlab-shell`, and `gitaly`. The TLS certificate should include the Workhorse
Service host name (e.g. `RELEASE-webservice-default.default.svc`) in the Common
Name (CN) or Subject Alternate Name (SAN).

Note that [multiple deployments of Webservice](#deployments-settings) can exist,
so you need to prepare the TLS certificate for different service names. This
can be achieved by either multiple SAN or wildcard certificate.

Once the TLS certificate is generated, create a [Kubernetes TLS Secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets) for it. You also need to create
another Secret that only contains the CA certificate of the TLS certificate
with `ca.crt` key.

The TLS can be enabled for `gitlab-workhorse` container by setting `global.workhorse.tls.enabled`
to `true`. You can pass custom Secret names to `gitlab.webservice.workhorse.tls.secretName` and
`global.certificates.customCAs` accordingly.

When `gitlab.webservice.workhorse.tls.verify` is `true` (it is by default), you
also need to pass the CA certificate Secret name to `gitlab.webservice.workhorse.tls.caSecretName`.
This is necessary for self-signed certificates and custom CA. This Secret is used
by NGINX to verify the TLS certificate of Workhorse.

```yaml
global:
  workhorse:
    tls:
      enabled: true
  certificates:
    customCAs:
      - secret: gitlab-workhorse-ca
gitlab:
  webservice:
    workhorse:
      tls:
        verify: true
        # secretName: gitlab-workhorse-tls
        caSecretName: gitlab-workhorse-ca
      monitoring:
        exporter:
          enabled: true
          tls:
            enabled: true
```

TLS on the metrics endpoints of the `gitlab-workhorse` container is inherited from
`global.workhorse.tls.enabled`. Note that TLS on metrics endpoint is only available
when TLS is enabled for Workhorse. The metrics listener uses the same TLS certificate
that is specified by `gitlab.webservice.workhorse.tls.secretName`.

TLS certificates used for metrics endpoints may require additional considerations for
the included subject alternative names (SANs), particularly if using the included Prometheus
Helm chart. For more information, see [Configure Prometheus to scrape TLS-enabled endpoints](../../../installation/tools.md#configure-prometheus-to-scrape-tls-enabled-endpoints).

#### `webservice`

The primary use case for enabling TLS is to provide encryption via HTTPS
for [scraping Prometheus metrics](https://docs.gitlab.com/administration/monitoring/prometheus/gitlab_metrics/).

For Prometheus to scrape the `/metrics/` endpoint using HTTPS, additional
configuration is required for the certificate's `CommonName` attribute or
a `SubjectAlternativeName` entry. See
[Configuring Prometheus to scrape TLS-enabled endpoints](../../../installation/tools.md#configure-prometheus-to-scrape-tls-enabled-endpoints)
for those requirements.

TLS can be enabled on the `webservice` container by the settings `gitlab.webservice.tls.enabled`:

```yaml
gitlab:
  webservice:
    tls:
      enabled: true
      # secretName: gitlab-webservice-tls
```

`secretName` must point to a [Kubernetes TLS secret](https://kubernetes.io/docs/concepts/configuration/secret/#tls-secrets).
For example, to create a TLS secret with a local certificate and key:

```shell
kubectl create secret tls <secret name> --cert=path/to/puma.crt --key=path/to/puma.key
```

## Using the Community Edition of this chart

By default, the Helm charts use the Enterprise Edition of GitLab. If desired, you
can use the Community Edition instead. Learn more about the
[differences between the two](https://about.gitlab.com/install/ce-or-ee/).

In order to use the Community Edition, set `image.repository` to
`registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ce` and `workhorse.image`
to `registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ce`.

## Global settings

We share some common global settings among our charts. See the [Globals Documentation](../../globals.md)
for common configuration options, such as GitLab and Registry hostnames.

## Deployments settings

This chart has the ability to create multiple Deployment objects and their related
resources. This feature allows requests to the GitLab application to be distributed between multiple sets of Pods using path based routing.

The keys of this Map (`default` in this example) are the "name" for each. `default`
will have a Deployment, Service, HorizontalPodAutoscaler, PodDisruptionBudget, and
optional Ingress created with `RELEASE-webservice-default`.

Any property not provided will inherit from the `gitlab-webservice` chart defaults.

```yaml
deployments:
  default:
    ingress:
      path: # Does not inherit or default. Leave blank to disable Ingress.
      pathType: Prefix
      provider: nginx
      annotations:
        # inherits `ingress.anntoations`
      proxyConnectTimeout: # inherits `ingress.proxyConnectTimeout`
      proxyReadTimeout:    # inherits `ingress.proxyReadTimeout`
      proxyBodySize:       # inherits `ingress.proxyBodySize`
    deployment:
      annotations: # map
      labels: # map
      # inherits `deployment`
    pod:
      labels: # additional labels to .podLabels
      annotations: # map
        # inherit from .Values.annotations
    service:
      labels: # additional labels to .serviceLabels
      annotations: # additional annotations to .service.annotations
        # inherits `service.annotations`
    hpa:
      minReplicas: # defaults to .minReplicas
      maxReplicas: # defaults to .maxReplicas
      metrics: # optional replacement of HPA metrics definition
      # inherits `hpa`
    pdb:
      maxUnavailable: # inherits `maxUnavailable`
    resources: # `resources` for `webservice` container
      # inherits `resources`
    workhorse: # map
      # inherits `workhorse`
    extraEnv: #
      # inherits `extraEnv`
    extraEnvFrom: #
      # inherits `extraEnvFrom`
    puma: # map
      # inherits `puma`
    workerProcesses: # inherits `workerProcesses`
    shutdown:
      # inherits `shutdown`
    nodeSelector: # map
      # inherits `nodeSelector`
    tolerations: # array
      # inherits `tolerations`
```

### Deployments Ingress

Each `deployments` entry will inherit from chart-wide [Ingress settings](#ingress-settings). Any value presented here will override those provided there. Outside of `path`, all settings are identical to those.

```yaml
webservice:
  deployments:
    default:
      ingress:
        path: /
   api:
     ingress:
       path: /api
```

The `path` property is directly populated into the Ingress's `path` property, and allows one to control URI paths which are directed to each service. In the example above,
`default` acts as the catch-all path, and `api` received all traffic under `/api`

You can disable a given Deployment from having an associated Ingress resource created by setting `path` to empty. See below, where `internal-api` will never receive external traffic.

```yaml
webservice:
  deployments:
    default:
      ingress:
        path: /
   api:
     ingress:
       path: /api
   internal-api:
     ingress:
       path:
```

## Ingress settings

| Name                              |  Type   | Default                   | Description |
|:----------------------------------|:-------:|:--------------------------|:------------|
| `ingress.apiVersion`              | String  |                           | Value to use in the `apiVersion` field. |
| `ingress.annotations`             |   Map   | See [below](#annotations) | These annotations will be used for every Ingress. For example: `ingress.annotations."nginx\.ingress\.kubernetes\.io/enable-access-log"=true`. |
| `ingress.configureCertmanager`    | Boolean |                           | Toggles Ingress annotation `cert-manager.io/issuer` and `acme.cert-manager.io/http01-edit-in-place`. For more information see the [TLS requirement for GitLab Pages](../../../installation/tls.md). |
| `ingress.enabled`                 | Boolean | `false`                   | Setting that controls whether to create Ingress objects for services that support them. When `false`, the `global.ingress.enabled` setting value is used. |
| `ingress.proxyBodySize`           | String  | `512m`                    | [See Below](#proxybodysize). |
| `ingress.serviceUpstream`         | Boolean | `true`                    | [See Below](#serviceupstream). |
| `ingress.tls.enabled`             | Boolean | `true`                    | When set to `false`, you disable TLS for GitLab Webservice. This is mainly useful for cases in which you cannot use TLS termination at Ingress-level, like when you have a TLS-terminating proxy before the Ingress Controller. |
| `ingress.tls.secretName`          | String  | (empty)                   | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the GitLab URL. When not set, the `global.ingress.tls.secretName` value is used instead. |
| `ingress.tls.smardcardSecretName` | String  | (empty)                   | The name of the Kubernetes TLS SEcret that contains a valid certificate and key for the GitLab smartcard URL if enabled. When not set, the `global.ingress.tls.secretName` value is used instead. |
| `ingress.tls.useGeoClass`         | Boolean | `false`                   | Override the IngressClass with the Geo Ingress class (`global.geo.ingressClass`). Required for primary Geo sites. |

### annotations

`annotations` is used to set annotations on the Webservice Ingress.

### `serviceUpstream`

This helps balance traffic to the Webservice pods more evenly by telling NGINX to directly
contact the Service itself as the upstream. For more information, see the
[NGINX docs](https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/annotations.md#service-upstream).

To override this, set:

```yaml
gitlab:
  webservice:
    ingress:
      serviceUpstream: "false"
```

### `proxyBodySize`

`proxyBodySize` is used to set the NGINX proxy maximum body size. This is commonly
required to allow a larger Docker image than the default.
It is equivalent to the `nginx['client_max_body_size']` configuration in a
[Linux package installation](https://docs.gitlab.com/omnibus/settings/nginx/#use-an-existing-passenger-and-nginx-installation).
As an alternative option,
you can set the body size with either of the following two parameters too:

- `gitlab.webservice.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"`
- `global.ingress.annotations."nginx\.ingress\.kubernetes\.io/proxy-body-size"`

### Extra Ingress

An extra Ingress can be deployed by setting `extraIngress.enabled=true`. The Ingress
is named as the default Ingress with the `-extra` suffix and supports the same
settings as the default Ingress.

## Resources

### Memory requests/limits

Each pod spawns an amount of workers equal to `workerProcesses`, who each use
some baseline amount of memory. We recommend:

- A minimum of 1.25GB per worker (`requests.memory`)
- A maximum of 1.5GB per worker, plus 1GB for the primary (`limits.memory`)

Note that required resources are dependent on the workload generated by users
and may change in the future based on changes or upgrades in the GitLab application.

Default:

```yaml
workerProcesses: 2
resources:
  requests:
    memory: 2.5G # = 2 * 1.25G
# limits:
#   memory: 4G   # = (2 * 1.5G) + 950M
```

With 4 workers configured:

```yaml
workerProcesses: 4
resources:
  requests:
    memory: 5G   # = 4 * 1.25G
# limits:
#   memory: 7G   # = (4 * 1.5G) + 950M
```

## External Services

### Redis

The Redis documentation has been consolidated in the [globals](../../globals.md#configure-redis-settings)
page. Please consult this page for the latest Redis configuration options.

### PostgreSQL

The PostgreSQL documentation has been consolidated in the [globals](../../globals.md#configure-postgresql-settings)
page. Please consult this page for the latest PostgreSQL configuration options.

### Gitaly

Gitaly is configured by [global settings](../../globals.md). Please see the
[Gitaly configuration documentation](../../globals.md#configure-gitaly-settings).

### MinIO

```yaml
minio:
  serviceName: 'minio-svc'
  port: 9000
```

| Name          |  Type   | Default     | Description |
|:--------------|:-------:|:------------|:------------|
| `port`        | Integer | `9000`      | Port number to reach the MinIO `Service` on. |
| `serviceName` | String  | `minio-svc` | Name of the `Service` that is exposed by the MinIO pod. |

### Registry

```yaml
registry:
  host: registry.example.com
  port: 443
  api:
    protocol: http
    host: registry.example.com
    serviceName: registry
    port: 5000
  tokenIssuer: gitlab-issuer
  certificate:
    secret: gitlab-registry
    key: registry-auth.key
```

| Name                 |  Type   | Default         | Description |
|:---------------------|:-------:|:----------------|:------------|
| `api.host`           | String  |                 | The hostname of the Registry server to use. This can be omitted in lieu of `api.serviceName`. |
| `api.port`           | Integer | `5000`          | The port on which to connect to the Registry API. |
| `api.protocol`       | String  |                 | The protocol Webservice should use to reach the Registry API. |
| `api.serviceName`    | String  | `registry`      | The name of the `service` which is operating the Registry server. If this is present, and `api.host` is not, the chart will template the hostname of the service (and current `.Release.Name`) in place of the `api.host` value. This is convenient when using Registry as a part of the overall GitLab chart. |
| `certificate.key`    | String  |                 | The name of the `key` in the `Secret` which houses the certificate bundle that will be provided to the [registry](https://hub.docker.com/_/registry/) container as `auth.token.rootcertbundle`. |
| `certificate.secret` | String  |                 | The name of the [Kubernetes Secret](https://kubernetes.io/docs/concepts/configuration/secret/) that houses the certificate bundle to be used to verify the tokens created by the GitLab instance(s). |
| `host`               | String  |                 | The external hostname to use for providing Docker commands to users in the GitLab UI. Falls back to the value set in the `registry.hostname` template. Which determines the registry hostname based on the values set in `global.hosts`. See the [Globals Documentation](../../globals.md) for more information. |
| `port`               | Integer |                 | The external port used in the hostname. Using port `80` or `443` will result in the URLs being formed with `http`/`https`. Other ports will all use `http` and append the port to the end of hostname, for example `http://registry.example.com:8443`. |
| `tokenIssuer`        | String  | `gitlab-issuer` | The name of the auth token issuer. This must match the name used in the Registry's configuration, as it incorporated into the token when it is sent. The default of `gitlab-issuer` is the same default we use in the Registry chart. |

## Chart settings

The following values are used to configure the Webservice Pods.

| Name              |  Type   | Default | Description |
|:------------------|:-------:|:--------|:------------|
| `workerProcesses` | Integer | `2`     | The number of Webservice workers to run per pod. You must have at least `2` workers available in your cluster in order for GitLab to function properly. Note that increasing the `workerProcesses` will increase the memory required by approximately `400MB` per worker, so you should update the pod `resources` accordingly. |
| `minReplicas`     | Integer | `2`     | Minimum number of replicas |
| `maxReplicas`     | Integer | `10`    | Maximum number of replicas |
| `maxUnavailable`  | Integer | `1`     | Limit of maximum number of Pods to be unavailable |

### Metrics

Metrics can be enabled with the `metrics.enabled` value and use the GitLab
monitoring exporter to expose a metrics port. Pods are either given Prometheus
annotations or if `metrics.serviceMonitor.enabled` is `true` a Prometheus
Operator ServiceMonitor is created. Metrics can alternativly be scraped from
the `/-/metrics` endpoint, but this requires [GitLab Prometheus metrics](https://docs.gitlab.com/administration/monitoring/prometheus/gitlab_metrics/)
to be enabled in the Admin area. The GitLab Workhorse metrics can also be
exposed via `workhorse.metrics.enabled` but these can't be collected using the
Prometheus annotations so either require
`workhorse.metrics.serviceMonitor.enabled` to be `true` or external Prometheus
configuration.

### GitLab Shell

GitLab Shell uses an Auth Token in its communication with Webservice. Share the token
with GitLab Shell and Webservice using a shared Secret.

```yaml
shell:
  authToken:
    secret: gitlab-shell-secret
    key: secret
  port:
```

| Name               |  Type   | Default | Description |
|:-------------------|:-------:|:--------|:------------|
| `authToken.key`    | String  |         | Defines the name of the key in the secret (below) that contains the authToken. |
| `authToken.secret` | String  |         | Defines the name of the Kubernetes `Secret` to pull from. |
| `port`             | Integer | `22`    | The port number to use in the generation of SSH URLs within the GitLab UI. Controlled by `global.shell.port`. |

### WebServer options

Current version of chart supports Puma web server.

Puma unique options:

| Name                   |  Type   | Default | Description |
|:-----------------------|:-------:|:--------|:------------|
| `puma.workerMaxMemory` | Integer |         | The maximum memory (in megabytes) for the Puma worker killer |
| `puma.threads.min`     | Integer | `4`     | The minimum amount of Puma threads |
| `puma.threads.max`     | Integer | `4`     | The maximum amount of Puma threads |

## Configuring the `networkpolicy`

This section controls the
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
This configuration is optional and is used to limit Egress and Ingress of the
Pods to specific endpoints.

| Name              |  Type   | Default | Description |
|:------------------|:-------:|:--------|:------------|
| `enabled`         | Boolean | `false` | This setting enables the `NetworkPolicy` |
| `ingress.enabled` | Boolean | `false` | When set to `true`, the `Ingress` network policy will be activated. This will block all Ingress connections unless rules are specified. |
| `ingress.rules`   |  Array  | `[]`    | Rules for the Ingress policy, for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |
| `egress.enabled`  | Boolean | `false` | When set to `true`, the `Egress` network policy will be activated. This will block all egress connections unless rules are specified. |
| `egress.rules`    |  Array  | `[]`    | Rules for the egress policy, these for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |

### Example Network Policy

The webservice service requires Ingress connections for the Prometheus
exporter if enabled, traffic coming from the NGINX Ingress and several GitLab pods.
Typically it requires Egress connections to various places.
This examples adds the following network policy:

- Allows Ingress requests:
  - From the pods `gitaly`, `gitlab-pages`, `gitlab-shell`, `kas` , `mailroom` and `nginx-ingress` to port `8181`
  - From the `Prometheus` pod to port `8080`, `8083` and `9229`
- Allows Egress requests:
  - To the `gitaly` pod to port `8075`
  - To the `kas` pod to port `8153`
  - To `kube-dns` to port `53`
  - To the `registry` pod to port `5000`
  - To external database `172.16.0.10/32` to port `5432`
  - To external Redis `172.16.0.11/32` to port `6379`
  - To the internet `0.0.0.0/0` to port `443`
  - To endpoints like AWS VPC endpoint for S3 or STS `172.16.1.0/24` to port `443`

_Note the example provided is only an example and may not be complete_

_Note the Webservice requires outbound connectivity to the public internet
for images on [external object storage](../../../advanced/external-object-storage)_

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
          - podSelector:
              matchLabels:
                app: gitaly
        ports:
          - port: 8181
      - from:
          - podSelector:
              matchLabels:
                app: gitlab-pages
        ports:
          - port: 8181
      - from:
          - podSelector:
              matchLabels:
                app: gitlab-shell
        ports:
          - port: 8181
      - from:
          - podSelector:
              matchLabels:
                app: kas
        ports:
          - port: 8181
      - from:
          - podSelector:
              matchLabels:
                app: mailroom
        ports:
          - port: 8181
      - from:
          - namespaceSelector:
              matchLabels:
                kubernetes.io/metadata.name: nginx-ingress
            podSelector:
              matchLabels:
                app: nginx-ingress
                component: controller
        ports:
          - port: 8181
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
          - port: 9229
          - port: 8080
          - port: 8083
  egress:
    enabled: true
    rules:
      - to:
          - podSelector:
              matchLabels:
                app: gitaly
        ports:
          - port: 8075
      - to:
          - podSelector:
              matchLabels:
                app: kas
        ports:
          - port: 8153
      - to:
          - ipBlock:
              cidr: 0.0.0.0/0
              except:
                - 10.0.0.0/8
        ports:
          - port: 443
      - to:
          - ipBlock:
              cidr: 172.16.0.10/32
        ports:
          - port: 5432
      - to:
          - ipBlock:
              cidr: 172.16.0.11/32
        ports:
          - port: 6379
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
```

### `LoadBalancer` service

If the `service.type` is set to `LoadBalancer`, you can optionally specify `service.loadBalancerIP` to create
the `LoadBalancer` with a user-specified IP (if your cloud provider supports it).

When the `service.type` is set to `LoadBalancer` you must also set `service.loadBalancerSourceRanges` to restrict
the CIDR ranges that can access the `LoadBalancer` (if your cloud provider supports it).
This is currently required due to an issue where [metric ports are exposed](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2500).

Additional information about the `LoadBalancer` service type can be found in
[the Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/#loadbalancer)

```yaml
service:
  type: LoadBalancer
  loadBalancerIP: 1.2.3.4
  loadBalancerSourceRanges:
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
| `minReplicaCount`               | Integer | `minReplicas`                   | Minimum number of replicas KEDA will scale the resource down to. |
| `maxReplicaCount`               | Integer | `maxReplicas`                   | Maximum number of replicas KEDA will scale the resource up to. |
| `fallback`                      |   Map   |                                 | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback) |
| `hpaName`                       | String  | `keda-hpa-{scaled-object-name}` | The name of the HPA resource KEDA will create. |
| `restoreToOriginalReplicaCount` | Boolean |                                 | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted |
| `behavior`                      |   Map   | `hpa.behavior`                  | The specifications for up- and downscaling behavior. |
| `triggers`                      |  Array  |                                 | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory` |
