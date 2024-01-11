---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Using the GitLab-Zoekt chart **(PREMIUM SELF EXPERIMENT)**

FLAG:
On self-managed GitLab, by default this feature is not available.
To make it available, an administrator can enable the feature flags named `index_code_with_zoekt` and `search_code_with_zoekt`.
On GitLab.com, this feature is not available. This feature is not ready for production use.

WARNING:
This feature is an [Experiment](https://docs.gitlab.com/ee/policy/experiment-beta-support.html#experiment).
GitLab Support cannot assist with configuring or troubleshooting the
`gitlab-zoekt` chart. For more information, see
[exact code search](https://docs.gitlab.com/ee/user/search/exact_code_search.html).

The Zoekt integration provides support for
[exact code search](https://docs.gitlab.com/ee/user/search/exact_code_search.html).
You can install the integration by setting `gitlab-zoekt.install` to `true`.
This setting does not configure GitLab to automatically discover Zoekt.
For more information, see the [`gitlab-zoekt` chart](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt).

## GitLab integration

> Shards [renamed](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/134717) to nodes in GitLab 16.6.

To enable Zoekt for a top-level group:

1. Connect to the Rails console of the Toolbox Pod:

   ```shell
   kubectl exec <Toolbox pod name> -it -c toolbox -- gitlab-rails console -e production
   ```

1. Enable the Zoekt feature flags:

   ```shell
   ::Feature.enable(:index_code_with_zoekt)
   ::Feature.enable(:search_code_with_zoekt)
   ```

1. Set up indexing:

   ```shell
   # Create a Zoekt node with the Zoekt ClusterIP Service
   node = ::Search::Zoekt::Node.find_or_create_by!(index_base_url: 'http://<release>-gitlab-zoekt:8080', search_base_url: 'http://<release>-gitlab-zoekt:8080', uuid: '00000000-0000-0000-0000-000000000000')
   # Use the name of your top-level group
   group = '<top-level-group-to-index>'
   namespace = Namespace.find_by_full_path(group)
   node.indexed_namespaces.find_or_create_by!(namespace: namespace.root_ancestor)
   ```

Zoekt can now index projects after they are updated or created.
