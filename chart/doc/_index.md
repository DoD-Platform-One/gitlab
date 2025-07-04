---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: GitLab Helm chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

To install a cloud-native version of GitLab, use the GitLab Helm chart.
This chart contains all the required components to get started and can scale to large deployments.

For OpenShift-based installations, use [GitLab Operator](https://docs.gitlab.com/operator/),
otherwise you must update the [security context constraints](https://docs.gitlab.com/operator/security_context_constraints.html)
yourself.

{{< alert type="warning" >}}

The default Helm chart configuration is **not intended for production**.
The default values create an implementation where _all_ GitLab services are
deployed in the cluster, which is **not suitable for production workloads**.
For production deployments, you **must** follow the [Cloud Native Hybrid reference architectures](installation/_index.md#use-the-reference-architectures).

{{< /alert >}}

For a production deployment, you should have strong working knowledge of Kubernetes.
This method of deployment has different management, observability, and concepts than traditional deployments.

The GitLab Helm chart is made up of multiple [subcharts](charts/gitlab/_index.md),
each of which can be installed separately.

## Learn more

- [Test the GitLab chart on GKE or EKS](quickstart/_index.md)
- [Migrate from using the Linux package to the GitLab chart](installation/migration/_index.md)
- [Prepare to deploy](installation/_index.md)
- [Deploy](installation/deployment.md)
- [View deployment options](installation/command-line-options.md)
- [Configure globals](charts/globals.md)
- [View the subcharts](charts/gitlab/_index.md)
- [View advanced configuration options](advanced/_index.md)
- [View architectural decisions](architecture/_index.md)
- Contribute to development by viewing the [developer documentation](development/_index.md) and
  [contribution guidelines](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/CONTRIBUTING.md)
- Create an [issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues)
- Create a [merge request](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests)
- View [troubleshooting](troubleshooting/_index.md) information
