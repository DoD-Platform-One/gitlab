---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# GitLab Helm chart **(FREE SELF)**

To install a cloud-native version of GitLab, use the GitLab Helm chart.
This chart contains all the required components to get started and can scale to large deployments.

Use this installation method if your infrastructure is built
on Kubernetes and you're familiar with how it works. This method of deployment has different
management, observability, and concepts than traditional deployments.

The GitLab Helm chart includes all the components for a complete deployment.
However, the **default chart is for proof-of-concept deployments only**.
For production deployments, additional setup and configuration is required.
[View details](installation/index.md).

The GitLab Helm chart is made up of multiple [subcharts](charts/gitlab/index.md),
each of which can be installed separately.

## Learn more

- [Test the GitLab chart on GKE or EKS](quickstart/index.md)
- [Migrate from Omnibus to the GitLab chart](installation/migration/index.md)
- [Prepare to deploy](installation/index.md)
- [Deploy](installation/deployment.md)
- [View deployment options](installation/command-line-options.md)
- [Configure globals](charts/globals.md)
- [View the subcharts](charts/gitlab/index.md)
- [View advanced configuration options](advanced/index.md)
- [View architectural decisions](architecture/index.md)
- Contribute to development by viewing the [developer documentation](development/index.md) and
  [contribution guidelines](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/CONTRIBUTING.md)
- Create an [issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues)
- Create a [merge request](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests)
- View [troubleshooting](troubleshooting/index.md) information
