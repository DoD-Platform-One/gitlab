---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Preparing GKE resources for the GitLab chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

For a fully functional GitLab instance, you will need a few resources before
deploying the GitLab chart. The following is how these charts are deployed
and tested within GitLab.

## Creating the GKE cluster

To get started easier, a script is provided to automate the cluster creation.
Alternatively, a cluster can be created manually as well.

Prerequisites:

- Install the [prerequisites](../tools.md).
- Install the [Google SDK](https://cloud.google.com/sdk/docs/install).

### Scripted cluster creation

A [bootstrap script](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/gke_bootstrap_script.sh)
has been created to automate much of the setup process for users on GCP/GKE.

The script will:

1. Create a new GKE cluster.
1. Allow the cluster to modify DNS records.
1. Setup `kubectl`, and connect it to the cluster.

The script reads various parameters from environment variables and the argument
`up` for bootstrap or `down` for clean up.

The table below describes all variables.

| Variable              | Default value                     | Description |
|-----------------------|-----------------------------------|-------------|
| `ADMIN_USER`          | current gcloud user               | The user to assign cluster-admin access to during setup. |
| `AUTOSCALE_MAX_NODES` | `NUM_NODES`                       | The maximum number of nodes the autoscaler should scale up to. |
| `AUTOSCALE_MIN_NODES` | `0`                               | The minimum number of nodes the autoscaler should scale down to. |
| `CLUSTER_NAME`        | `gitlab-cluster`                  | The name of the cluster. |
| `CLUSTER_VERSION`     | GKE default, check the [GKE release notes](https://cloud.google.com/kubernetes-engine/docs/release-notes) | The version of your GKE cluster. |
| `INT_NETWORK`         | default                           | The IP space to use within this cluster. |
| `MACHINE_TYPE`        | `n2d-standard-4`                  | The cluster instances' type. |
| `NUM_NODES`           | `2`                               | The number of nodes required. |
| `PREEMPTIBLE`         | `false`                           | Cheaper, clusters live at *most* 24 hrs. No SLA on nodes/disks. |
| `PROJECT`             | No defaults, required to be set.  | The ID of your GCP project. |
| `RBAC_ENABLED`        | `true`                            | If you know whether your cluster has RBAC enabled set this variable. |
| `REGION`              | `us-central1`                     | The region where your cluster lives. |
| `SUBNETWORK`          | default                           | The subnetwork to use within this cluster. |
| `USE_STATIC_IP`       | `false`                           | Create a static IP for GitLab instead of an ephemeral IP with managed DNS. |
| `ZONE_EXTENSION`      | `b`                               | The extension (`a`, `b`, `c`) of the zone name where your cluster instances live. |

Run the script, by passing in your desired parameters. It can work with the
default parameters except for `PROJECT` which is required:

```shell
PROJECT=<gcloud project id> ./scripts/gke_bootstrap_script.sh up
```

The script can also be used to clean up the created GKE resources:

```shell
PROJECT=<gcloud project id> ./scripts/gke_bootstrap_script.sh down
```

With the cluster created, continue to [creating the DNS entry](#dns-entry).

### Manual cluster creation

Two resources need to be created in GCP, a Kubernetes cluster and an external IP.

#### Creating the Kubernetes cluster

To provision the Kubernetes cluster manually, follow the
[GKE instructions](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster).

- We recommend a cluster with at least 2 nodes, each with 4vCPU and 15GB of RAM.
- Make a note of the cluster's region, it will be needed in the following step.

#### Creating the external IP

An external IP is required so that your cluster can be reachable. The external
IP needs to be regional and in the same region as the cluster itself. A global
IP or an IP outside the cluster's region will **not work**.

To create a static IP run:

`gcloud compute addresses create ${CLUSTER_NAME}-external-ip --region $REGION --project $PROJECT`

To get the address of the newly created IP:

`gcloud compute addresses describe ${CLUSTER_NAME}-external-ip --region $REGION --project $PROJECT --format='value(address)'`

We will use this IP to bind with a DNS name in the next section.

## DNS Entry

If you created your cluster manually or used the `USE_STATIC_IP` option with the scripted creation,
you'll need a public domain with an A record wild card DNS entry pointing to the IP we just created.

Follow the [Google DNS quickstart guide](https://cloud.google.com/dns/docs/set-up-dns-records-domain-name)
to create the DNS entry.

## Next Steps

Continue with the [installation of the chart](../deployment.md) after you have
the cluster up and running, and the static IP and DNS entry ready.
