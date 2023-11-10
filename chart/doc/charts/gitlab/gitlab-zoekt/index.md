---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the GitLab-Zoekt chart **(PREMIUM SELF)**

The Zoekt integration provides support for
[Exact code search](https://docs.gitlab.com/ee/user/search/exact_code_search.html).
This can be installed by setting `gitlab-zoekt.install` to `true`. For now
this does not configure GitLab to automatically discover Zoekt and this feature
is experimental and disabled by default. More details on configuration can be
found in the
[`gitlab-zoekt` chart](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt).

## GitLab integration

To enable Zoekt for a top level group:

1. Connect to the Rails console of the toolbox pod:

   ```shell
   kubectl exec <Toolbox pod name> -it -c toolbox -- gitlab-rails console -e production
   ```

1. Enable the Zoekt feature flags:

   ```shell
   ::Feature.enable(:index_code_with_zoekt)
   ::Feature.enable(:search_code_with_zoekt)
   ```

1. Setup indexing:

   ```shell
   # create shard using the Zoekt ClusterIP Service
   shard = ::Zoekt::Shard.find_or_create_by!(index_base_url: 'http://<release>-gitlab-zoekt:8080', search_base_url: 'http://<release>-gitlab-zoekt:8080')
   # use the name of your top level group
   group = '<top-level-group-to-index>'
   namespace = Namespace.find_by_full_path(group)
   ::Zoekt::IndexedNamespace.find_or_create_by!(shard: shard, namespace: namespace.root_ancestor)
   ```

1. Zoekt will now index projects after they are updated or created.
