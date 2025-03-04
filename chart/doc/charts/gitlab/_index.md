---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GitLab Helm subcharts
---

The GitLab Helm chart is made up of multiple subcharts,
which provide the core GitLab components:

- [Gitaly](gitaly/_index.md)
- [GitLab Exporter](gitlab-exporter/_index.md)
- [GitLab Pages](gitlab-pages/_index.md)
- [GitLab Runner](gitlab-runner/_index.md)
- [GitLab Shell](gitlab-shell/_index.md)
- [GitLab agent server (KAS)](kas/_index.md)
- [Mailroom](mailroom/_index.md)
- [Migrations](migrations/_index.md)
- [Praefect](praefect/_index.md)
- [Sidekiq](sidekiq/_index.md)
- [Spamcheck](spamcheck/_index.md)
- [Toolbox](toolbox/_index.md)
- [Webservice](webservice/_index.md)

The parameters for each subchart must be under the `gitlab` key. For example,
GitLab Shell parameters would be similar to:

```yaml
gitlab:
  gitlab-shell:
    ...
```

Use these charts for optional dependencies:

- [MinIO](../minio/_index.md)
- [NGINX](../nginx/_index.md)
- [HAProxy](../haproxy/_index.md)
- [PostgreSQL](https://artifacthub.io/packages/helm/bitnami/postgresql)
- [Redis](https://artifacthub.io/packages/helm/bitnami/redis)
- [Registry](../registry/_index.md)
- [Traefik](../traefik/_index.md)

Use these charts as optional additions:

- [Prometheus](https://artifacthub.io/packages/helm/prometheus-community/prometheus)
- [_Unprivileged_](https://docs.gitlab.com/runner/install/kubernetes.html#running-docker-in-docker-containers-with-gitlab-runner) [GitLab Runner](https://docs.gitlab.com/runner/) that uses the Kubernetes executor
- Automatically provisioned SSL from [Let's Encrypt](https://letsencrypt.org/), which uses [Jetstack](https://venafi.com/jetstack-consult/)'s [cert-manager](https://cert-manager.io/docs/) with [certmanager-issuer](../certmanager-issuer/_index.md)

## GitLab Helm subchart optional parameters

### affinity

{{< history >}}

- [Introduced](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests/3770) in GitLab 17.3 (Charts 8.3) for all GitLab Helm subcharts except `webservice` and `sidekiq`.

{{< /history >}}

`affinity` is an optional parameter in all GitLab Helm subcharts. When you set it, it takes precedence over the [global `affinity`](../globals.md#affinity) value.
For more information about `affinity`, see [the relevant Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity).

{{< alert type="note" >}}

The `webservice` and `sidekiq` Helm charts can only use the [global `affinity`](../globals.md#affinity) value. Follow [issue 25403](https://gitlab.com/gitlab-com/gl-infra/production-engineering/-/issues/25403) to learn when the local `affinity` is implemented for `webservice` and `sidekiq`.

{{< /alert >}}

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
