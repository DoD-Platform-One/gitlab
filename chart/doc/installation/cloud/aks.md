---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Preparing AKS resources for the GitLab chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

For a fully functional GitLab instance, you need a few resources before
deploying the GitLab chart to [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/what-is-aks).

## Creating the AKS cluster

To get started easier, a script is provided to automate the cluster creation.
Alternatively, a cluster can be created manually as well.

Prerequisites:

- Install the [prerequisites](../tools.md).
- Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
  and use it to [sign into Azure](https://learn.microsoft.com/en-us/cli/azure/get-started-with-azure-cli#how-to-sign-into-the-azure-cli).
- [Install `jq`](https://stedolan.github.io/jq/download/).

### Scripted cluster creation

A [bootstrap script](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/aks_bootstrap_script.sh) has been created to automate much of the setup process for users on Azure.

It reads an argument of `up`, `down` or `creds`, with additional optional parameters
from environment variables, or command line arguments:

- To create the cluster:

  ```shell
  ./scripts/aks_bootstrap_script.sh up
  ```

  This will:

  1. Create a new Resource Group (optional).
  1. Create a new AKS cluster.
  1. Create a new Public IP (optional).

- To clean up the created AKS resources:

  ```shell
  ./scripts/aks_bootstrap_script.sh down
  ```

  This will:

  1. Delete the specified Resource Group (optional).
  1. Delete the AKS cluster.
  1. Delete the Resource Group created by the cluster.

  The `down` argument will send the command to delete all resources and finish instantly. The actual deletion can take several minutes to complete.

- To connect `kubectl` to the cluster:

  ```shell
  ./scripts/aks_bootstrap_script.sh creds
  ```

The table below describes all available variables.

| Variable                  | Description                                                                         | Default value      | Scope    |
|---------------------------|-------------------------------------------------------------------------------------|--------------------|----------|
| `-g --resource-group`     | Name of the resource group to use.                                                  | `gitlab-resources` | All      |
| `-n --cluster-name`       | Name of the cluster to use.                                                         | `gitlab-cluster`   | All      |
| `-r --region`             | Region to install the cluster in.                                                   | `eastus`           | `up`     |
| `-v --cluster-version`    | Version of Kubernetes to use for creating the cluster.                              | Latest             | `up`     |
| `-c --node-count`         | Number of nodes to use.                                                             | `2`                | `up`     |
| `-s --node-vm-size`       | Type of nodes to use.                                                               | `Standard_D4s_v3`  | `up`     |
| `-p --public-ip-name`     | Name of the public IP to create.                                                    | `gitlab-ext-ip`    | `up`     |
| `--create-resource-group` | Create a new resource group to hold all created resources.                          | `false`            | `up`     |
| `--create-public-ip`      | Create a public IP to use with the new cluster.                                     | `false`            | `up`     |
| `--delete-resource-group` | Delete the resource group when using the down command.                              | `false`            | `down`   |
| `-f --kubctl-config-file` | Kubernetes configuration file to update. Use `-` to print YAML to `stdout` instead.   | `~/.kube/config`   | `creds`  |

### Manual cluster creation

A cluster with 8vCPU and 30GB of RAM is recommended.

For the most up to date instructions, follow Microsoft's
[AKS walkthrough](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-portal).

## External Access to GitLab

An external IP is required so that your cluster can be reachable. For the most up to date instructions, follow Microsoft's
[Create a static IP address](https://learn.microsoft.com/en-us/azure/aks/static-ip) guide.

## Next Steps

Continue with the [installation of the chart](../deployment.md) once you have
the cluster up and running, and the static IP and DNS entry ready.
