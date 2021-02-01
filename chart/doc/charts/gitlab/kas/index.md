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
| `serviceAccount.annotations`| `{}`       | Service account annotations      |
| `podLabels`                 | `{}`           | Supplemental Pod labels. Not used for selectors. |
| `resources.requests.cpu`    | `75m`                 | GitLab Exporter minimum CPU                    |
| `resources.requests.memory` | `100M`                | GitLab Exporter minimum memory                 |
| `service.externalPort`      | `8150`         | External port                    |
| `service.internalPort`      | `8150`         | Internal port                    |
| `service.type`              | `ClusterIP`    | Service type                     |
| `tolerations`               | `[]`           | Toleration labels for pod assignment     |
| `customConfig`              | `{}`           | When given, fully overwrites the `kas` configuration with these values. |

## Development (how to manual QA)

1. Install the chart

   Choose the **Short Path** if you have access to `gitlab-paas` GCP project (internal), which enables you
   to skip almost all the steps since cluster, project and agents are already setup.
   Choose the **Long Path** if you don't have access to `gitlab-paas` GCP project (internal).

   - **Short Path:** setup your local configuration to talk to this cluster:
   `gcloud container clusters get-credentials kas-chart-qa --zone us-west1-b --project gitlab-paas`. Then checkout the MR working branch and install/upgrade GitLab with `kas` enabled from your local chart branch using `--set global.kas.enabled=true`. For example, using Helm v3:

   ```shell
   helm upgrade --force --install gitlab . \
     --timeout 600s \
     --set global.hosts.domain=qa.joaocunha.eu \
     --set global.hosts.externalIP=35.227.184.50 \
     --set certmanager-issuer.email=fake.email@gitlab.com \
     --set global.kas.enabled=true
   ```

   Check that the deploy was successful and skip to step 6.

   - **Long Path:** create your own GKE cluster. Then checkout the MR working branch and install/upgrade GitLab with `kas` enabled from your local chart branch using `--set global.kas.enabled=true`, for example:

   ```shell
   helm upgrade --force --install gitlab . \
     --timeout 600s \
     --set global.hosts.domain=your.domain.com \
     --set global.hosts.externalIP=XYZ.XYZ.XYZ.XYZ \
     --set certmanager-issuer.email=your@email.com \
     --set global.kas.enabled=true
   ```

1. Create a project on your GitLab instance to manage your cluster by either importing or copying the contents of [this template project](https://gitlab.qa.joaocunha.eu/root/kas-qa):

1. Create a `Clusters::Agent` and a `Clusters::AgentToken`. **Take note of the generated token, since you need it in the next step**.

   To do this you could either run `rails c` or via GraphQL. From `rails c`:

   ```ruby
   project = ::Project.find_by_full_path("root/kas-qa")
   agent = ::Clusters::Agent.create(name: "my-agent", project: project)
   token = ::Clusters::AgentToken.create(agent: agent)
   token.token # this will print out the token you need to use on the next step
   ```

   or using GraphQL:

   with this approach, you need a Premium license to use this feature.

   ```json
   mutation createAgent {
     createClusterAgent(input: { projectPath: "root/kas-qa", name: "my-agent" }) {
       clusterAgent {
         id
         name
       }
       errors
     }
   }

   mutation createToken {
     clusterAgentTokenCreate(input: { clusterAgentId: <cluster-agent-id-taken-from-the-previous-mutation> }) {
       secret
       token {
         createdAt
         id
       }
       errors
     }
   }
   ```

   Note that GraphQL only shows you the token once, after you've created it. It's the `secret` field.

1. Follow these instructions on installing the [GitLab Kubernetes Agent](https://gitlab.com/gitlab-org/cluster-integration/gitlab-agent/-/tree/master/build/deployment/gitlab-agent) with the token generated on the previous step.

1. Login with the root user, edit the `manifest.yaml` ConfigMap in the root of your project. If you're using `gitlab-paas`, here is your [`manifest.yaml`](https://gitlab.qa.joaocunha.eu/root/kas-qa/-/blob/master/manifest.yaml). Change one of the configurations to whatever value you like, for instance increment the `data.game.properties.lives` attribute. Wait 30 seconds and check if this configuration map was correctly updated on your cluster: `kubectl get cm -n agentk game-config -oyaml`
