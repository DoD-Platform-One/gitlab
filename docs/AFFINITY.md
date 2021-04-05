# Node Affinity & Anti-Affinity with Gitlab

Affinity is exposed through values options for the Gitlab. If you want to schedule your pods to deploy on specific nodes you can do that through the `nodeSelector` and `global.antiAffinity` values. Additional info is provided below as well to help in configuring this.

It is good to have a basic knowledge of node affinity and available options to you before customizing in this way - the upstream kubernetes documentation [has a good walkthrough of this](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity).

## Values for Affinity

While you cannot specify full affinity with the Gitlab chart, node selector options are provided which give a simpler way to specify basic affinity. The `nodeSelector` value under each subchart should be used to specify affinity. The format to include follows what you'd specify at a [pod/deployment level](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#step-two-add-a-nodeselector-field-to-your-pod-configuration) for `nodeSelector`. See the example below for scheduling the pods only to nodes with the label `node-type` equal to `gitlab`:

```yaml
gitlab:
  task-runner:
    nodeSelector:
      node-type: gitlab
  gitlab-exporter:
    nodeSelector:
      node-type: gitlab
  migrations:
    nodeSelector:
      node-type: gitlab
  webservice:
    nodeSelector:
      node-type: gitlab
  sidekiq:
    nodeSelector:
      node-type: gitlab
  gitaly:
    nodeSelector:
      node-type: gitlab
  gitlab-shell:
    nodeSelector:
      node-type: gitlab
registry:
  nodeSelector:
    node-type: gitlab
```

## Values for Anti-Affinity

The `global.antiAffinity` value can be set to either `soft` or `hard` (soft = preferred, hard = required). This value defaults to `soft` to attempt to distribute replicas across nodes (without requiring it) - and will apply for all subcharts of Gitlab. To set a hard anti-affinity:

```yaml
global:
  antiAffinity: "hard"
```
