---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Zoekt chart

DETAILS:
**Tier:** Premium, Ultimate
**Offering:** Self-managed
**Status:** Experiment

> - [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/105049) in GitLab 15.9 [with flags](https://docs.gitlab.com/ee/administration/feature_flags.html) named `index_code_with_zoekt` and `search_code_with_zoekt`. Disabled by default.
> - [Enabled on GitLab.com](https://gitlab.com/gitlab-org/gitlab/-/issues/388519) in GitLab 16.6.

FLAG:
On self-managed GitLab, by default this feature is not available.
To make it available, an administrator can [enable the feature flags](https://docs.gitlab.com/ee/administration/feature_flags.html) named `index_code_with_zoekt` and `search_code_with_zoekt`.
On GitLab.com, this feature is available.

WARNING:
This feature is an [Experiment](https://docs.gitlab.com/ee/policy/experiment-beta-support.html#experiment).
GitLab Support cannot assist with configuring or troubleshooting the Zoekt chart.

The Zoekt chart provides support for
[exact code search](https://docs.gitlab.com/ee/user/search/exact_code_search.html).
You can install the chart by setting `gitlab-zoekt.install` to `true`.
For more information, see [`gitlab-zoekt`](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt).

## Enable the Zoekt chart

To enable the Zoekt chart, set the following values:

```shell
--set gitlab-zoekt.install=true \
--set gitlab-zoekt.replicas=2 \         # Number of Zoekt pods. If you want to use only one pod, you can skip this setting.
--set gitlab-zoekt.indexStorage=128Gi   # Zoekt node disk size. Zoekt uses about three times the repository storage.
```

## Set CPU and memory usage

You can define requests and limits for the Zoekt chart by modifying the following GitLab.com default settings:

```yaml
  webserver:
    resources:
      requests:
        cpu: 4
        memory: 32Gi
      limits:
        cpu: 16
        memory: 128Gi
  indexer:
    resources:
      requests:
        cpu: 4
        memory: 6Gi
      limits:
        cpu: 16
        memory: 12Gi
  gateway:
    resources:
      requests:
        cpu: 2
        memory: 512Mi
      limits:
        cpu: 4
        memory: 1Gi
```

## Configure Zoekt in GitLab

> - Shards [renamed](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/134717) to nodes in GitLab 16.6.

To configure Zoekt for a top-level group in GitLab:

1. Connect to the Rails console of the toolbox pod:

   ```shell
   kubectl exec <toolbox pod name> -it -c toolbox -- gitlab-rails console -e production
   ```

1. Enable the feature flags for Zoekt:

   ```shell
   ::Feature.enable(:index_code_with_zoekt)
   ::Feature.enable(:search_code_with_zoekt)
   ```

1. Set up indexing:

   ```shell
   # Select one of the Zoekt nodes
   node = ::Search::Zoekt::Node.last
   # Use the name of your top-level group
   namespace = Namespace.find_by_full_path('<top-level-group-to-index>')
   enabled_namespace = Search::Zoekt::EnabledNamespace.find_or_create_by(namespace: namespace)
   node.indices.create!(zoekt_enabled_namespace_id: enabled_namespace.id, namespace_id: namespace.id, state: :ready)
   ```

Zoekt can now index projects in that group after any project is updated or created.
