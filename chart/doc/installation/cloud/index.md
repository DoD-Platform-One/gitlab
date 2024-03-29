---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Cloud provider setup for the GitLab chart

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

Before you deploy the GitLab chart, you must configure resources for
the cloud provider you choose.

The GitLab chart is intended to fit in a cluster with at least 8 vCPU
and 30 GB of RAM. If you are trying to deploy a non-production instance,
you can reduce the defaults to fit into a smaller cluster.

## Supported Kubernetes releases

The GitLab Helm chart supports the following Kubernetes releases:

| Kubernetes release | Status                                                                             | Minimum GitLab version | Architectures | End of life |
|--------------------|------------------------------------------------------------------------------------|------------------------|---------------|-------------|
| 1.27               | [In development/qualification](https://gitlab.com/groups/gitlab-org/-/epics/11320) | 16.6                   | x86-64        | 2024-06-28  |
| 1.26               | Supported                                                                          | 16.5                   | x86-64        | 2024-02-28  |
| 1.25               | Deprecated                                                                         | 16.5                   | x86-64        | 2023-10-28  |
| 1.24               | Deprecated                                                                         | 16.5                   | x86-64        | 2023-07-28  |
| 1.23               | Deprecated                                                                         | 16.5                   | x86-64        | 2023-02-28  |
| 1.22               | Deprecated                                                                         | 16.5                   | x86-64        | 2022-10-28  |

The GitLab Helm Chart aims to support new minor Kubernetes releases three months after their initial release.
We welcome reports made to our [issue tracker](https://gitlab.com/gitlab-org/charts/gitlab/-/issues) about compatibility issues in releases newer than those listed above.

Some GitLab features might not work on deprecated releases or releases older than the releases listed above.

For some components, like the [agent for Kubernetes](https://docs.gitlab.com/ee/user/clusters/agent/#gitlab-agent-for-kubernetes-supported-cluster-versions) and [GitLab Operator](https://docs.gitlab.com/operator/installation.html#kubernetes), GitLab might support different cluster releases.

WARNING:
Kubernetes nodes must use the x86-64 architecture.
Support for multiple architectures, including AArch64/ARM64, is under active development.
See [issue 2899](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2899) for more information.

- For cluster topology recommendations for an environment, see the
  [reference architectures](https://docs.gitlab.com/ee/administration/reference_architectures/#available-reference-architectures).
- For an example of tuning the resources to fit in a 3 vCPU 12 GB cluster, see the
  [minimal GKE example values file](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/values-gke-minimum.yaml).

## Instructions for specific Cloud providers

Create and connect to a Kubernetes cluster in your environment:

- [Azure Kubernetes Service](aks.md)
- [Amazon EKS](eks.md)
- [Google Kubernetes Engine](gke.md)
- [OpenShift](openshift.md)
- [Oracle Container Engine for Kubernetes](oke.md)
