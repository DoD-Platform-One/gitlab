---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Installing GitLab using Helm

Install GitLab on Kubernetes with the cloud native GitLab Helm chart.

## Requirements

In order to deploy GitLab on Kubernetes, the following are required:

1. kubectl 1.13 or higher, compatible with your cluster
   ([+/- 1 minor release from your cluster](https://kubernetes.io/docs/tasks/tools/)).
1. Helm v3 (3.2.0 or higher).
1. A Kubernetes cluster, version 1.13 or higher. 8vCPU and 30GB of RAM is recommended.

NOTE:
Helm v2 has reached end of lifecyle. If GitLab has been previously installed
with Helm v2, you should use Helm v3 as soon as possible. Please consult
the [Helm migration document](migration/helm.md).

## Environment setup

Before proceeding to deploying GitLab, you need to prepare your environment.

### Tools

`helm` and `kubectl` need to be [installed on your computer](tools.md).

### Cloud cluster preparation

NOTE:
[Kubernetes 1.13 or higher is required](#requirements), due to the usage of certain
Kubernetes features.

Follow the instructions to create and connect to the Kubernetes cluster of your
choice:

- [Google Kubernetes Engine](cloud/gke.md)
- [Amazon EKS](cloud/eks.md)
- [OpenShift Origin](cloud/openshift.md)
- [Azure Kubernetes Service](cloud/aks.md)
- VMware Tanzu - Documentation to be added.
- On-Premises solutions - Documentation to be added.

## Deploying GitLab

With the environment set up and configuration generated, you can now proceed to
the [deployment of GitLab](deployment.md).

## Upgrading GitLab

If you are upgrading an existing Kubernetes installation, follow the
[upgrade documentation](upgrade.md) instead.

## Migrating from Omnibus GitLab to Kubernetes

To migrate your existing Omnibus GitLab instance to your Kubernetes cluster,
follow the [migration documentation](migration/index.md).
