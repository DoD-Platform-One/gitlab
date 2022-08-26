---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Preparation for installing on cloud based providers **(FREE SELF)**

The resource requests, and number of replicas for the GitLab components (not PostgreSQL, Redis, or MinIO) in the GitLab chart
are set by default to be adequate for a small production deployment. This is intended to fit in a cluster with at least 8vCPU
and 30gb of RAM. If you are trying to deploy a non-production instance, you can reduce the defaults in order to fit into
a smaller cluster.
Refer to the [Cloud Native Hybrid reference architectures](https://docs.gitlab.com/ee/administration/reference_architectures/#available-reference-architectures) for cluster topology recommendations for an environment.
The [minimal GKE example values file](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/values-gke-minimum.yaml) provides an example of tuning the resources
to fit within a 3vCPU 12gb cluster.

A Kubernetes cluster, version 1.16 through 1.21 is required due to the usage of certain
Kubernetes features. Support for Kubernetes 1.22 is under active development, see
[epic &6883](https://gitlab.com/groups/gitlab-org/-/epics/6883) for more information.

NOTE:
If using the in-chart NGINX Ingress Controller (`nginx-ingress.enabled=true`),
then Kubernetes 1.19 or newer is required.

Create and connect to the Kubernetes cluster in the environment you choose:

- [Azure Kubernetes Service](aks.md)
- [Amazon EKS](eks.md)
- [Google Kubernetes Engine](gke.md)
- [OpenShift](openshift.md)
- [Oracle Container Engine for Kubernetes](oke.md)
