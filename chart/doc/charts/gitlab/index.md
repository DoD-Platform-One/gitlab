---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# GitLab Helm subcharts

The GitLab Helm chart is made up of multiple subcharts,
which provide the core GitLab components:

- [Gitaly](gitaly/index.md)
- [GitLab Exporter](gitlab-exporter/index.md)
- [GitLab Pages](gitlab-pages/index.md)
- [GitLab Runner](gitlab-runner/index.md)
- [GitLab Shell](gitlab-shell/index.md)
- [GitLab agent server (KAS)](kas/index.md)
- [Mailroom](mailroom/index.md)
- [Migrations](migrations/index.md)
- [Praefect](praefect/index.md)
- [Sidekiq](sidekiq/index.md)
- [Spamcheck](spamcheck/index.md)
- [Toolbox](toolbox/index.md)
- [Webservice](webservice/index.md)

The parameters for each subchart must be under the `gitlab` key. For example,
GitLab Shell parameters would be similar to:

```yaml
gitlab:
  gitlab-shell:
    ...
```

Use these charts for optional dependencies:

- [MinIO](../minio/index.md)
- [NGINX](../nginx/index.md)
- [HAProxy](../haproxy/index.md)
- [PostgreSQL](https://artifacthub.io/packages/helm/bitnami/postgresql)
- [Redis](https://artifacthub.io/packages/helm/bitnami/redis)
- [Registry](../registry/index.md)
- [Traefik](../traefik/index.md)

Use these charts as optional additions:

- [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus)
- [_Unprivileged_](https://docs.gitlab.com/runner/install/kubernetes.html#running-docker-in-docker-containers-with-gitlab-runner) [GitLab Runner](https://docs.gitlab.com/runner/) that uses the Kubernetes executor
- Automatically provisioned SSL from [Let's Encrypt](https://letsencrypt.org/), which uses [Jetstack](https://venafi.com/jetstack-consult/)'s [cert-manager](https://cert-manager.io/docs/) with [certmanager-issuer](../certmanager-issuer/index.md)

## GitLab Helm subchart optional parameters

### affinity

> - [Introduced](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3770) in GitLab 17.3 (Charts 8.3) for all GitLab Helm subcharts except `webservice` and `sidekiq`.

`affinity` is an optional parameter in all GitLab Helm subcharts. When you set it, it takes precedence over the [global `affinity`](../globals.md#affinity) value.
For more information about `affinity`, see [the relevant Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity).

NOTE:
The `webservice` and `sidekiq` Helm charts can only use the [global `affinity`](../globals.md#affinity) value. Follow [issue 25403](https://gitlab.com/gitlab-com/gl-infra/production-engineering/-/issues/25403) to learn when the local `affinity` is implemented for `webservice` and `sidekiq`.

With `affinity`, you can set either or both:

- `podAntiAffinity` rules to:
  - Not schedule pods in the same domain as the pods that match the expression corresponding to the `topology key`.
  - Set two modes of `podAntiAffinity` rules: required (`requiredDuringSchedulingIgnoredDuringExecution`) and preferred
    (`preferredDuringSchedulingIgnoredDuringExecution`). Using the variable `antiAffinity` in `values.yaml`, set the setting to `soft` so that the preferred mode is
    applied or set it to `hard` so that the required mode is applied.
- `nodeAffinity` rules to:
  - Schedule pods to nodes that belong to a specific zone or zones.
  - Set two modes of `nodeAffinity` rules: required (`requiredDuringSchedulingIgnoredDuringExecution`) and preferred
    (`preferredDuringSchedulingIgnoredDuringExecution`). When set to `soft`, the preferred mode is applied. When set to `hard`, the required mode is applied. This
    rule is implemented only for the `registry` chart and the `gitlab` chart alongwith all its subcharts except `webservice` and `sidekiq`.

`nodeAffinity` only implements the [`In` operator](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#operators).

The following example sets `affinity`, with both `nodeAffinity` and `antiAffinity` set to `hard`:

```yaml
nodeAffinity: "hard"
antiAffinity: "hard"
affinity:
  nodeAffinity:
    key: "test.com/zone"
    values:
    - us-east1-a
    - us-east1-b
  podAntiAffinity:
    topologyKey: "test.com/hostname"
```
