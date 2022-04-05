---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
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

1. On the top bar, select `Menu` > `Admin`.
1. On the left sidebar, select `Settings` > `Reporting`.
1. Expand `Spam and Anti-bot Protection`.
1. Update the Spam Check settings:
    1. Check the `Enable Spam Check via external API endpoint` checkbox
    1. For URL of the external Spam Check endpoint use `grpc://gitlab-spamcheck.default.svc:8001`, where `default` is replaced with the Kubernetes namespace where GitLab is deployed.
    1. Leave `Spam Check API key` blank.
1. Select `Save changes`.

## Installation command line options

The table below contains all the possible charts configurations that can be supplied to the `helm install` command using the `--set` flags.

| Parameter                   | Default        | Description                      |
| --------------------------- | -------------- | ---------------------------------|
| `annotations`               | `{}`           | Pod annotations                  |
| `common.labels`             | `{}`           | Supplemental labels that are applied to all objects created by this chart.  |
| `deployment.livenessProbe.initialDelaySeconds`  | 20     | Delay before liveness probe is initiated       |
| `deployment.livenessProbe.periodSeconds`        | 60     | How often to perform the liveness probe        |
| `deployment.livenessProbe.timeoutSeconds`       | 30     | When the liveness probe times out              |
| `deployment.livenessProbe.successThreshold`     | 1      | Minimum consecutive successes for the liveness probe to be considered successful after having failed |
| `deployment.livenessProbe.failureThreshold`     | 3      | Minimum consecutive failures for the liveness probe to be considered failed after having succeeded |
| `deployment.readinessProbe.initialDelaySeconds` | 0      | Delay before readiness probe is initiated      |
| `deployment.readinessProbe.periodSeconds`       | 10     | How often to perform the readiness probe       |
| `deployment.readinessProbe.timeoutSeconds`      | 2      | When the readiness probe times out             |
| `deployment.readinessProbe.successThreshold`    | 1      | Minimum consecutive successes for the readiness probe to be considered successful after having failed |
| `deployment.readinessProbe.failureThreshold`    | 3      | Minimum consecutive failures for the readiness probe to be considered failed after having succeeded |
| `deployment.strategy`      | `{}`                  | Allows one to configure the update strategy used by the deployment. When not provided, the cluster default is used. |
| `hpa.targetAverageValue`    | `100m`         | Set the autoscaling target value (CPU) |
| `image.repository`          | `registry.gitlab.com/gitlab-com/gl-security/engineering-and-research/automation-team/spam/spamcheck` | Spamcheck image repository |
| `logging.format`         | `json`      | Log format  |
| `logging.level`   | `info`     | Log level |
| `metrics.enabled`           | `true`         | Toggle Prometheus metrics exporter |
| `metrics.port`              | `8003`         | Port number to use for the metrics exporter |
| `metrics.path`              | `/metrics`     | Path to use for the metrics exporter |
| `maxReplicas`               | `10`           | HPA `maxReplicas`                |
| `maxUnavailable`            | `1`            | HPA `maxUnavailable`             |
| `minReplicas`               | `2`            | HPA `maxReplicas`                |
| `podLabels`                 | `{}`           | Supplemental Pod labels. Not used for selectors. |
| `resources.requests.cpu`    | `100m`         | Spamcheck minimum CPU                    |
| `resources.requests.memory` | `100M`         | Spamcheck minimum memory                 |
| `securityContext.fsGroup`        | `1000`                | Group ID under which the pod should be started |
| `securityContext.runAsUser`      | `1000`                | User ID under which the pod should be started  |
| `serviceLabels`                  | `{}`                  | Supplemental service labels |
| `service.externalPort`           | `8001`                | Spamcheck external port |
| `service.internalPort`           | `8001`                | Spamcheck internal port |
| `service.type`                   | `ClusterIP`           | Spamcheck service type |
| `serviceAccount.enabled`             | Flag for using ServiceAccount                    | `false`                       |
| `serviceAccount.create`              | Flag for creating a ServiceAccount               | `false`                       |
| `tolerations`                    | `[]`                  | Toleration labels for pod assignment |

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

`annotations` allows you to add annotations to the Webservice pods. For example:

```yaml
annotations:
  kubernetes.io/example-annotation: annotation-value
```
