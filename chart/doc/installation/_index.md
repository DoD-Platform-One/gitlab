---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Installing GitLab by using Helm
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

Install GitLab on Kubernetes by using the cloud native GitLab Helm chart.

Assuming you already have the [prerequisites](tools.md) installed and configured,
you can [deploy GitLab](deployment.md) with the `helm` command.

{{< alert type="warning" >}}

The default Helm chart configuration is **not intended for production**.
The default chart creates a proof of concept (PoC) implementation where all GitLab
services are deployed in the cluster. For production deployments, you must follow the
[Cloud Native Hybrid reference architecture](#use-the-reference-architectures).

{{< /alert >}}

For a production deployment, you should have strong working knowledge of Kubernetes.
This method of deployment has different management, observability, and concepts than traditional deployments.

In a production deployment:

- The stateful components, like PostgreSQL, Redis or Gitaly (a Git repository storage dataplane),
  must run outside the cluster on PaaS or compute instances. This configuration is required
  to scale and reliably service the variety of workloads found in production GitLab environments.
- You should use Cloud PaaS for PostgreSQL, Redis, and object storage for all non-Git repository storage.

If Kubernetes is not required for your GitLab instance, see the
[reference architectures](https://docs.gitlab.com/administration/reference_architectures/)
for simpler alternatives.

## Container images

The GitLab Helm chart uses the [Cloud Native GitLab (CNG)](https://gitlab.com/gitlab-org/build/CNG)
container images to deploy GitLab. Besides the CNG images for GitLab itself, the default configuration
uses images published by third parties (for example, Bitnami) to deploy PostgreSQL, Redis, and MinIO
to simplify non-production deployments.

Production instances should not deploy these (stateful) third party services
with the GitLab chart as mentioned above.

Refer to the following documentation for instructions on how to configure the chart to
use external services.

1. [External Database](../advanced/external-db/_index.md)
1. [External Redis](../advanced/external-redis/_index.md)
1. [External Object Storage](../advanced/external-object-storage/_index.md)

{{< alert type="note" >}}

Starting in December 2024, [Bitnami changed its build policy](https://github.com/bitnami/containers/issues/75671)
to update only the latest stable major version of each application in the free catalog. The GitLab chart
will continue to default to publicly available images.

In July 2025, [Bitnami announced](https://github.com/bitnami/containers/issues/75671) it will require
a subscription to Bitnami Secure Images, a paid offering, for users to get access to secure and
versioned charts and images.

As a result, the versions of these Bitnami charts configured by GitLab will fall out of date. Teams that deploy these Bitnami charts for non-production use should take care
to use appropriate up-to-date, patched images commensurate with their security requirements.

{{< /alert >}}

## Configure the Helm chart to use external stateful data

You can configure the GitLab Helm chart to point to external stateful storage
for items like PostgreSQL, Redis, all non-Git repository storage, and Git repository storage (Gitaly).

The following Infrastructure as Code (IaC) options use this approach.

For production-grade implementation, the appropriate chart parameters should be used to
point to prebuilt, externalized state stores that align with the chosen
[reference architecture](https://docs.gitlab.com/administration/reference_architectures/).

### Use the reference architectures

The reference architecture for deploying GitLab instances to Kubernetes is called [Cloud Native Hybrid](https://docs.gitlab.com/administration/reference_architectures/#cloud-native-hybrid) specifically because not all GitLab services can run in the cluster for production-grade implementations. All stateful GitLab components must be deployed outside the Kubernetes cluster.

Available Cloud Native Hybrid reference architectures sizes
are listed at [Reference architectures](https://docs.gitlab.com/administration/reference_architectures/#cloud-native-hybrid) page.
For example, here is the [Cloud Native Hybrid reference architecture](https://docs.gitlab.com/administration/reference_architectures/3k_users/#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative) for the 3,000 user count.

### Use Infrastructure as Code (IaC) and builder resources

GitLab develops Infrastructure as Code that is capable of configuring the combination of Helm charts and supplemental cloud infrastructure:

- [GitLab Environment Toolkit IaC](https://gitlab.com/gitlab-org/gitlab-environment-toolkit).
- [Implementation pattern: Provision GitLab cloud native hybrid on AWS EKS](https://docs.gitlab.com/solutions/cloud/aws/gitlab_instance_on_aws/):
  This resource provides a Bill of Materials tested with the GitLab Performance Toolkit,
  and uses the AWS Cost Calculator for budgeting.
