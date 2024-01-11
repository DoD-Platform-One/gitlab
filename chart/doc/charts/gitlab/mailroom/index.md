---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the Mailroom chart **(FREE SELF)**

The Mailroom Chart handles [incoming email](https://docs.gitlab.com/ee/administration/incoming_email.html).

## Configuration

```yaml
image:
  repository: registry.gitlab.com/gitlab-org/build/cng/gitlab-mailroom
  # tag: v0.9.1
  pullSecrets: []
  # pullPolicy: IfNotPresent

enabled: true

init:
  image: {}
    # repository:
    # tag:
  resources:
    requests:
      cpu: 50m

# Tolerations for pod scheduling
tolerations: []

podLabels: {}

hpa:
  minReplicas: 1
  maxReplicas: 2
  cpu:
    targetAverageUtilization: 75

  # Note that the HPA is limited to autoscaling/v2beta1, autoscaling/v2beta2 and autoscaling/v2
  customMetrics: []
  behavior: {}

networkpolicy:
  enabled: false
  egress:
    enabled: false
    rules: []
  ingress:
    enabled: false
    rules: []
  annotations: {}

resources:
  # limits:
  #  cpu: 1
  #  memory: 2G
  requests:
    cpu: 50m
    memory: 150M

## Allow to overwrite under which User and Group we're running.
securityContext:
  runAsUser: 1000
  fsGroup: 1000

## Enable deployment to use a serviceAccount
serviceAccount:
  enabled: false
  create: false
  annotations: {}
  ## Name to be used for serviceAccount, otherwise defaults to chart fullname
  # name:
```

| Parameter                              | Description                                                                                                                                                                                        | Default                                                                                                                                                                 |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------                                                                                                              |
| `deployment.strategy`                  | Allows one to configure the update strategy utilized by the deployment                                                                                                                             | `{}`                                                                                                                                                                    |
| `enabled`                              | Mailroom enablement flag                                                                                                                                                                           | `true`                                                                                                                                                                  |
| `hpa.behavior`                         | Behavior contains the specifications for up- and downscaling behavior (requires `autoscaling/v2beta2` or higher)                                                                                   | `{scaleDown: {stabilizationWindowSeconds: 300 }}`                                                                                                                       |
| `hpa.customMetrics`                    | Custom metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) | `[]`                                                                                                                                                                    |
| `hpa.cpu.targetType`                   | Set the autoscaling CPU target type, must be either `Utilization` or `AverageValue`                                                                                                                | `Utilization`                                                                                                                                                           |
| `hpa.cpu.targetAverageValue`           | Set the autoscaling CPU target value                                                                                                                                                               |                                                                                                                                                                         |
| `hpa.cpu.targetAverageUtilization`     | Set the autoscaling CPU target utilization                                                                                                                                                         | `75`                                                                                                                                                                    |
| `hpa.memory.targetType`                | Set the autoscaling memory target type, must be either `Utilization` or `AverageValue`                                                                                                             |                                                                                                                                                                         |
| `hpa.memory.targetAverageValue`        | Set the autoscaling memory target value                                                                                                                                                            |                                                                                                                                                                         |
| `hpa.memory.targetAverageUtilization`  | Set the autoscaling memory target utilization                                                                                                                                                      |                                                                                                                                                                         |
| `hpa.maxReplicas`                      | Maximum number of replicas                                                                                                                                                                         | `2`                                                                                                                                                                     |
| `hpa.minReplicas`                      | Minimum number of replicas                                                                                                                                                                         | `1`                                                                                                                                                                     |
| `image.pullPolicy`                     | Mailroom image pull policy                                                                                                                                                                         | `IfNotPresent`                                                                                                                                                          |
| `extraEnvFrom`                         | List of extra environment variables from other data sources to expose                                                                                                                              |                                                                                                                                                                         |
| `image.pullSecrets`                    | Mailroom image pull secrets                                                                                                                                                                        |                                                                                                                                                                         |
| `image.registry`                       | Mailroom image registry                                                                                                                                                                          |          |
| `image.repository`                     | Mailroom image repository                                                                                                                                                                          | `registry.gitlab.com/gitlab-org/build/cng/gitlab-mailroom`                                                                                                              |
| `image.tag`                            | Mailroom image tag                                                                                                                                                                                 |        |
| `init.image.repository`                | Mailroom init image repository                                                                                                                                                                     |                                                                                                                                                                         |
| `init.image.tag`                       | Mailroom init image tag                                                                                                                                                                            |                                                                                                                                                                         |
| `init.resources`                       | Mailroom init container resource requirements                                                                                                                                                      | `{ requests: { cpu: 50m }}`                                                                                                                                             |
| `init.containerSecurityContext`        |                                                                                                                                                                                                    | initContainer container specific [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core)                        |
| `keda.enabled`                         | `false`                                                                                                                                                                                            | Use [KEDA](https://keda.sh/) `ScaledObjects` instead of `HorizontalPodAutoscalers`                                                                                      |
| `keda.pollingInterval`                 | `30`                                                                                                                                                                                               | The interval to check each trigger on                                                                                                                                   |
| `keda.cooldownPeriod`                  | `300`                                                                                                                                                                                              | The period to wait after the last trigger reported active before scaling the resource back to 0                                                                         |
| `keda.minReplicaCount`                 |                                                                                                                                                                                                    | Minimum number of replicas KEDA will scale the resource down to, defaults to `hpa.minReplicas`                                                                          |
| `keda.maxReplicaCount`                 |                                                                                                                                                                                                    | Maximum number of replicas KEDA will scale the resource up to, defaults to `hpa.maxReplicas`                                                                            |
| `keda.fallback`                        |                                                                                                                                                                                                    | KEDA fallback configuration, see the [documentation](https://keda.sh/docs/2.10/concepts/scaling-deployments/#fallback)                                                  |
| `keda.hpaName`                         |                                                                                                                                                                                                    | The name of the HPA resource KEDA will create, defaults to `keda-hpa-{scaled-object-name}`                                                                              |
| `keda.restoreToOriginalReplicaCount`   |                                                                                                                                                                                                    | Specifies whether the target resource should be scaled back to original replicas count after the `ScaledObject` is deleted                                              |
| `keda.behavior`                        |                                                                                                                                                                                                    | The specifications for up- and downscaling behavior, defaults to `hpa.behavior`                                                                                         |
| `keda.triggers`                        |                                                                                                                                                                                                    | List of triggers to activate scaling of the target resource, defaults to triggers computed from `hpa.cpu` and `hpa.memory`                                              |
| `podLabels`                            | Labels for running Mailroom Pods                                                                                                                                                                   | `{}`                                                                                                                                                                    |
| `common.labels`                        | Supplemental labels that are applied to all objects created by this chart.                                                                                                                         | `{}`                                                                                                                                                                    |
| `resources`                            | Mailroom resource requirements                                                                                                                                                                     | `{ requests: { cpu: 50m, memory: 150M }}`                                                                                                                               |
| `networkpolicy.annotations`            | Annotations to add to the NetworkPolicy                                                                                                                                                            | `{}`                                                                                                                                                                    |
| `networkpolicy.egress.enabled`         | Flag to enable egress rules of NetworkPolicy                                                                                                                                                       | `false`                                                                                                                                                                 |
| `networkpolicy.egress.rules`           | Define a list of egress rules for NetworkPolicy                                                                                                                                                    | `[]`                                                                                                                                                                    |
| `networkpolicy.enabled`                | Flag for using NetworkPolicy                                                                                                                                                                       | `false`                                                                                                                                                                 |
| `networkpolicy.ingress.enabled`        | Flag to enable `ingress` rules of NetworkPolicy                                                                                                                                                    | `false`                                                                                                                                                                 |
| `networkpolicy.ingress.rules`          | Define a list of `ingress` rules for NetworkPolicy                                                                                                                                                 | `[]`                                                                                                                                                                    |
| `securityContext.fsGroup`              | Group ID under which the pod should be started                                                                                                                                                     | `1000`                                                                                                                                                                  |
| `securityContext.runAsUser`            | User ID under which the pod should be started                                                                                                                                                      | `1000`                                                                                                                                                                  |
| `securityContext.fsGroupChangePolicy`  | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23)                                                                                                              |                                                                                                                                                                         |
| `containerSecurityContext`             |                                                                                                                                                                                                    | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started |
| `containerSecurityContext.runAsUser`   | `1000`                                                                                                                                                                                             | Allow to overwrite the specific security context under which the container is started                                                                                   |
| `serviceAccount.annotations`           | Annotations for ServiceAccount                                                                                                                                                                     | `{}`                                                                                                                                                                    |
| `serviceAccount.enabled`               | Flag for using ServiceAccount                                                                                                                                                                      | `false`                                                                                                                                                                 |
| `serviceAccount.create`                | Flag for creating a ServiceAccount                                                                                                                                                                 | `false`                                                                                                                                                                 |
| `serviceAccount.name`                  | Name of ServiceAccount to use                                                                                                                                                                      |                                                                                                                                                                         |
| `tolerations`                          | Tolerations to add to the Mailroom                                                                                                                                                                 |                                                                                                                                                                         |
| `priorityClassName`                    | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods.                                                                               |                                                                                                                                                                         |

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

## Incoming email

By default, incoming email is disabled. There are two methods for
reading incoming email:

- [IMAP](#imap)
- [Microsoft Graph](#microsoft-graph)

First, enable it by setting the [common settings](../../../installation/command-line-options.md#common-settings).
Then configure the [IMAP settings](../../../installation/command-line-options.md#imap-settings) or
[Microsoft Graph settings](../../../installation/command-line-options.md#microsoft-graph-settings).

These methods can be configured in `values.yaml`. See the following examples:

- [Incoming email with IMAP](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-incoming-email.yaml)
- [Incoming email with Microsoft Graph](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-msgraph.yaml)

### IMAP

To enable incoming e-mail for IMAP, provide details of your IMAP server
and access credentials using the `global.appConfig.incomingEmail`
settings.

In addition, the [requirements for the IMAP email account](https://docs.gitlab.com/ee/administration/incoming_email.html)
should be reviewed to ensure that the targeted IMAP account can be used
by GitLab for receiving email. Several common email services are also
documented on the same page to aid in setting up incoming email.

The IMAP password will still need to be created as a Kubernetes Secret as
described in the [secrets guide](../../../installation/secrets.md#imap-password-for-incoming-emails).

### Microsoft Graph

See the [GitLab documentation on creating an Azure Active Directory application](https://docs.gitlab.com/ee/administration/incoming_email.html#microsoft-graph).

Provide the tenant ID, client ID, and client secret. You can find details for these settings in the [command line options](../../../installation/command-line-options.md#incoming-email-configuration).

Create a Kubernetes secret containing the client secret as described in the [secrets guide](../../../installation/secrets.md#microsoft-graph-client-secret-for-incoming-emails).

### Reply-by-email

To use the reply-by-email feature, where users can reply to notification emails to
comment on issues and MRs, you need to configure both [outgoing email](../../../installation/command-line-options.md#outgoing-email-configuration)
and incoming email settings.

### Service Desk email

By default, the Service Desk email is disabled.

As with incoming e-mail, enable it by setting the [common settings](../../../installation/command-line-options.md#common-settings-1).
Then configure the [IMAP settings](../../../installation/command-line-options.md#imap-settings-1) or
[Microsoft Graph settings](../../../installation/command-line-options.md#microsoft-graph-settings-1).

These options can also be configured in `values.yaml`. See the following examples:

- [Service Desk with IMAP](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-service-desk-email.yaml)
- [Service Desk with Microsoft Graph](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-msgraph.yaml)

Service Desk email _requires_ that [Incoming email](#incoming-email) be configured.

#### IMAP

Provide details of your IMAP server and access credentials using the
`global.appConfig.serviceDeskEmail` settings. You can find details for
these settings in the [command line options](../../../installation/command-line-options.md#service-desk-email-configuration).

Create a Kubernetes secret containing IMAP password as described in the [secrets guide](../../../installation/secrets.md#imap-password-for-service-desk-emails).

#### Microsoft Graph

See the [GitLab documentation on creating an Azure Active Directory application](https://docs.gitlab.com/ee/administration/incoming_email.html#microsoft-graph).

Provide the tenant ID, client ID, and client secret using the
`global.appConfig.serviceDeskEmail` settings. You can find details for
these settings in the [command line options](../../../installation/command-line-options.md#service-desk-email-configuration).

You will also have to create a Kubernetes secret containing the client secret
as described in the [secrets guide](../../../installation/secrets.md#imap-password-for-service-desk-emails).
