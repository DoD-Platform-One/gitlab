---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Preparing OpenShift resources for the GitLab chart
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

This document walks you through using the automation scripts in this project to create an OpenShift cluster in Google Cloud.

## Preparation

First, you should have a Red Hat account associated with your GitLab email.
Contact our Red Hat Alliance liaison; they will arrange to send you an account invitation email. Once you activate your Red Hat account, you will have access the to licenses and subscriptions needed to run OpenShift.

To launch a cluster in Google Cloud, a public Cloud DNS zone must be connected to a registered domain and configured in Google Cloud DNS. If a domain is not already available, follow the steps [in this guide](https://github.com/openshift/installer/blob/master/docs/user/gcp/dns.md) to create one.

### Get the CLI tools and Pull Secret

Two CLI tools are required to create an OpenShift cluster (`openshift-install`) and then interact with the cluster (`oc`).

A pull secret is required to fetch images from Red Hat's private Docker registry.
Every developer has a different pull secret associated with their Red Hat account.

To get the CLI tools and your pull secret, go to [Red Hat's cloud](https://cloud.redhat.com/openshift/install/gcp/installer-provisioned) and log in with your Red Hat account.
On this page, download the latest version of the installer and command-line tools with the links provided. Extract these packages and place `openshift-install` and `oc` in your `PATH`.

Copy the pull secret to your clipboard and write the content to a file `pull_secret` in the root of this repository. This file is gitignored.

### Create a Google Cloud (GCP) Service Account

Follow [these instructions](https://docs.openshift.com/container-platform/4.9/installing/installing_gcp/installing-gcp-account.html#installation-gcp-service-account_installing-gcp-account) to create a Service Account in the Google Cloud `cloud-native` project. Attach all roles marked as Required in that document.
Once the Service Account is created, generate a JSON key and save it as `gcloud.json` in the root of this repository. This file is gitignored.

## Create your OpenShift cluster

To create the OpenShift cluster:

1. Clone the GitLab Operator repository:

   ```shell
   git clone https://gitlab.com/gitlab-org/cloud-native/gitlab-operator.git
   ```

1. Run the script to create the OpenShift cluster in Google Cloud:

   ```shell
   cd gitlab-operator
   ./scripts/create_openshift_cluster.sh
   ```

This will be a 6 node cluster with 3 control plane (master) nodes and 3 worker nodes.
The process takes around 40 minutes. Follow the instructions at the end of the
console output to connect to the cluster.

Once created, you should be able to see your cluster registered in
[Red Hat cloud](https://cloud.redhat.com/openshift/). All installation logs and
metadata will be stored in the `install-$CLUSTER_NAME/` directory in this repository.
This directory is gitignored.

### Configuration options

Configuration can be applied during runtime by setting environment variables.
All options have defaults, so no options are required.

| Variable                         | Default                                      | Description |
|----------------------------------|----------------------------------------------|-------------|
| `CLUSTER_NAME`                   | `ocp-$USER`                                  | Name of cluster |
| `BASE_DOMAIN`                    | `k8s-ft.win`                                 | Root domain for cluster |
| `GCP_PROJECT_ID`                 | `cloud-native-182609`                        | Google Cloud project ID |
| `GCP_REGION`                     | `us-central1`                                | Google Cloud region for cluster |
| `GOOGLE_APPLICATION_CREDENTIALS` | `gcloud.json`                                | Path to Google Cloud service account JSON file |
| `GOOGLE_CREDENTIALS`             | Content of `$GOOGLE_APPLICATION_CREDENTIALS` | Content of Google Cloud service account JSON file |
| `PULL_SECRET_FILE`               | `pull_secret`                                | Path to Red Hat pull secret file |
| `PULL_SECRET`                    | Content of `$PULL_SECRET_FILE`               | Content of Red Hat pull secret file |
| `SSH_PUBLIC_KEY_FILE`            | `$HOME/.ssh/id_rsa.pub`                      | Path to SSH public key file |
| `SSH_PUBLIC_KEY`                 | Content of `$SSH_PUBLIC_KEY_FILE`            | Content of SSH public key file |
| `LOG_LEVEL`                      | `info`                                       | Verbosity of `openshift-install` output |
| `INSTALL_DIR`                    | `install-$CLUSTER_NAME`                      | Directory for install assets, useful for launching multiple clusters |

{{< alert type="note" >}}

The variables `CLUSTER_NAME` and `BASE_DOMAIN` are combined to build the domain name for the cluster.

{{< /alert >}}

## Destroy your OpenShift cluster

To destroy the OpenShift cluster:

1. Clone the GitLab Operator repository:

   ```shell
   git clone https://gitlab.com/gitlab-org/cloud-native/gitlab-operator.git
   ```

1. Run the script to destroy the OpenShift cluster in Google Cloud. This takes
   around 4 minutes:

   ```shell
   cd gitlab-operator
   ./scripts/destroy_openshift_cluster.sh
   ```

Configuration can be applied during runtime by setting the following environment
variables. All options have defaults, no options are required.

| Variable                         | Default------------------------------------- | Description |
|----------------------------------|----------------------------------------------|-------------|
| `GOOGLE_APPLICATION_CREDENTIALS` | `gcloud.json`                                | Path to Google Cloud service account JSON file |
| `GOOGLE_CREDENTIALS`             | Content of `$GOOGLE_APPLICATION_CREDENTIALS` | Content of Google Cloud service account JSON file |
| `LOG_LEVEL`                      | `info`                                       | Verbosity of `openshift-install` output |
| `INSTALL_DIR`                    | `install-$CLUSTER_NAME`                      | Directory for install assets, useful for launching multiple clusters |

## Next steps

When the cluster is up and running, you can continue [installing GitLab](https://docs.gitlab.com/operator/).

## Resources

- [`openshift-installer` source code](https://github.com/openshift/installer)
- [`oc` source code](https://github.com/openshift/oc)
- [`openshift-installer` and `oc` packages](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/)
- [OpenShift Container Project (OCP) architecture docs](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.9/html/architecture/architecture)
- [OpenShift GCP docs](https://docs.openshift.com/container-platform/4.9/installing/installing_gcp/installing-gcp-account.html)
- [OpenShift troubleshooting guide](https://docs.openshift.com/container-platform/4.9/support/troubleshooting/troubleshooting-installations.html)
