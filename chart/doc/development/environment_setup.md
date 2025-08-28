---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Environment setup
---

To set up for charts development, command line tools and a
Kubernetes cluster are required.

## Required developer tools

The minimum tools required for charts development are documented on the [Required tools page](../installation/tools.md).

You should use [`asdf`](https://github.com/asdf-vm/asdf) to install these tools.
This allows us to easily switch between versions, such as different kubectl or Helm versions.

We provide a [`.tool-versions` file](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/.tool-versions)
that specifies these tools with their recommended versions. To install or update them:

1. Clone the charts repository and change directory:

   ```shell
   git clone https://gitlab.com/gitlab-org/charts/gitlab.git charts-gitlab
   cd charts-gitlab/
   ```

1. Add each plugin repository. This only has to be done once:

   ```shell
   asdf plugin add minikube
   asdf plugin add kubectl
   asdf plugin add helm
   asdf plugin add stern
   asdf plugin add vale
   asdf plugin add gomplate
   ```

1. Install or update the tools:

   ```shell
   asdf install
   ```

### Additional developer tools

Developers working on charts also often use the following tools:

| Tool name                                                                  | Benefits                                                                | Example use case |
|----------------------------------------------------------------------------|-------------------------------------------------------------------------|------------------|
| [`asdf`](https://github.com/asdf-vm/asdf)                                  | Easily switch between versions of your favorite runtimes and CLI tools. | Switching between Helm 3.7 and Helm 3.9 binaries. |
| [`kubectx` & `kubens`](https://github.com/ahmetb/kubectx)                  | Manage and switch between Kubernetes contexts and namespaces.           | Setting default namespace per selected cluster context. |
| [`k3s`](https://k3s.io)                                                    | Lightweight Kubernetes installation (<40 MB).                           | Quick and reliable local chart testing. |
| [`k9s`](https://github.com/derailed/k9s)                                   | Greatly reduced typing of `kubectl` commands.                           | Navigate and manage cluster resources quickly in a command line interface. |
| [`lens`](https://k8slens.dev/)                                             | Highly visual management and navigation of clusters.                    | Navigate and manage cluster resources quickly in a standalone desktop application. |
| [`stern`](https://github.com/stern/stern)                                  | Easily follow logs from multiple pods.                                  | See logs from a set of GitLab pods together. |
| [`dive`](https://github.com/wagoodman/dive)                                | Explore container layers.                                               | A tool for exploring a container image, layer contents, and discovering ways to shrink the size of your Docker/OCI image. [GitLab Unfiltered](https://youtu.be/9kdE-ye6vlc) |
| [`container-diff`](https://github.com/GoogleContainerTools/container-diff) | Explore container layers.                                               | A tool for analyzing and comparing container images. |

## Kubernetes cluster

A cloud or local Kubernetes cluster may be used for development.
For simple issues, a local cluster is often enough to test deployments.
When dealing with networking, storage, or other complex issues, a cloud Kubernetes cluster allows you to more accurately recreate a production environment.

{{< alert type="warning" >}}

Official GitLab images are built with the x86-64 architecture.
For local development, Apple silicon users can use an [alternate Docker setup](kind/_index.md#apple-silicon-m1m2)
to emulate a compatible architecture.
Support for multiple architectures, including AArch64/ARM64, is under active development.
See [issue 2899](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2899) for more information.

{{< /alert >}}

### Local cluster

The following local cluster options are supported:

- [minikube](minikube/_index.md) - Cluster in virtual machines
- [KinD (Kubernetes in Docker)](kind/_index.md) - Cluster in Docker containers

### Cloud cluster

The following cloud cluster options are supported:

- [GKE](../installation/cloud/gke.md) - Google Kubernetes Engine, recommended
- [EKS](../installation/cloud/eks.md) - Amazon Elastic Kubernetes Service

## Installing from repository

Details on installing the chart from the Git repository can be found in the [developer deployment](deploy.md) documentation.

## Developer license

A [developer license](https://handbook.gitlab.com/handbook/engineering/developer-onboarding/#working-on-gitlab-ee-developer-licenses) can
be used for chart development to test features that are only functional in a licensed environment.

To use a developer license follow the [instructions for Enterprise licenses](../installation/secrets.md#initial-enterprise-license)
and connect your instance to the Staging Customers Portal.

```yaml
global:
  extraEnv:
    GITLAB_LICENSE_MODE: test
    CUSTOMER_PORTAL_URL: https://customers.staging.gitlab.com
```
