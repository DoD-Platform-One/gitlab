# Node Affinity & Anti-Affinity with Gitlab

Affinity is exposed through values options for the Gitlab. If you want to schedule your pods to deploy on specific nodes you can do that through the `nodeSelector` and `global.antiAffinity` values. Additional info can be found in [Gitlab documentation](https://docs.gitlab.com/charts/charts/globals/#affinity).

For additional information on Affinity and Anti-Affinity, review the [Kubernetes documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity).
