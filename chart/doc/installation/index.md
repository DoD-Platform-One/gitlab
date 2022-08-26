---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Installing GitLab using Helm **(FREE SELF)**

Install GitLab on Kubernetes with the cloud native GitLab Helm chart.

## Important considerations

The following considerations should be well noted for implementing production GitLab environments.

### Default Helm chart configuration not intended for production

Installing GitLab using only the Helm charts creates a proof of concept (POC) implementation where all GitLab services are placed into the cluster. GitLab Cloud Native Hybrid Reference Architectures specify that the stateful components such as PostgreSQL or Gitaly (Git repository storage dataplane) run outside the cluster on PaaS or compute instances. This is required in order to scale and reliably service the many varieties of workloads found in production GitLab environments. Additionally it is allowable, and generally preferable, to take advantage of Cloud PaaS for PostgreSQL, Redis, and object storage for all non-Git repository storages.

### Configure Helm charts to external stateful data

The GitLab Helm charts [can be configured](../charts/) to point to external stateful storage for items such as the PostgreSQL, Redis, all Non-Git repository storage as well as Git repository storage (Gitaly). The Infrastructure as Code (IaC) options below use this approach. For production-grade implementation the appropriate chart parameters should be used to point to prebuilt, externalized state stores that align with the chosen [Reference Architecture](https://docs.gitlab.com/ee/administration/reference_architectures/).

### Use GitLab Cloud Native Hybrid Reference Architectures

The Reference Architecture for deploying GitLab instances to Kubernetes is called Cloud Native Hybrid specifically because not all GitLab services can run in the cluster for production-grade implementations. Each Cloud Native Hybrid Reference Architecture is detailed within the overall architecture page. For instance, here is the [Cloud Native Hybrid reference architecture](https://docs.gitlab.com/ee/administration/reference_architectures/3k_users.html#cloud-native-hybrid-reference-architecture-with-helm-charts-alternative) alternative for the 3,000 user count.

### GitLab Cloud Native Hybrid deployment with Infrastructure as Code (IaC) and builder resources

GitLab develops Infrastructure as Code that is capable of configuring the combination of Helm charts and supplemental cloud infrastructure:

- [GitLab Environment Toolkit IaC](https://gitlab.com/gitlab-org/quality/gitlab-environment-toolkit).
- [AWS Quick Start for GitLab Cloud Native Hybrid on EKS IaC](https://docs.gitlab.com/ee/install/aws/gitlab_hybrid_on_aws.html#available-infrastructure-as-code-for-gitlab-cloud-native-hybrid) - this tooling is under development, for GA status please follow this issue: [AWS Quick Start for GitLab Cloud Native Hybrid on EKS Status](https://gitlab.com/gitlab-com/alliances/aws/public-tracker/-/issues/11)
- [Implementation Pattern: Provision GitLab Cloud Native Hybrid on AWS EKS](https://docs.gitlab.com/ee/install/aws/gitlab_hybrid_on_aws.html) - regardless of how you are building Cloud Native Hybrid, this resource provides a Bill of Materials tested with GitLab Performance Toolkit and budgets using AWS Cost Calculator.

## Prerequisites

To deploy GitLab on Kubernetes, you must first install the [prerequisites](tools.md).

## Deploying GitLab

With the environment set up and configuration generated, you can now proceed to
the [deployment of GitLab](deployment.md).

## Upgrading GitLab

If you are upgrading an existing Kubernetes installation, follow the
[upgrade documentation](upgrade.md) instead.

## Migrate from or to the GitLab Helm chart

To migrate your existing GitLab Linux package installation to your Kubernetes cluster,
or vice versa, follow the [migration documentation](migration/index.md).
