---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Cloud provider setup for the GitLab chart **(FREE SELF)**

Before you deploy the GitLab chart, you must configure resources for
the cloud provider you choose.

The GitLab chart is intended to fit in a cluster with at least 8 vCPU
and 30 GB of RAM. If you are trying to deploy a non-production instance,
you can reduce the defaults to fit into a smaller cluster.

## Supported Kubernetes versions

The GitLab Helm chart supports the following Kubernetes versions:

- A cluster running Kubernetes 1.20 or newer is required for all components to work.
- 1.26 support is fully tested as of Chart 7.5 (GitLab 16.5).
- 1.27 and 1.28 are expected to also be compatible with Chart 7.6 (GitLab 16.6), and full testing is [in progress](https://gitlab.com/groups/gitlab-org/-/epics/11320).

The GitLab Helm Chart aims to support new minor Kubernetes versions three months after their initial release.
We welcome any compatibility issues with releases newer than those listed above in our [issue tracker](https://gitlab.com/gitlab-org/charts/gitlab/-/issues).

Some GitLab features might not work on versions older than the versions listed above.

For some components, like the [agent for Kubernetes](https://docs.gitlab.com/ee/user/clusters/agent/#gitlab-agent-for-kubernetes-supported-cluster-versions) and [GitLab Operator](https://docs.gitlab.com/operator/installation.html#kubernetes), GitLab might support different cluster versions.

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
