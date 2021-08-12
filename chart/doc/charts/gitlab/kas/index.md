---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Using the GitLab-Kas chart

The `kas` sub-chart provides a configurable deployment of the [Kubernetes Agent Server](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent#gitlab-kubernetes-agent-server-kas), which is the server-side component of the [GitLab Kubernetes Agent](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent) implementation.

## Requirements

This chart depends on access to the GitLab API and the Gitaly Servers. An Ingress is deployed if this chart is enabled.

## Design Choices

The `kas` container used in this chart use a distroless image for minimal resource consumption. The deployed services are exposed by an Ingress which uses [WebSocket proxying](https://nginx.org/en/docs/http/websocket.html) to permit communication in long lived connections with the external component [`agentk`](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent#gitlab-kubernetes-agent-agentk), which is its Kubernetes cluster-side agent counterpart.

The route to access the service will depend on your [Ingress configuration](#ingress).

Follow the link for further information about the [GitLab Kubernetes Agent architecture](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/blob/master/doc/architecture.md).

## Configuration

### Enable

`kas` is deployed turned off by default. To enable it on your GitLab server, use the Helm property `global.kas.enabled`, like: `helm install --set global.kas.enabled=true`.

### Ingress

When using the chart's Ingress with default configuration, the KAS service will be reachable via a subdomain. For example, if you have `global.hosts.domain: example.com`, then by default KAS will be reachable at `kas.example.com`.

The [KAS Ingress](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/charts/gitlab/charts/kas/templates/ingress.yaml) can use a different domain than what is used globally under `global.hosts.domain` by setting `global.hosts.kas.name`. For example, setting `global.hosts.kas.name=kas.my-other-domain.com` will set `kas.my-other-domain.com` as the host for the KAS Ingress alone, while the rest of the services (including GitLab, Registry, MinIO, etc.) will use the domain specified in `global.hosts.domain`.

### Installation command line options

The table below contains all the possible charts configurations that can be supplied to
the `helm install` command using the `--set` flags.

| Parameter                   | Default        | Description                      |
| --------------------------- | -------------- | ---------------------------------|
| `annotations`               | `{}`           | Pod annotations                  |
| `extraContainers`           |                | List of extra containers to include      |
| `image.repository`          | `registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/kas` | image repository |
| `image.tag`                 | `v13.7.0`      | Image tag                        |
| `hpa.targetAverageValue`    | `100m`         | Set the autoscaling target value (CPU) |
| `ingress.enabled`           |  `true` if `global.kas.enabled=true` | You can use `kas.ingress.enabled` to explicitly turn it on or off. If not set, you can optionally use `global.ingress.enabled` for the same purpose. |
| `ingress.annotations`       | `{}`           | Ingress annotations              |
| `ingress.tls`               | `{}`           | Ingress TLS configuration        |
| `metrics.enabled`           | `true`         | Toggle Prometheus metrics exporter |
| `metrics.port`              | `8151`         | Port number to use for the metrics exporter |
| `metrics.path`              | `/metrics`     | Path to use for the metrics exporter |
| `maxReplicas`               | `10`           | HPA `maxReplicas`                |
| `maxUnavailable`            | `1`            | HPA `maxUnavailable`             |
| `minReplicas`               | `2`            | HPA `maxReplicas`                |
| `nodeSelector`              |                | Define a [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) for the `Pod`s of this `Deployment`, if present. |
| `serviceAccount.annotations`| `{}`       | Service account annotations      |
| `podLabels`                 | `{}`           | Supplemental Pod labels. Not used for selectors. |
| `serviceLabels`             | `{}`           | Supplemental service labels |
| `common.labels`             |                | Supplemental labels that are applied to all objects created by this chart. |
| `redis.enabled`             | `true`         | Allows opting-out of using Redis for KAS features. Warnings: Redis will become a hard dependency soon, so this key is already deprecated. |
| `resources.requests.cpu`    | `75m`                 | GitLab Exporter minimum CPU                    |
| `resources.requests.memory` | `100M`                | GitLab Exporter minimum memory                 |
| `service.externalPort`      | `8150`         | External port (for agentk connections) |
| `service.internalPort`      | `8150`         | Internal port (for agentk connections) |
| `service.apiInternalPort`   | `8153`         | Internal port for the internal API (for GitLab backend) |
| `global.kas.service.apiExternalPort` | `8153` | External port for the internal API (for GitLab backend) |
| `service.type`              | `ClusterIP`    | Service type                     |
| `tolerations`               | `[]`           | Toleration labels for pod assignment     |
| `customConfig`              | `{}`           | When given, merges the default `kas` configuration with these values giving precedence to those defined here. |
| `deployment.strategy`       | `{}`           | Allows one to configure the update strategy utilized by the deployment |

## Development (how to manual QA)

To install the chart:

1. Create your own Kubernetes cluster.
1. Check out the merge request's working branch.
1. Install (or upgrade) GitLab with `kas` enabled from your local chart branch,
   using `--set global.kas.enabled=true`, for example:

   ```shell
   helm upgrade --force --install gitlab . \
     --timeout 600s \
     --set global.hosts.domain=your.domain.com \
     --set global.hosts.externalIP=XYZ.XYZ.XYZ.XYZ \
     --set certmanager-issuer.email=your@email.com \
     --set global.kas.enabled=true
   ```

1. Use the GDK to run the process to configure and use the
   [GitLab Kubernetes Agent](https://docs.gitlab.com/ee/user/clusters/agent/):
   (You can also follow the steps to configure and use the Agent manually.)

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
