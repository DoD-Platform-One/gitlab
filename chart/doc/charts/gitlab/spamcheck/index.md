---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the GitLab-Spamcheck chart **(PREMIUM SELF)**

The `spamcheck` sub-chart provides a deployment of [Spamcheck](https://gitlab.com/gitlab-org/spamcheck) which is an anti-spam engine developed by GitLab originally to combat the rising amount of spam in GitLab.com, and later made public to be used in self-managed GitLab instances.

## Requirements

This chart depends on access to the GitLab API.

## Configuration

### Enable Spamcheck

`spamcheck` is disabled by default. To enable it on your GitLab instance, set the Helm property `global.spamcheck.enabled` to `true`, for example:

```shell
helm upgrade --force --install gitlab . \
--set global.hosts.domain='your.domain.com' \
--set global.hosts.externalIP=XYZ.XYZ.XYZ.XYZ \
--set certmanager-issuer.email='me@example.com' \
--set global.spamcheck.enabled=true
```

### Configure GitLab to use Spamcheck

1. On the left sidebar, at the bottom, select **Admin Area**.
1. Select **Settings > Reporting**.
1. Expand **Spam and Anti-bot Protection**.
1. Update the Spam Check settings:
   1. Check the "Enable Spam Check via external API endpoint" checkbox
   1. For URL of the external Spam Check endpoint use `grpc://gitlab-spamcheck.default.svc:8001`, where `default` is replaced with the Kubernetes namespace where GitLab is deployed.
   1. Leave "Spam Check API key" blank.
1. Select **Save changes**.

## Installation command line options

The table below contains all the possible charts configurations that can be supplied to the `helm install` command using the `--set` flags.

| Parameter                                       | Default                                                                                              | Description                                                                                                                                                                                        |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------                                                                                |
| `annotations`                                   | `{}`                                                                                                 | Pod annotations                                                                                                                                                                                    |
| `common.labels`                                 | `{}`                                                                                                 | Supplemental labels that are applied to all objects created by this chart.                                                                                                                         |
| `deployment.livenessProbe.initialDelaySeconds`  | 20                                                                                                   | Delay before liveness probe is initiated                                                                                                                                                           |
| `deployment.livenessProbe.periodSeconds`        | 60                                                                                                   | How often to perform the liveness probe                                                                                                                                                            |
| `deployment.livenessProbe.timeoutSeconds`       | 30                                                                                                   | When the liveness probe times out                                                                                                                                                                  |
| `deployment.livenessProbe.successThreshold`     | 1                                                                                                    | Minimum consecutive successes for the liveness probe to be considered successful after having failed                                                                                               |
| `deployment.livenessProbe.failureThreshold`     | 3                                                                                                    | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded                                                                                                 |
| `deployment.readinessProbe.initialDelaySeconds` | 0                                                                                                    | Delay before readiness probe is initiated                                                                                                                                                          |
| `deployment.readinessProbe.periodSeconds`       | 10                                                                                                   | How often to perform the readiness probe                                                                                                                                                           |
| `deployment.readinessProbe.timeoutSeconds`      | 2                                                                                                    | When the readiness probe times out                                                                                                                                                                 |
| `deployment.readinessProbe.successThreshold`    | 1                                                                                                    | Minimum consecutive successes for the readiness probe to be considered successful after having failed                                                                                              |
| `deployment.readinessProbe.failureThreshold`    | 3                                                                                                    | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded                                                                                                |
| `deployment.strategy`                           | `{}`                                                                                                 | Allows one to configure the update strategy used by the deployment. When not provided, the cluster default is used.                                                                                |
| `hpa.behavior`                                  | `{scaleDown: {stabilizationWindowSeconds: 300 }}`                                                    | Behavior contains the specifications for up- and downscaling behavior (requires `autoscaling/v2beta2` or higher)                                                                                   |
| `hpa.customMetrics`                             | `[]`                                                                                                 | Custom metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) |
| `hpa.cpu.targetType`                            | `AverageValue`                                                                                       | Set the autoscaling CPU target type, must be either `Utilization` or `AverageValue`                                                                                                                |
| `hpa.cpu.targetAverageValue`                    | `100m`                                                                                               | Set the autoscaling CPU target value                                                                                                                                                               |
| `hpa.cpu.targetAverageUtilization`              |                                                                                                      | Set the autoscaling CPU target utilization                                                                                                                                                         |
| `hpa.memory.targetType`                         |                                                                                                      | Set the autoscaling memory target type, must be either `Utilization` or `AverageValue`                                                                                                             |
| `hpa.memory.targetAverageValue`                 |                                                                                                      | Set the autoscaling memory target value                                                                                                                                                            |
| `hpa.memory.targetAverageUtilization`           |                                                                                                      | Set the autoscaling memory target utilization                                                                                                                                                      |
| `hpa.targetAverageValue`                        |                                                                                                      | **DEPRECATED** Set the autoscaling CPU target value                                                                                                                                                |
| `image.registry`                                |                                                                                                      | Spamcheck image registry          |
| `image.repository`                              | `registry.gitlab.com/gitlab-com/gl-security/engineering-and-research/automation-team/spam/spamcheck` | Spamcheck image repository                                                                                                                                                                         |
| `image.tag`                                     |                                                                                                      | Spamcheck image tag                                                                                                                                                                                                      |
| `image.digest`                                  |                                                                                                      | Spamcheck image digest                                                                                                                                                                                                   |
| `keda.enabled`                                  | `false`                                                                                              | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers`                                                                                                                 |
| `keda.pollingInterval`                          | `30`                                                                                                 | The interval to check each trigger on                                                                                                                                                              |
| `keda.cooldownPeriod`                           | `300`                                                                                                | The period to wait after the last trigger reported active before scaling the resource back to 0                                                                                                    |
| `keda.minReplicaCount`                          |                                                                                                      | Minimum number of replicas KEDA will scale the resource down to, defaults to `hpa.minReplicas`                                                                                                     |
| `keda.maxReplicaCount`                          |                                                                                                      | Maximum number of replicas KEDA will scale the resource up to, defaults to `hpa.maxReplicas`                                                                                                       |
| `keda.fallback`                                 |                                                                                                      | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback)                                                                             |
| `keda.hpaName`                                  |                                                                                                      | The name of the HPA resource KEDA will create, defaults to `keda-hpa-{scaled-object-name}`                                                                                                         |
| `keda.restoreToOriginalReplicaCount`            |                                                                                                      | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted                                                                         |
| `keda.behavior`                                 |                                                                                                      | The specifications for up- and downscaling behavior, defaults to `hpa.behavior`                                                                                                                    |
| `keda.triggers`                                 |                                                                                                      | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory`                                                                         |
| `logging.level`                                 | `info`                                                                                               | Log level                                                                                                                                                                                          |
| `maxReplicas`                                   | `10`                                                                                                 | HPA `maxReplicas`                                                                                                                                                                                  |
| `maxUnavailable`                                | `1`                                                                                                  | HPA `maxUnavailable`                                                                                                                                                                               |
| `minReplicas`                                   | `2`                                                                                                  | HPA `maxReplicas`                                                                                                                                                                                  |
| `podLabels`                                     | `{}`                                                                                                 | Supplemental Pod labels. Not used for selectors.                                                                                                                                                   |
| `resources.requests.cpu`                        | `100m`                                                                                               | Spamcheck minimum CPU                                                                                                                                                                              |
| `resources.requests.memory`                     | `100M`                                                                                               | Spamcheck minimum memory                                                                                                                                                                           |
| `securityContext.fsGroup`                       | `1000`                                                                                               | Group ID under which the pod should be started                                                                                                                                                     |
| `securityContext.runAsUser`                     | `1000`                                                                                               | User ID under which the pod should be started                                                                                                                                                      |
| `securityContext.fsGroupChangePolicy`           |                                                                                                      | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23)                                                                                                              |
| `serviceLabels`                                 | `{}`                                                                                                 | Supplemental service labels                                                                                                                                                                        |
| `service.externalPort`                          | `8001`                                                                                               | Spamcheck external port                                                                                                                                                                            |
| `service.internalPort`                          | `8001`                                                                                               | Spamcheck internal port                                                                                                                                                                            |
| `service.type`                                  | `ClusterIP`                                                                                          | Spamcheck service type                                                                                                                                                                             |
| `serviceAccount.enabled`                        | Flag for using ServiceAccount                                                                        | `false`                                                                                                                                                                                            |
| `serviceAccount.create`                         | Flag for creating a ServiceAccount                                                                   | `false`                                                                                                                                                                                            |
| `tolerations`                                   | `[]`                                                                                                 | Toleration labels for pod assignment                                                                                                                                                               |
| `extraEnvFrom`                                  | `{}`                                                                                                 | List of extra environment variables from other data sources to expose                                                                                                                              |
| `priorityClassName`                             |                                                                                                      | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods.                                                                               |

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
| `minReplicaCount`               | Integer |         | Minimum number of replicas KEDA will scale the resource down to, defaults to `hpa.minReplicas`                                                                                  |
| `maxReplicaCount`               | Integer |         | Maximum number of replicas KEDA will scale the resource up to, defaults to `hpa.maxReplicas`                                                                                    |
| `fallback`                      | Map     |         | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback)                                                          |
| `hpaName`                       | String  |         | The name of the HPA resource KEDA will create, defaults to `keda-hpa-{scaled-object-name}`                                                                                      |
| `restoreToOriginalReplicaCount` | Boolean |         | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted                                                      |
| `behavior`                      | Map     |         | The specifications for up- and downscaling behavior, defaults to `hpa.behavior`                                                                                                 |
| `triggers`                      | Array   |         | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory`                                                      |

## Chart configuration examples

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

### annotations

`annotations` allows you to add annotations to the Spamcheck pods. For example:

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```

### resources

`resources` allows you to configure the minimum and maximum amount of resources (memory and CPU) a Spamcheck pod can consume.

For example:

```yaml
resources:
  requests:
    memory: 100m
    cpu: 100M
```

### livenessProbe/readinessProbe

`deployment.livenessProbe` and `deployment.readinessProbe` provide a mechanism to help control the termination of Spamcheck Pods in certain scenarios,
such as, when a container is in a broken state.

For example:

```yaml
deployment:
  livenessProbe:
    initialDelaySeconds: 10
    periodSeconds: 20
    timeoutSeconds: 3
    successThreshold: 1
    failureThreshold: 10
  readinessProbe:
    initialDelaySeconds: 10
    periodSeconds: 5
    timeoutSeconds: 2
    successThreshold: 1
    failureThreshold: 3
```

Refer to the official [Kubernetes Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
for additional details regarding this configuration.
