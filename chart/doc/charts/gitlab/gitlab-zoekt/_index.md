---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Zoekt chart
---

{{< details >}}

- Tier: Premium, Ultimate
- Offering: GitLab.com, GitLab Self-Managed
- Status: Beta

{{< /details >}}

{{< history >}}

- [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/105049) as a [beta](https://docs.gitlab.com/policy/development_stages_support/#beta) in GitLab 15.9 [with flags](https://docs.gitlab.com/administration/feature_flags/) named `index_code_with_zoekt` and `search_code_with_zoekt`. Disabled by default.
- [Enabled on GitLab.com](https://gitlab.com/gitlab-org/gitlab/-/issues/388519) in GitLab 16.6.
- Feature flags `index_code_with_zoekt` and `search_code_with_zoekt` [removed](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/148378) in GitLab 17.1.

{{< /history >}}

{{< alert type="warning" >}}

This feature is in [beta](https://docs.gitlab.com/policy/development_stages_support/#beta) and subject to change without notice.
For more information, see [epic 9404](https://gitlab.com/groups/gitlab-org/-/epics/9404).

{{< /alert >}}

## Zoekt chart with a Linux package instance

Use the Zoekt chart to connect Zoekt to a Linux package instance.

Prerequisites:

- A dedicated Zoekt cluster based on current [sizing recommendations](https://docs.gitlab.com/integration/exact_code_search/zoekt/#sizing-recommendations).

To use the Zoekt chart with a Linux package instance:

1. Create a namespace called `zoekt`:

   ```shell
   kubectl create namespace zoekt
   ```

1. Clone the [`gitlab-zoekt` chart](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt/) locally and change to its directory:

   ```shell
   git clone https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt.git
   cd gitlab-zoekt
   ```

1. [Enable a load balancer](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt/-/blob/v2.7.0/doc/load_balancer.md).
   Because the Zoekt chart is a headless service, a load balancer is required.

1. In `values.yaml`:

   1. Use the `gitlab_shell` secret from the `/etc/gitlab/gitlab-secrets.json` file to create the `kubectl` secret:

      ```shell
      kubectl create secret generic gitlab-zoekt-secret --from-literal=secret-key="<gitlab-shell-secret>" -n zoekt
      ```

   1. Add the secret:

      ```yaml
      internalApi:
       secretName: 'gitlab-zoekt-secret'
       secretKey: 'secret-key'
      ```

   1. Add the GitLab instance URL and service URL with a load balancer IP port of `:8080`:

      ```yaml
       internalApi:
         gitlabUrl: 'https://<gitlab_url>' # Internal URL to connect to GitLab
         serviceUrl: 'http://<loadbalancer_internal_ip>:8080' # URL to reach Zoekt service - LB internal URL
      ```

1. In GitLab, [change the Gitaly listening interface](https://docs.gitlab.com/administration/gitaly/configure_gitaly/#change-the-gitaly-listening-interface):

   ```ruby
   gitaly['configuration'] = {
     listen_addr: '0.0.0.0:8075',
     storage: [
       {
         name: 'default',
         path: '/var/opt/gitlab/git-data/repositories',
       },
     ]
   }
   gitlab_rails['repositories_storages'] = {
     'default'  => { 'gitaly_address' => 'tcp://<gitlab_url>:8075' },
   }
   ```

1. Install Zoekt by using `helm`:

   ```shell
   helm install gitlab-zoekt . -f values.yaml --version <latest_version> --namespace zoekt
   ```

1. Confirm the pods were created. You should have both the gateway and `gitlab-zoekt-0` pods:

   ```shell
   kubectl get pods
   NAME                                  READY   STATUS    RESTARTS   AGE
   gitlab-zoekt-0                        3/3     Running   0          13d
   gitlab-zoekt-gateway-b78dbc78-hzw28   1/1     Running   0          13d
   ```

   Install or upgrade the GitLab Helm chart if you make further changes to `values.yaml`.

1. [Enable exact code search](https://docs.gitlab.com/integration/zoekt/#enable-exact-code-search).
1. Set up indexing:

   ```ruby
   node = ::Search::Zoekt::Node.online.last
   namespace = Namespace.find_by_full_path('<top-level-group-to-index>')
   enabled_namespace = Search::Zoekt::EnabledNamespace.find_or_create_by(namespace: namespace)
   replica = enabled_namespace.replicas.find_or_create_by(namespace_id: enabled_namespace.root_namespace_id)
   node.indices.create!(zoekt_enabled_namespace_id: enabled_namespace.id, namespace_id: namespace.id, zoekt_replica_id: replica.id)
   ```

## Zoekt chart with the GitLab Helm chart

The Zoekt chart provides support for
[exact code search](https://docs.gitlab.com/user/search/exact_code_search/).
You can install the chart by setting `gitlab-zoekt.install` to `true`.
For more information, see [`gitlab-zoekt`](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt).

### Enable the Zoekt chart

To enable the Zoekt chart, set the following values:

```shell
--set gitlab-zoekt.install=true \
--set gitlab-zoekt.replicas=2 \         # Number of Zoekt pods. If you want to use only one pod, you can skip this setting.
--set gitlab-zoekt.indexStorage=128Gi   # Disk size for the Zoekt node. Zoekt requires up to three times the repository's default branch's storage size, depending on the number of large and binary files.
```

### Set CPU and memory usage

You can define requests and limits for the Zoekt chart by modifying the GitLab.com [default settings](https://gitlab.com/gitlab-com/gl-infra/k8s-workloads/gitlab-com/-/blob/master/releases/gitlab/values/gprd.yaml.gotmpl#L6-45).

## Configure Zoekt in GitLab

{{< history >}}

- Shards [renamed](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/134717) to nodes in GitLab 16.6.

{{< /history >}}

To configure Zoekt for a top-level group in GitLab:

1. Connect to the Rails console of the toolbox pod:

   ```shell
   kubectl exec <toolbox pod name> -it -c toolbox -- gitlab-rails console -e production
   ```

1. [Enable exact code search](https://docs.gitlab.com/integration/zoekt/#enable-exact-code-search).
1. Set up indexing:

   {{< tabs >}}

   {{< tab title="GitLab 17.7 and later" >}}

   ```shell
   node = ::Search::Zoekt::Node.online.last
   namespace = Namespace.find_by_full_path('<top-level-group-to-index>')
   enabled_namespace = Search::Zoekt::EnabledNamespace.find_or_create_by(namespace: namespace)
   replica = enabled_namespace.replicas.find_or_create_by(namespace_id: enabled_namespace.root_namespace_id)
   node.indices.create!(zoekt_enabled_namespace_id: enabled_namespace.id, namespace_id: namespace.id, zoekt_replica_id: replica.id)
   ```

   {{< /tab >}}

   {{< tab title="GitLab 17.6 and earlier" >}}

   ```shell
   node = ::Search::Zoekt::Node.online.last
   namespace = Namespace.find_by_full_path('<top-level-group-to-index>')
   enabled_namespace = Search::Zoekt::EnabledNamespace.find_or_create_by(namespace: namespace)
   replica = enabled_namespace.replicas.find_or_create_by(namespace_id: enabled_namespace.root_namespace_id)
   replica.ready!
   node.indices.create!(zoekt_enabled_namespace_id: enabled_namespace.id, namespace_id: namespace.id, zoekt_replica_id: replica.id, state: :ready)
   ```

      {{< /tab >}}

   {{< /tabs >}}

Zoekt can now index projects in that group after any project is updated or created. For the initial indexing, wait at least a few minutes for Zoekt to start indexing the namespace.
