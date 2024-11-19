---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the GitLab Pages chart

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

The `gitlab-pages` subchart provides a daemon for serving static websites from
GitLab projects.

## Requirements

This chart depends on access to the Workhorse services, either as part of the
complete GitLab chart or provided as an external service reachable from the Kubernetes
cluster this chart is deployed onto.

## Configuration

The `gitlab-pages` chart is configured as follows:
[Global settings](#global-settings) and [Chart settings](#chart-settings).

## Global Settings

We share some common global settings among our charts. See the
[Globals Documentation](../../globals.md#configure-gitlab-pages) for details.

## Chart settings

The tables in following two sections contains all the possible chart
configurations that can be supplied to the `helm install` command using the
`--set` flags.

### General settings

| Parameter                                                | Default                                                 | Description                                                                                                                                                                                        |
|----------------------------------------------------------|---------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `affinity`                             | `{}`                                                       | [Affinity rules](../index.md#affinity) for pod assignment                                                                                                                                                     |
| `annotations`                                            |                                                         | Pod annotations                                                                                                                                                                                    |
| `common.labels`                                          | `{}`                                                    | Supplemental labels that are applied to all objects created by this chart.                                                                                                                         |
| `deployment.strategy`                                    | `{}`                                                    | Allows one to configure the update strategy used by the deployment. When not provided, the cluster default is used.                                                                                |
| `extraEnv`                                               |                                                         | List of extra environment variables to expose                                                                                                                                                      |
| `extraEnvFrom`                                           |                                                         | List of extra environment variables from other data source to expose                                                                                                                               |
| `hpa.behavior`                                           | `{scaleDown: {stabilizationWindowSeconds: 300 }}`       | Behavior contains the specifications for up- and downscaling behavior (requires `autoscaling/v2beta2` or higher)                                                                                   |
| `hpa.customMetrics`                                      | `[]`                                                    | Custom metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) |
| `hpa.cpu.targetType`                                     | `AverageValue`                                          | Set the autoscaling CPU target type, must be either `Utilization` or `AverageValue`                                                                                                                |
| `hpa.cpu.targetAverageValue`                             | `100m`                                                  | Set the autoscaling CPU target value                                                                                                                                                               |
| `hpa.cpu.targetAverageUtilization`                       |                                                         | Set the autoscaling CPU target utilization                                                                                                                                                         |
| `hpa.memory.targetType`                                  |                                                         | Set the autoscaling memory target type, must be either `Utilization` or `AverageValue`                                                                                                             |
| `hpa.memory.targetAverageValue`                          |                                                         | Set the autoscaling memory target value                                                                                                                                                            |
| `hpa.memory.targetAverageUtilization`                    |                                                         | Set the autoscaling memory target utilization                                                                                                                                                      |
| `hpa.minReplicas`                                        | `1`                                                     | Minimum number of replicas                                                                                                                                                                         |
| `hpa.maxReplicas`                                        | `10`                                                    | Maximum number of replicas                                                                                                                                                                         |
| `hpa.targetAverageValue`                                 |                                                         | **DEPRECATED** Set the autoscaling CPU target value                                                                                                                                                |
| `image.pullPolicy`                                       | `IfNotPresent`                                          | GitLab image pull policy                                                                                                                                                                           |
| `image.pullSecrets`                                      |                                                         | Secrets for the image repository                                                                                                                                                                   |
| `image.repository`                                       | `registry.gitlab.com/gitlab-org/build/cng/gitlab-pages` | GitLab Pages image repository                                                                                                                                                                      |
| `image.tag`                                              |                                                         | image tag                                                                                                                                                                                          |
| `init.image.repository`                                  |                                                         | initContainer image                                                                                                                                                                                |
| `init.image.tag`                                         |                                                         | initContainer image tag                                                                                                                                                                            |
| `init.containerSecurityContext`                          |                                                         | initContainer specific [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core)                                                             |
| `init.containerSecurityContext.allowPrivilegeEscalation` | `false`                                                 | initContainer specific: Controls whether a process can gain more privileges than its parent process                                                                                                |
| `init.containerSecurityContext.runAsNonRoot`             | `true`                                                  | initContainer specific: Controls whether the container runs with a non-root user                                                                                                                   |
| `init.containerSecurityContext.capabilities.drop`        | `[ "ALL" ]`                                             | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container                                                                  |
| `keda.enabled`                                           | `false`                                                 | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers`                                                                                                                 |
| `keda.pollingInterval`                                   | `30`                                                    | The interval to check each trigger on                                                                                                                                                              |
| `keda.cooldownPeriod`                                    | `300`                                                   | The period to wait after the last trigger reported active before scaling the resource back to 0                                                                                                    |
| `keda.minReplicaCount`                                   |                                                         | Minimum number of replicas KEDA will scale the resource down to, defaults to `hpa.minReplicas`                                                                                                     |
| `keda.maxReplicaCount`                                   |                                                         | Maximum number of replicas KEDA will scale the resource up to, defaults to `hpa.maxReplicas`                                                                                                       |
| `keda.fallback`                                          |                                                         | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback)                                                                             |
| `keda.hpaName`                                           |                                                         | The name of the HPA resource KEDA will create, defaults to `keda-hpa-{scaled-object-name}`                                                                                                         |
| `keda.restoreToOriginalReplicaCount`                     |                                                         | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted                                                                         |
| `keda.behavior`                                          |                                                         | The specifications for up- and downscaling behavior, defaults to `hpa.behavior`                                                                                                                    |
| `keda.triggers`                                          |                                                         | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory`                                                                         |
| `metrics.enabled`                                        | `true`                                                  | If a metrics endpoint should be made available for scraping                                                                                                                                        |
| `metrics.port`                                           | `9235`                                                  | Metrics endpoint port                                                                                                                                                                              |
| `metrics.path`                                           | `/metrics`                                              | Metrics endpoint path                                                                                                                                                                              |
| `metrics.serviceMonitor.enabled`                         | `false`                                                 | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping, note that enabling this removes the `prometheus.io` scrape annotations                         |
| `metrics.serviceMonitor.additionalLabels`                | `{}`                                                    | Additional labels to add to the ServiceMonitor                                                                                                                                                     |
| `metrics.serviceMonitor.endpointConfig`                  | `{}`                                                    | Additional endpoint configuration for the ServiceMonitor                                                                                                                                           |
| `metrics.annotations`                                    |                                                         | **DEPRECATED** Set explicit metrics annotations. Replaced by template content.                                                                                                                     |
| `metrics.tls.enabled`                                    | `false`                                                 | TLS enabled for the metrics endpoint                                                                                                                                                               |
| `metrics.tls.secretName`                                 | `{Release.Name}-pages-metrics-tls`                      | Secret for the metrics endpoint TLS cert and key                                                                                                                                                   |
| `priorityClassName`                          |                                                         | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods.                                                                               |
| `podLabels`                                              |                                                         | Supplemental Pod labels. Will not be used for selectors.                                                                                                                                           |
| `resources.requests.cpu`                                 | `900m`                                                  | GitLab Pages minimum CPU                                                                                                                                                                           |
| `resources.requests.memory`                              | `2G`                                                    | GitLab Pages minimum memory                                                                                                                                                                        |
| `securityContext.fsGroup`                                | `1000`                                                  | Group ID under which the pod should be started                                                                                                                                                     |
| `securityContext.runAsUser`                              | `1000`                                                  | User ID under which the pod should be started                                                                                                                                                      |
| `securityContext.fsGroupChangePolicy`                    |                                                         | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23)                                                                                                              |
| `securityContext.seccompProfile.type`                    | `RuntimeDefault`                                        | Seccomp profile to use                                                                                                                                                                             |
| `containerSecurityContext`                               |                                                         | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started                            |
| `containerSecurityContext.runAsUser`                     | `1000`                                                  | Allow to overwrite the specific security context user ID under which the container is started                                                                                                             |
| `containerSecurityContext.allowPrivilegeEscalation`      | `false`                                                 | Controls whether a process of the container can gain more privileges than its parent process                                                                                                       |
| `containerSecurityContext.runAsNonRoot`                  | `true`                                                  | Controls whether the container runs with a non-root user                                                                                                                                           |
| `containerSecurityContext.capabilities.drop`             | `[ "ALL" ]`                                             | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container                                                                                   |
| `service.externalPort`                                   | `8090`                                                  | GitLab Pages exposed port                                                                                                                                                                          |
| `service.internalPort`                                   | `8090`                                                  | GitLab Pages internal port                                                                                                                                                                         |
| `service.name`                                           | `gitlab-pages`                                          | GitLab Pages service name                                                                                                                                                                          |
| `service.annotations`                                    |                                                         | Annotations for all pages services.                                                                                                                                                                |
| `service.primary.annotations`                            |                                                         | Annotations for the primary service only.                                                                                                                                                          |
| `service.metrics.annotations`                            |                                                         | Annotations for the metrics service only.                                                                                                                                                          |
| `service.customDomains.annotations`                      |                                                         | Annotations for the custom domains service only.                                                                                                                                                   |
| `service.customDomains.type`                             | `LoadBalancer`                                          | Type of service created for handling custom domains                                                                                                                                                |
| `service.customDomains.internalHttpsPort`                | `8091`                                                  | Port where Pages daemon listens for HTTPS requests                                                                                                                                                 |
| `service.customDomains.internalHttpsPort`                | `8091`                                                  | Port where Pages daemon listens for HTTPS requests                                                                                                                                                 |
| `service.customDomains.nodePort.http`                    |                                                         | Node Port to be opened for HTTP connections. Valid only if `service.customDomains.type` is `NodePort`                                                                                              |
| `service.customDomains.nodePort.https`                   |                                                         | Node Port to be opened for HTTPS connections. Valid only if `service.customDomains.type` is `NodePort`                                                                                             |
| `service.sessionAffinity`                                | `None`                                                  | Type of the session affinity. Must be either `ClientIP` or `None` (this only makes sense for traffic originating from within the cluster)                                                          |
| `service.sessionAffinityConfig`                          |                                                         | Session affinity config. If `service.sessionAffinity` == `ClientIP` the default session sticky time is 3 hours (10800)                                                                             |
| `serviceAccount.annotations`              | `{}`                                                       | ServiceAccount annotations                                                                                                                                                                         |
| `serviceAccount.automountServiceAccountToken` | `false`                                                | Indicates whether or not the default ServiceAccount access token should be mounted in pods                                                                                                         |
| `serviceAccount.create`                   | `false`                                                    | Indicates whether or not a ServiceAccount should be created                                                                                                                                        |
| `serviceAccount.enabled`                  | `false`                                                    | Indicates whether or not to use a ServiceAccount                                                                                                                                                   |
| `serviceAccount.name`                     |                                                            | Name of the ServiceAccount. If not set, the full chart name is used                                                                                                                           |
| `serviceLabels`                                          | `{}`                                                    | Supplemental service labels                                                                                                                                                                        |
| `tolerations`                                            | `[]`                                                    | Toleration labels for pod assignment                                                                                                                                                               |

### Pages specific settings

| Parameter                   | Default  | Description                                                                                                                                                                                                                                  |
| --------------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `artifactsServerTimeout`    | `10`     | Timeout (in seconds) for a proxied request to the artifacts server                                                                                                                                                                           |
| `artifactsServerUrl`        |          | API URL to proxy artifact requests to                                                                                                                                                                                                        |
| `extraVolumeMounts`         |          | List of extra volumes mounts to add                                                                                                                                                                                                          |
| `extraVolumes`              |          | List of extra volumes to create                                                                                                                                                                                                              |
| `gitlabCache.cleanup`       | int      | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings)                                                                                                                                     |
| `gitlabCache.expiry`        | int      | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings)                                                                                                                                     |
| `gitlabCache.refresh`       | int      | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings)                                                                                                                                     |
| `gitlabClientHttpTimeout`   |          | GitLab API HTTP client connection timeout in seconds                                                                                                                                                                                         |
| `gitlabClientJwtExpiry`     |          | JWT Token expiry time in seconds                                                                                                                                                                                                             |
| `gitlabRetrieval.interval`  | int      | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings)                                                                                                                                     |
| `gitlabRetrieval.retries`   | int      | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings)                                                                                                                                     |
| `gitlabRetrieval.timeout`   | int      | See: [Pages Global Settings](https://docs.gitlab.com/ee/administration/pages/index.html#global-settings)                                                                                                                                     |
| `gitlabServer`              |          | GitLab server FQDN                                                                                                                                                                                                                           |
| `headers`                   | `[]`     | Specify any additional http headers that should be sent to the client with each response. Multiple headers can be given as an array, header and value as one string, for example `['my-header: myvalue', 'my-other-header: my-other-value']` |
| `insecureCiphers`           | `false`  | Use default list of cipher suites, may contain insecure ones like 3DES and RC4                                                                                                                                                               |
| `internalGitlabServer`      |          | Internal GitLab server used for API requests                                                                                                                                                                                                 |
| `logFormat`                 | `json`   | Log output format                                                                                                                                                                                                                            |
| `logVerbose`                | `false`  | Verbose logging                                                                                                                                                                                                                              |
| `maxConnections`            |          | Limit on the number of concurrent connections to the HTTP, HTTPS or proxy listeners                                                                                                                                                          |
| `maxURILength`              |          | Limit the length of URI, 0 for unlimited.                                                                                                                                                                                                    |
| `propagateCorrelationId`    |          | Reuse existing Correlation-ID from the incoming request header `X-Request-ID` if present                                                                                                                                                     |
| `redirectHttp`              | `false`  | Redirect pages from HTTP to HTTPS                                                                                                                                                                                                            |
| `sentry.enabled`            | `false`  | Enable Sentry reporting                                                                                                                                                                                                                      |
| `sentry.dsn`                |          | The address for sending Sentry crash reporting to                                                                                                                                                                                            |
| `sentry.environment`        |          | The environment for Sentry crash reporting                                                                                                                                                                                                   |
| `serverShutdowntimeout`     | `30s`    | GitLab Pages server shutdown timeout in seconds                                                                                                                                                                                              |
| `statusUri`                 |          | The URL path for a status page                                                                                                                                                                                                               |
| `tls.minVersion`            |          | Specifies the minimum SSL/TLS version                                                                                                                                                                                                        |
| `tls.maxVersion`            |          | Specifies the maximum SSL/TLS version                                                                                                                                                                                                        |
| `useHTTPProxy`              | `false`  | Use this option when GitLab Pages is behind a Reverse Proxy.                                                                                                                                                                                 |
| `useProxyV2`                | `false`  | Force HTTPS request to utilize the PROXYv2 protocol.                                                                                                                                                                                         |
| `zipCache.cleanup`          | int      | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration)                                                                                                   |
| `zipCache.expiration`       | int      | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration)                                                                                                   |
| `zipCache.refresh`          | int      | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration)                                                                                                   |
| `zipOpenTimeout`            | int      | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration)                                                                                                   |
| `zipHTTPClientTimeout`      | int      | See: [Zip Serving and Cache Configuration](https://docs.gitlab.com/ee/administration/pages/index.html#zip-serving-and-cache-configuration)                                                                                                   |
| `rateLimitSourceIP`         |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits).                                                                                                                                     |
| `rateLimitSourceIPBurst`    |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits)                                                                                                                                      |
| `rateLimitDomain`           |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits).                                                                                                                                     |
| `rateLimitDomainBurst`      |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits)                                                                                                                                      |
| `rateLimitTLSSourceIP`      |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits).                                                                                                                                     |
| `rateLimitTLSSourceIPBurst` |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits)                                                                                                                                      |
| `rateLimitTLSDomain`        |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits).                                                                                                                                     |
| `rateLimitTLSDomainBurst`   |          | See: [GitLab Pages rate-limits](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits)                                                                                                                                      |
| `rateLimitSubnetsAllowList` |          | See: [GitLab Pages rate-limits](#rate-limits)                                                                                                                                      |
| `serverReadTimeout`         | `5s`     | See: [GitLab Pages global settings](https://docs.gitlab.com/ee/administration/pages/#global-settings)                                                                                                                                        |
| `serverReadHeaderTimeout`   | `1s`     | See: [GitLab Pages global settings](https://docs.gitlab.com/ee/administration/pages/#global-settings)                                                                                                                                        |
| `serverWriteTimeout`        | `5m`     | See: [GitLab Pages global settings](https://docs.gitlab.com/ee/administration/pages/#global-settings)                                                                                                                                        |
| `serverKeepAlive`           | `15s`    | See: [GitLab Pages global settings](https://docs.gitlab.com/ee/administration/pages/#global-settings)                                                                                                                                        |
| `authTimeout`               | `5s`     | See: [GitLab Pages global settings](https://docs.gitlab.com/ee/administration/pages/#global-settings)                                                                                                                                        |
| `authCookieSessionTimeout`  | `10m`    | See: [GitLab Pages global settings](https://docs.gitlab.com/ee/administration/pages/#global-settings)                                                                                                                                        |

### Configuring the `ingress`

This section controls the GitLab Pages Ingress.

| Name                   |  Type   | Default | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| :--------------------- | :-----: | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `apiVersion`           | String  |         | Value to use in the `apiVersion` field.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| `annotations`          | String  |         | This field is an exact match to the standard `annotations` for [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `configureCertmanager` | Boolean | `false` | Toggles Ingress annotation `cert-manager.io/issuer` and `acme.cert-manager.io/http01-edit-in-place`. The acquisition of a TLS certificate for GitLab Pages via cert-manager is disabled because a wildcard certificate acquisition requires a cert-manager Issuer with a [DNS01 solver](https://cert-manager.io/docs/configuration/acme/dns01/), and the Issuer deployed by this chart only provides a [HTTP01 solver](https://cert-manager.io/docs/configuration/acme/http01/). For more information see the [TLS requirement for GitLab Pages](../../../installation/tls.md). |
| `enabled`              | Boolean |         | Setting that controls whether to create Ingress objects for services that support them. When not set, the `global.ingress.enabled` setting is used.                                                                                                                                                                                                                                                                                                                                                                                                                             |
| `tls.enabled`          | Boolean |         | When set to `false`, you disable TLS for the Pages subchart. This is mainly useful for cases in which you cannot use TLS termination at `ingress-level`, like when you have a TLS-terminating proxy before the Ingress Controller.                                                                                                                                                                                                                                                                                                                                              |
| `tls.secretName`       | String  |         | The name of the Kubernetes TLS Secret that contains a valid certificate and key for the pages URL. When not set, the `global.ingress.tls.secretName` is used instead. Defaults to not being set.                                                                                                                                                                                                                                                                                                                                                                                |

## Chart configuration examples

### extraVolumes

`extraVolumes` allows you to configure extra volumes chart-wide.

Below is an example use of `extraVolumes`:

```yaml
extraVolumes: |
  - name: example-volume
    persistentVolumeClaim:
      claimName: example-pvc
```

### extraVolumeMounts

`extraVolumeMounts` allows you to configure extra volumeMounts on all containers chart-wide.

Below is an example use of `extraVolumeMounts`:

```yaml
extraVolumeMounts: |
  - name: example-volume
    mountPath: /etc/example
```

### Configuring the `networkpolicy`

This section controls the
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
This configuration is optional and is used to limit Egress and Ingress of the
Pods to specific endpoints.

| Name              |  Type   | Default | Description                                                                                                                                                                     |
| :---------------- | :-----: | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `enabled`         | Boolean | `false` | This setting enables the `NetworkPolicy`                                                                                                                                        |
| `ingress.enabled` | Boolean | `false` | When set to `true`, the `Ingress` network policy will be activated. This will block all Ingress connections unless rules are specified.                                         |
| `ingress.rules`   |  Array  | `[]`    | Rules for the Ingress policy, for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below      |
| `egress.enabled`  | Boolean | `false` | When set to `true`, the `Egress` network policy will be activated. This will block all egress connections unless rules are specified.                                           |
| `egress.rules`    |  Array  | `[]`    | Rules for the egress policy, these for details see <https://kubernetes.io/docs/concepts/services-networking/network-policies/#the-networkpolicy-resource> and the example below |

### Example Network Policy

The `gitlab-pages` service requires Ingress connections for port 80 and 443 and
Egress connections to various to default workhorse port 8181. This examples adds
the following network policy:

- All Ingress requests from the network on TCP `0.0.0.0/0` port 80 and 443 are allowed
- All Egress requests to the network on UDP `10.0.0.0/8` port 53 are allowed for DNS
- All Egress requests to the network on TCP `10.0.0.0/8` port 8181 are allowed for Workhorse

_Note the example provided is only an example and may not be complete_

```yaml
networkpolicy:
  enabled: true
  ingress:
    enabled: true
    rules:
      - to:
        - ipBlock:
            cidr: 0.0.0.0/0
        ports:
          - port: 80
            protocol: TCP
          - port: 443
            protocol: TCP
  egress:
    enabled: true
    rules:
      - to:
        - ipBlock:
            cidr: 10.0.0.0/8
        ports:
          - port: 8181
            protocol: TCP
          - port: 53
            protocol: UDP
```

### TLS access to GitLab Pages

To have TLS access to the GitLab Pages feature you must:

1. Create a dedicated wildcard certificate for your GitLab Pages domain in this format:
   `*.pages.<yourdomain>`.

1. Create the secret in Kubernetes:

   ```shell
   kubectl create secret tls tls-star-pages-<mysecret> --cert=<path/to/fullchain.pem> --key=<path/to/privkey.pem>
   ```

1. Configure GitLab Pages to use this secret:

   ```yaml
   gitlab:
     gitlab-pages:
       ingress:
         tls:
           secretName: tls-star-pages-<mysecret>
   ```

1. Create a DNS entry in your DNS provider with the name `*.pages.<yourdomaindomain>`
   pointing to your LoadBalancer.

### Pages domain without wildcard DNS

> - [Introduced](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5570) as a [beta](https://docs.gitlab.com/ee/policy/experiment-beta-support.html#beta) in GitLab 17.2.
> - [Generally available](https://gitlab.com/gitlab-org/gitlab/-/issues/483365) in GitLab 17.4.

WARNING:
GitLab Pages supports only one URL scheme at a time: Either with wildcard DNS, or without wildcard DNS. If you enable `namespaceInPath`, existing GitLab Pages websites are accessible only on domains without wildcard DNS.

1. Enable `namespaceInPath` in the global Pages settings.

   ```yaml
   global:
     pages:
       namespaceInPath: true
   ```

1. Create a DNS entry in your DNS provider with the name `pages.<yourdomaindomain>` pointing to your LoadBalancer.

#### TLS access to GitLab Pages domain without wildcard DNS

1. Create a certificate for your GitLab Pages domain in this format: `pages.<yourdomain>`.
1. Create the secret in Kubernetes:

   ```shell
   kubectl create secret tls tls-star-pages-<mysecret> --cert=<path/to/fullchain.pem> --key=<path/to/privkey.pem>
   ```

1. Configure GitLab Pages to use this secret:

   ```yaml
   gitlab:
     gitlab-pages:
       ingress:
         tls:
           secretName: tls-star-pages-<mysecret>
   ```

#### Configure access control

1. Enable `accessControl` in the global pages settings.

   ```yaml
   global:
     pages:
       accessControl: true
   ```

1. Optional. If [TLS access](#tls-access-to-gitlab-pages-domain-without-wildcard-dns) is configured, update the redirect URI in the GitLab Pages
   [System OAuth application](https://docs.gitlab.com/ee/integration/oauth_provider.html#create-an-instance-wide-application)
   to use the HTTPS protocol.

WARNING:
GitLab Pages does not update the OAuth application, and the default `authRedirectUri` is updated to `https://pages.<yourdomaindomain>/projects/auth`. While accessing a private Pages site, if you encounter an error 'The redirect URI included is not valid', update the redirect URI in the GitLab Pages [System OAuth application](https://docs.gitlab.com/ee/integration/oauth_provider.html#create-an-instance-wide-application) to `https://pages.<yourdomaindomain>/projects/auth`.

### Rate limits

You can enforce rate limits to help minimize the risk of a Denial of Service (DoS) attack. Detailed [rate limits documentation](https://docs.gitlab.com/ee/administration/pages/index.html#rate-limits) is available.

To allow certain IP ranges (subnets) to bypass all rate limits:

- `rateLimitSubnetsAllowList`: Sets the allow list with the IP ranges (subnets) that should bypass all rate limits.

#### Configure rate limits subnets allow list

Set the allow list with the IP ranges (subnets) in `charts/gitlab/charts/gitlab-pages/values.yaml`:

```yaml
gitlab:
  gitlab-pages:
    rateLimitSubnetsAllowList:
     - "1.2.3.4/24"
     - "2001:db8::1/32"
```

### Configuring KEDA

This `keda` section enables the installation of [KEDA](https://keda.sh/) `ScaledObjects` instead of regular `HorizontalPodAutoscalers`.
This configuration is optional and can be used when there is a need for autoscaling based on custom or external metrics.

Most settings default to the values set in the `hpa` section where applicable.

If the following are true, CPU and memory triggers are added automatically based on the CPU and memory thresholds set in the `hpa` section:

- `triggers` is not set.
- The corresponding `request.cpu.request` or `request.memory.request` setting is also set to a non-zero value.

If no triggers are set, the `ScaledObject` is not created.

Refer to the [KEDA documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/) for more details about those settings.

| Name                            | Type    | Default | Description                                                                                                                                                                     |
| :----------------------------   | :-----: | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `enabled`                       | Boolean | `false` | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers`                                                                                              |
| `pollingInterval`               | Integer | `30`    | The interval to check each trigger on                                                                                                                                           |
| `cooldownPeriod`                | Integer | `300`   | The period to wait after the last trigger reported active before scaling the resource back to 0                                                                                 |
| `minReplicaCount`               | Integer |         | Minimum number of replicas KEDA will scale the resource down to, defaults to `hpa.minReplicas`                                                                                  |
| `maxReplicaCount`               | Integer |         | Maximum number of replicas KEDA will scale the resource up to, defaults to `hpa.maxReplicas`                                                                                    |
| `fallback`                      | Map     |         | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback)                                                          |
| `hpaName`                       | String  |         | The name of the HPA resource KEDA will create, defaults to `keda-hpa-{scaled-object-name}`                                                                                      |
| `restoreToOriginalReplicaCount` | Boolean |         | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted                                                      |
| `behavior`                      | Map     |         | The specifications for up- and downscaling behavior, defaults to `hpa.behavior`                                                                                                 |
| `triggers`                      | Array   |         | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory`                                                      |

### serviceAccount

This section controls if a ServiceAccount should be created and if the default access token should be mounted in pods.

| Name                           |  Type   | Default | Description                                                                                                                                                                      |
| :----------------------------- | :-----: | :------ | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `annotations`                  | Map     | `{}`    | ServiceAccount annotations.                                                                                                                                                      |
| `automountServiceAccountToken` | Boolean | `false` | Controls if the default ServiceAccount access token should be mounted in pods. You should not enable this unless it is required by certain sidecars to work properly (for example, Istio). |
| `create`                       | Boolean | `false` | Indicates whether or not a ServiceAccount should be created.                                                                                                                     |
| `enabled`                      | Boolean | `false` | Indicates whether or not to use a ServiceAccount.                                                                                                                                |
| `name`                         | String  |         | Name of the ServiceAccount. If not set, the chart full name is used.                                                                                                             |

### affinity

For more information, see [`affinity`](../index.md#affinity).
