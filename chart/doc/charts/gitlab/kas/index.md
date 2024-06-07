---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the GitLab `kas` chart

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

The `kas` sub-chart provides a configurable deployment of the
[GitLab agent server (KAS)](https://docs.gitlab.com/ee/administration/clusters/kas.html).
The agent server is a component you install together with GitLab. It is required to
manage the [GitLab agent for Kubernetes](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent).

This chart depends on access to the GitLab API and the Gitaly Servers.
When you enable this chart, an Ingress is deployed.

To consume minimal resources, the `kas` container uses a distroless image.
The deployed services are exposed by an Ingress, which uses
[WebSocket proxying](https://nginx.org/en/docs/http/websocket.html) for communication.
This proxy allows long-lived connections with the external component,
[`agentk`](https://docs.gitlab.com/ee/user/clusters/agent/install/index.html).
`agentk` is the Kubernetes cluster-side agent counterpart.

The route to access the service depends on your [Ingress configuration](#specify-an-ingress).

For more information, see the
[GitLab agent for Kubernetes architecture](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/architecture.md).

## Disable the agent server

The GitLab agent server (`kas`) is enabled by default.
To disable it on your GitLab instance, set the Helm property `global.kas.enabled` to `false`.

For example:

```shell
helm upgrade --install kas --set global.kas.enabled=false
```

### Specify an Ingress

When you use the chart's Ingress with the default configuration,
the service for the agent server is reachable on a subdomain.
For example, for `global.hosts.domain: example.com`, the agent server
is reachable at `kas.example.com`.

The [KAS Ingress](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/charts/gitlab/charts/kas/templates/ingress.yaml)
can use a different domain than the `global.hosts.domain`.

Set `global.hosts.kas.name`, for example:

```shell
global.hosts.kas.name: kas.my-other-domain.com
```

This example uses `kas.my-other-domain.com` as the host for the KAS Ingress alone.
The rest of the services (including GitLab, Registry, MinIO, etc.) use the domain
specified in `global.hosts.domain`.

### Installation command line options

You can pass these parameters to the `helm install` command by using the `--set` flags.

| Parameter                                    | Default                                                 | Description                                                                                                                                                                                                                                                  |
| -------------------------------------------- | ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `annotations`                                | `{}`                                                    | Pod annotations.                                                                                                                                                                                                                                             |
| `common.labels`                              | `{}`                                                    | Supplemental labels that are applied to all objects created by this chart.                                                                                                                                                                                   |
| `containerSecurityContext.runAsUser`         | `65532`                                                 | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started                                                                                      |
| `extraContainers`                            |                                                         | List of extra containers to include.                                                                                                                                                                                                                         |
| `extraEnv`                                   |                                                         | List of extra environment variables to expose                                                                                                                                                                                                                |
| `extraEnvFrom`                               |                                                         | List of extra environment variables from other data sources to expose                                                                                                                                                                                        |
| `init.containerSecurityContext`              | `{}`                                                    | init container securityContext overrides                                                                                                                                                                                                                     |
| `image.repository`                           | `registry.gitlab.com/gitlab-org/build/cng/gitlab-kas`   | Image repository.                                                                                                                                                                                                                                            |
| `image.tag`                                  | `v13.7.0`                                               | Image tag.                                                                                                                                                                                                                                                   |
| `hpa.behavior`                               | `{scaleDown: {stabilizationWindowSeconds: 300 }}`       | Behavior contains the specifications for up- and downscaling behavior (requires `autoscaling/v2beta2` or higher).                                                                                                                                            |
| `hpa.customMetrics`                          | `[]`                                                    | Custom metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`).                                                          |
| `hpa.cpu.targetType`                         | `AverageValue`                                          | Set the autoscaling CPU target type, must be either `Utilization` or `AverageValue`.                                                                                                                                                                         |
| `hpa.cpu.targetAverageValue`                 | `100m`                                                  | Set the autoscaling CPU target value.                                                                                                                                                                                                                        |
| `hpa.cpu.targetAverageUtilization`           |                                                         | Set the autoscaling CPU target utilization.                                                                                                                                                                                                                  |
| `hpa.memory.targetType`                      |                                                         | Set the autoscaling memory target type, must be either `Utilization` or `AverageValue`.                                                                                                                                                                      |
| `hpa.memory.targetAverageValue`              |                                                         | Set the autoscaling memory target value.                                                                                                                                                                                                                     |
| `hpa.memory.targetAverageUtilization`        |                                                         | Set the autoscaling memory target utilization.                                                                                                                                                                                                               |
| `hpa.targetAverageValue`                     |                                                         | **DEPRECATED** Set the autoscaling CPU target value                                                                                                                                                                                                          |
| `ingress.enabled`                            | `true` if `global.kas.enabled=true`                     | You can use `kas.ingress.enabled` to explicitly turn it on or off. If not set, you can optionally use `global.ingress.enabled` for the same purpose.                                                                                                         |
| `ingress.apiVersion`                         |                                                         | Value to use in the `apiVersion` field.                                                                                                                                                                                                                      |
| `ingress.annotations`                        | `{}`                                                    | Ingress annotations.                                                                                                                                                                                                                                         |
| `ingress.tls`                                | `{}`                                                    | Ingress TLS configuration.                                                                                                                                                                                                                                   |
| `ingress.agentPath`                          | `/`                                                     | Ingress path for the agent API endpoint.                                                                                                                                                                                                                     |
| `ingress.k8sApiPath`                         | `/k8s-proxy`                                            | Ingress path for Kubernetes API endpoint.                                                                                                                                                                                                                    |
| `keda.enabled`                               | `false`                                                 | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers`                                                                                                                                                                           |
| `keda.pollingInterval`                       | `30`                                                    | The interval to check each trigger on                                                                                                                                                                                                                        |
| `keda.cooldownPeriod`                        | `300`                                                   | The period to wait after the last trigger reported active before scaling the resource back to 0                                                                                                                                                              |
| `keda.minReplicaCount`                       |                                                         | Minimum number of replicas KEDA will scale the resource down to, defaults to `minReplicas`                                                                                                                                                                   |
| `keda.maxReplicaCount`                       |                                                         | Maximum number of replicas KEDA will scale the resource up to, defaults to `maxReplicas`                                                                                                                                                                     |
| `keda.fallback`                              |                                                         | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback)                                                                                                                                       |
| `keda.hpaName`                               |                                                         | The name of the HPA resource KEDA will create, defaults to `keda-hpa-{scaled-object-name}`                                                                                                                                                                   |
| `keda.restoreToOriginalReplicaCount`         |                                                         | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted                                                                                                                                   |
| `keda.behavior`                              |                                                         | The specifications for up- and downscaling behavior, defaults to `hpa.behavior`                                                                                                                                                                              |
| `keda.triggers`                              |                                                         | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory`                                                                                                                                   |
| `metrics.enabled`                            | `true`                                                  | If a metrics endpoint should be made available for scraping.                                                                                                                                                                                                 |
| `metrics.path`                               | `/metrics`                                              | Metrics endpoint path.                                                                                                                                                                                                                                       |
| `metrics.serviceMonitor.enabled`             | `false`                                                 | If a ServiceMonitor should be created to enable Prometheus Operator to manage the metrics scraping. Enabling removes the `prometheus.io` scrape annotations.                                                                                                 |
| `metrics.serviceMonitor.additionalLabels`    | `{}`                                                    | Additional labels to add to the ServiceMonitor.                                                                                                                                                                                                              |
| `metrics.serviceMonitor.endpointConfig`      | `{}`                                                    | Additional endpoint configuration for the ServiceMonitor.                                                                                                                                                                                                    |
| `maxReplicas`                                | `10`                                                    | HPA `maxReplicas`.                                                                                                                                                                                                                                           |
| `maxUnavailable`                             | `1`                                                     | HPA `maxUnavailable`.                                                                                                                                                                                                                                        |
| `minReplicas`                                | `2`                                                     | HPA `maxReplicas`.                                                                                                                                                                                                                                           |
| `nodeSelector`                               |                                                         | Define a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) for the `Pod`s of this `Deployment`, if present.                                                                                              |
| `observability.port`                         | `8151`                                                  | Observability endpoint port. Used for metrics and probe endpoints.                                                                                                                                                                                           |
| `observability.livenessProbe.path`           | `/liveness`                                             | URI for the liveness probe endpoint. This value has to match the `observability.liveness_probe.url_path` value from the KAS service configuration.                                                                                                           |
| `observability.readinessProbe.path`          | `/readiness`                                            | URI for the readiness probe endpoint. This value has to match the `observability.readiness_probe.url_path` value from the KAS service configuration.                                                                                                         |
| `serviceAccount.annotations`                 | `{}`                                                    | Service account annotations.                                                                                                                                                                                                                                 |
| `podLabels`                                  | `{}`                                                    | Supplemental Pod labels. Not used for selectors.                                                                                                                                                                                                             |
| `serviceLabels`                              | `{}`                                                    | Supplemental service labels.                                                                                                                                                                                                                                 |
| `common.labels`                              |                                                         | Supplemental labels that are applied to all objects created by this chart.                                                                                                                                                                                   |
| `redis.enabled`                              | `true`                                                  | Allows opting-out of using Redis for KAS features. Warnings: Redis will become a hard dependency soon, so this key is already deprecated.                                                                                                                    |
| `resources.requests.cpu`                     | `75m`                                                   | GitLab Exporter minimum CPU.                                                                                                                                                                                                                                 |
| `resources.requests.memory`                  | `100M`                                                  | GitLab Exporter minimum memory.                                                                                                                                                                                                                              |
| `service.externalPort`                       | `8150`                                                  | External port (for `agentk` connections).                                                                                                                                                                                                                    |
| `service.internalPort`                       | `8150`                                                  | Internal port (for `agentk` connections).                                                                                                                                                                                                                    |
| `service.apiInternalPort`                    | `8153`                                                  | Internal port for the internal API (for GitLab backend).                                                                                                                                                                                                     |
| `service.loadBalancerIP`                     | `nil`                                                   | A custom load balancer IP when `service.type` is `LoadBalancer`.                                                                                                                                                                                             |
| `service.loadBalancerSourceRanges`           | `nil`                                                   | A list of custom load balancer source ranges when `service.type` is `LoadBalancer`.                                                                                                                                                                          |
| `service.kubernetesApiPort`                  | `8154`                                                  | External port to expose proxied Kubernetes API on.                                                                                                                                                                                                           |
| `service.privateApiPort`                     | `8155`                                                  | Internal port to expose `kas`' private API on (for `kas` -> `kas` communication).                                                                                                                                                                            |
| `privateApi.secret`                          | Autogenerated                                           | The name of the secret to use for authenticating with the database.                                                                                                                                                                                          |
| `privateApi.key`                             | Autogenerated                                           | The name of the key in `privateApi.secret` to use.                                                                                                                                                                                                           |
| `global.kas.service.apiExternalPort`         | `8153`                                                  | External port for the internal API (for GitLab backend).                                                                                                                                                                                                     |
| `service.type`                               | `ClusterIP`                                             | Service type.                                                                                                                                                                                                                                                |
| `tolerations`                                | `[]`                                                    | Toleration labels for pod assignment.                                                                                                                                                                                                                        |
| `customConfig`                               | `{}`                                                    | When given, merges the default `kas` configuration with these values giving precedence to those defined here.                                                                                                                                                |
| `deployment.minReadySeconds`                 | `0`                                                     | Minimum number of seconds that must pass before a `kas` pod is considered ready.                                                                                                                                                                             |
| `deployment.strategy`                        | `{}`                                                    | Allows one to configure the update strategy utilized by the deployment.                                                                                                                                                                                      |
| `deployment.terminationGracePeriodSeconds`   | `300`                                                   | How much time in seconds a Pod is allowed to spend shutting down after receiving SIGTERM.                                                                                                                                                                    |
| `priorityClassName`                          |                                                         | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods.                                                                                                                                         |

## Enable TLS communication

Enable TLS communication between your `kas` pods and other GitLab chart components,
through the [global KAS attribute](../../globals.md#tls-settings-1).

## Test the `kas` chart

To install the chart:

1. Create your own Kubernetes cluster.
1. Check out the merge request's working branch.
1. Install (or upgrade) GitLab with `kas` enabled by default from your local chart branch:

   ```shell
   helm upgrade --force --install gitlab . \
     --timeout 600s \
     --set global.hosts.domain=your.domain.com \
     --set global.hosts.externalIP=XYZ.XYZ.XYZ.XYZ \
     --set certmanager-issuer.email=your@email.com
   ```

1. Use the GDK to run the process to configure and use the
   [GitLab agent for Kubernetes](https://docs.gitlab.com/ee/user/clusters/agent/):
   (You can also follow the steps to configure and use the agent manually.)

   1. From your GDK GitLab repository, move into the QA folder: `cd qa`.
   1. Run the following command to run the QA test:

      ```shell
      GITLAB_USERNAME=$ROOT_USER
      GITLAB_PASSWORD=$ROOT_PASSWORD
      GITLAB_ADMIN_USERNAME=$ROOT_USER
      GITLAB_ADMIN_PASSWORD=$ROOT_PASSWORD
      bundle exec bin/qa Test::Instance::All https://your.gitlab.domain/ -- --tag orchestrated --tag quarantine qa/specs/features/ee/api/7_configure/kubernetes/kubernetes_agent_spec.rb
      ```

      You can also customize the `agentk` version to install with an environment variable: `GITLAB_AGENTK_VERSION=v13.7.1`

## Configuring KEDA

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
| `minReplicaCount`               | Integer |         | Minimum number of replicas KEDA will scale the resource down to, defaults to `minReplicas`                                                                                      |
| `maxReplicaCount`               | Integer |         | Maximum number of replicas KEDA will scale the resource up to, defaults to `maxReplicas`                                                                                        |
| `fallback`                      | Map     |         | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback)                                                          |
| `hpaName`                       | String  |         | The name of the HPA resource KEDA will create, defaults to `keda-hpa-{scaled-object-name}`                                                                                      |
| `restoreToOriginalReplicaCount` | Boolean |         | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted                                                      |
| `behavior`                      | Map     |         | The specifications for up- and downscaling behavior, defaults to `hpa.behavior`                                                                                                 |
| `triggers`                      | Array   |         | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory`                                                      |
