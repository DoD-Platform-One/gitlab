---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Configure the GitLab chart with an external object storage
---

GitLab relies on object storage for highly-available persistent data in Kubernetes.
GitLab supports two types of authentication methods for major cloud object storage providers: static credentials and temporary credentials through cloud-specific services.

### Static credentials

These credentials are long-lived access keys and secrets for all providers:

- AWS S3: Access Key ID + Secret Access Key
- Google Cloud Storage: Service Account JSON key file
- Azure Blob Storage: Storage Account Name + Access Key, or Client ID + Tenant ID + Client Secret

### Temporary credentials through Cloud IAM

GitLab can retrieve provider-specific workload identity mechanisms for dynamic, short-lived credentials:

- AWS S3: [IAM Roles for Service Accounts (IRSA)](aws-iam-roles.md)
- Google Cloud Storage: [Workload Identity Federation](gke-workload-identity.md)
- Azure Blob Storage: [Workload Identity for Azure Kubernetes Service](azure-workload-identity.md)

These temporary credential mechanisms improve security by:

- Eliminating long-lived static credentials.
- Providing automated credential rotation.
- Enabling fine-grained access control.
- Supporting audit logging of credential usage.
- Integrating with cloud provider IAM policies.

## Disable MinIO

By default, an S3-compatible storage solution named `minio` is deployed with the
chart. For production quality deployments, we recommend using a hosted
object storage solution like Google Cloud Storage or AWS S3.

To disable MinIO, set this option and then follow the related documentation below:

```shell
--set global.minio.enabled=false
```

An [example of the full configuration](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/values-external-objectstorage.yaml)
has been provided in the [examples](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples).

## Azure Blob Storage

Direct support for Azure Blob storage is available for
[uploaded attachments, CI job artifacts, LFS, and other object types supported via the consolidated settings](https://docs.gitlab.com/administration/object_storage/#storage-specific-configuration). In previous GitLab versions, an [Azure MinIO gateway](azure-minio-gateway.md) was needed.

{{< alert type="note" >}}

GitLab [does not support](https://github.com/minio/minio/issues/9978) the Azure MinIO gateway as the storage for the Docker Registry.
Please refer to the [corresponding Azure example](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.azure.yaml) when [setting up the Docker Registry](#docker-registry-images).

{{< /alert >}}

Although Azure uses the word container to denote a collection of blobs,
GitLab standardizes on the term bucket.

Azure Blob storage requires the use of the
[consolidated object storage settings](../../charts/globals.md#consolidated-object-storage). A
single Azure storage account name and key must be used across multiple
Azure blob containers. Customizing individual `connection` settings by
object type (for example, `artifacts`, `uploads`, and so on) is not permitted.

To enable Azure Blob storage, see
[`rails.azurerm.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.azurerm.yaml)
as an example to define the Azure `connection`. You can load this as a
secret via:

```shell
kubectl create secret generic gitlab-rails-storage --from-file=connection=rails.azurerm.yml
```

Then, disable MinIO and set these global settings:

```shell
--set global.minio.enabled=false
--set global.appConfig.object_store.enabled=true
--set global.appConfig.object_store.connection.secret=gitlab-rails-storage
```

Be sure to create Azure containers for the [default names or set the container names in the bucket configuration](../../charts/globals.md#specify-buckets).

{{< alert type="note" >}}

If you experience requests failing with `Requests to the local network are not allowed`,
see the [Troubleshooting section](#troubleshooting).

{{< /alert >}}

## Docker Registry images

Configuration of object storage for the `registry` chart is done via the `registry.storage` key, and the `global.registry.bucket` key.

```shell
--set registry.storage.secret=registry-storage
--set registry.storage.key=config
--set global.registry.bucket=bucket-name
```

{{< alert type="note" >}}

The bucket name needs to be set both in the secret, and in `global.registry.bucket`. The secret is used in the registry server, and
the global is used by GitLab backups.

{{< /alert >}}

Create the secret per [registry chart documentation on storage](../../charts/registry/_index.md#storage), then configure the chart to make use of this secret.

Examples for [S3](https://distribution.github.io/distribution/storage-drivers/s3/)(S3 compatible storages, but Azure MinIO gateway not supported, see [Azure Blob Storage](#azure-blob-storage)), [Azure](https://distribution.github.io/distribution/storage-drivers/azure/) and [GCS](https://distribution.github.io/distribution/storage-drivers/gcs/) drivers can be found in
[`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage).

- [`registry.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.s3.yaml)
- [`registry.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.gcs.yaml)
- [`registry.azure.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.azure.yaml)

### Registry configuration

1. Decide on which storage service to use.
1. Copy appropriate file to `registry-storage.yaml`.
1. Edit with the correct values for the environment.
1. Follow [registry chart documentation on storage](../../charts/registry/_index.md#storage) for creating the secret.
1. Configure the chart as documented.

## LFS, Artifacts, Uploads, Packages, External Diffs, Terraform State, Dependency Proxy, Secure Files

Configuration of object storage for LFS, artifacts, uploads, packages, external
diffs, Terraform state, Secure Files, and pseudonymizer is done via the following keys:

- `global.appConfig.lfs`
- `global.appConfig.artifacts`
- `global.appConfig.uploads`
- `global.appConfig.packages`
- `global.appConfig.externalDiffs`
- `global.appConfig.dependencyProxy`
- `global.appConfig.terraformState`
- `global.appConfig.ciSecureFiles`

Note also that:

- You must create buckets for the [default names or custom names in the bucket configuration](../../charts/globals.md#specify-buckets).
- A different bucket is needed for each, otherwise performing a restore from
  backup doesn't function properly.
- Storing MR diffs on external storage is not enabled by default, so,
  for the object storage settings for `externalDiffs` to take effect,
  `global.appConfig.externalDiffs.enabled` key should have a `true` value.
- The dependency proxy feature is not enabled by default, so,
  for the object storage settings for `dependencyProxy` to take effect,
  `global.appConfig.dependencyProxy.enabled` key should have a `true` value.

Below is an example of the configuration options:

```shell
--set global.appConfig.lfs.bucket=gitlab-lfs-storage
--set global.appConfig.lfs.connection.secret=object-storage
--set global.appConfig.lfs.connection.key=connection

--set global.appConfig.artifacts.bucket=gitlab-artifacts-storage
--set global.appConfig.artifacts.connection.secret=object-storage
--set global.appConfig.artifacts.connection.key=connection

--set global.appConfig.uploads.bucket=gitlab-uploads-storage
--set global.appConfig.uploads.connection.secret=object-storage
--set global.appConfig.uploads.connection.key=connection

--set global.appConfig.packages.bucket=gitlab-packages-storage
--set global.appConfig.packages.connection.secret=object-storage
--set global.appConfig.packages.connection.key=connection

--set global.appConfig.externalDiffs.bucket=gitlab-externaldiffs-storage
--set global.appConfig.externalDiffs.connection.secret=object-storage
--set global.appConfig.externalDiffs.connection.key=connection

--set global.appConfig.terraformState.bucket=gitlab-terraform-state
--set global.appConfig.terraformState.connection.secret=object-storage
--set global.appConfig.terraformState.connection.key=connection

--set global.appConfig.dependencyProxy.bucket=gitlab-dependencyproxy-storage
--set global.appConfig.dependencyProxy.connection.secret=object-storage
--set global.appConfig.dependencyProxy.connection.key=connection

--set global.appConfig.ciSecureFiles.bucket=gitlab-ci-secure-files
--set global.appConfig.ciSecureFiles.connection.secret=object-storage
--set global.appConfig.ciSecureFiles.connection.key=connection
```

See the [charts/globals documentation on appConfig](../../charts/globals.md#configure-appconfig-settings) for full details.

Create the secret(s) per the [connection details documentation](../../charts/globals.md#connection), and then configure the chart to use the provided secrets. Note, the same secret can be used for all of them.

Examples for [AWS](https://fog.github.io/storage/#using-amazon-s3-and-fog) (any S3 compatible like [Azure using MinIO](azure-minio-gateway.md)) and [Google](https://fog.github.io/storage/#google-cloud-storage) providers can be found in
[`examples/objectstorage`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage).

- [`rails.s3.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.s3.yaml)
- [`rails.gcs.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.gcs.yaml)
- [`rails.azure.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.azure.yaml)
- [`rails.azurerm.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.azurerm.yaml)

### S3 encryption

GitLab supports [Amazon KMS](https://aws.amazon.com/kms/)
to [encrypt data stored in S3 buckets](https://docs.gitlab.com/administration/object_storage/#encrypted-s3-buckets).
You can enable this in two ways:

- In AWS, [configure the S3 bucket to use default encryption](https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html).
- In GitLab, enable [server side encryption headers](../../charts/globals.md#storage_options).

These two options are not mutually exclusive. You can set a default encryption
policy, but also enable server-side encryption headers to override those defaults.

See the [GitLab documentation on encrypted S3 buckets](https://docs.gitlab.com/administration/object_storage/#encrypted-s3-buckets)
for more details.

### appConfig configuration

1. Decide on which storage service to use.
1. Copy appropriate file to `rails.yaml`.
1. Edit with the correct values for the environment.
1. Follow [connection details documentation](../../charts/globals.md#connection) for creating the secret.
1. Configure the chart as documented.

## Backups

Backups are also stored in object storage, and must be configured to point
externally rather than the included MinIO service. The backup/restore procedure uses two separate buckets:

- A bucket for storing backups (`global.appConfig.backups.bucket`)
- A temporary bucket for preserving existing data during the restore process (`global.appConfig.backups.tmpBucket`)

AWS S3-compatible object storage systems, Google Cloud Storage, and Azure Blob Storage
are supported backends. You can configure the backend type by setting `global.appConfig.backups.objectStorage.backend`
to `s3` for AWS S3, `gcs` for Google Cloud Storage, or `azure` for Azure Blob Storage.
You must also provide a connection configuration through the `gitlab.toolbox.backups.objectStorage.config` key.

When using Google Cloud Storage with a secret, the GCP project must be set with the `global.appConfig.backups.objectStorage.config.gcpProject` value.

For S3-compatible storage:

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
--set gitlab.toolbox.backups.objectStorage.config.secret=storage-config
--set gitlab.toolbox.backups.objectStorage.config.key=config
```

For Google Cloud Storage (GCS) with a secret:

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
--set gitlab.toolbox.backups.objectStorage.backend=gcs
--set gitlab.toolbox.backups.objectStorage.config.gcpProject=my-gcp-project-id
--set gitlab.toolbox.backups.objectStorage.config.secret=storage-config
--set gitlab.toolbox.backups.objectStorage.config.key=config
```

For Google Cloud Storage (GCS) with [Workload Identity Federation for GKE](gke-workload-identity.md), only the backend and buckets need to be set.
Make sure `gitlab.toolbox.backups.objectStorage.config.secret` and `gitlab.toolbox.backups.objectStorage.config.key` are not set,
so that the cluster uses [Google's Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials):

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
--set gitlab.toolbox.backups.objectStorage.backend=gcs
```

For Azure Blob Storage:

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
--set gitlab.toolbox.backups.objectStorage.backend=azure
--set gitlab.toolbox.backups.objectStorage.config.secret=storage-config
--set gitlab.toolbox.backups.objectStorage.config.key=config
```

See the [backup/restore object storage documentation](../../backup-restore/_index.md#object-storage) for full details.

{{< alert type="note" >}}

To backup or restore files from the other object storage locations, the configuration file needs to be
configured to authenticate as a user with sufficient access to read/write to all GitLab buckets.

{{< /alert >}}

### Backups storage example

1. Create the `storage.config` file:

   - On Amazon S3, the contents should be in the [s3cmd configuration file format](https://s3tools.org/kb/item14.htm)

     ```ini
     [default]
     access_key = AWS_ACCESS_KEY
     secret_key = AWS_SECRET_KEY
     bucket_location = us-east-1
     multipart_chunk_size_mb = 128 # default is 15 (MB)
     ```

   - On Google Cloud Storage, you can create the file by creating a service account
     with the `storage.admin` role and then
     [creating a service account key](https://cloud.google.com/iam/docs/keys-create-delete#creating_service_account_keys).
     Below is an example of using the `gcloud` CLI to create the file.

     ```shell
     export PROJECT_ID=$(gcloud config get-value project)
     gcloud iam service-accounts create gitlab-gcs --display-name "Gitlab Cloud Storage"
     gcloud projects add-iam-policy-binding --role roles/storage.admin ${PROJECT_ID} --member=serviceAccount:gitlab-gcs@${PROJECT_ID}.iam.gserviceaccount.com
     gcloud iam service-accounts keys create --iam-account gitlab-gcs@${PROJECT_ID}.iam.gserviceaccount.com storage.config
     ```

   - On Azure Storage

     ```ini
     [default]
     # Setup endpoint: hostname of the Web App
     host_base = https://your_minio_setup.azurewebsites.net
     host_bucket = https://your_minio_setup.azurewebsites.net
     # Leave as default
     bucket_location = us-west-1
     use_https = True
     multipart_chunk_size_mb = 128 # default is 15 (MB)

     # Setup access keys
     # Access Key = Azure Storage Account name
     access_key = AZURE_ACCOUNT_NAME
     # Secret Key = Azure Storage Account Key
     secret_key = AZURE_ACCOUNT_KEY

     # Use S3 v4 signature APIs
     signature_v2 = False
     ```

1. Create the secret

   ```shell
   kubectl create secret generic storage-config --from-file=config=storage.config
   ```

## Google Cloud CDN

{{< history >}}

- [Introduced](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/98010) in GitLab 15.5.

{{< /history >}}

You can use [Google Cloud CDN](https://cloud.google.com/cdn) to cache
and fetch data from the artifacts bucket. This can help improve
performance and reduce network egress costs.

Configuration of Cloud CDN is done via the following keys:

- `global.appConfig.artifacts.cdn.secret`
- `global.appConfig.artifacts.cdn.key` (default is `cdn`)

To use Cloud CDN:

1. Set up [Cloud CDN to use the artifacts bucket as the backend](https://cloud.google.com/cdn/docs/setting-up-cdn-with-bucket).
1. Create a [key for signed URLs](https://cloud.google.com/cdn/docs/using-signed-urls).
1. Give the [Cloud CDN service account permission to read from the bucket](https://cloud.google.com/cdn/docs/using-signed-urls#configuring_permissions).
1. Prepare a YAML file with the parameters using the example in [`rails.googlecdn.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/cdn/rails.googlecdn.yaml).
   You will need to fill in the following information:
   - `url`: Base URL of the CDN host from step 1
   - `key_name`: Key name from step 2
   - `key`: The actual secret from step 2
1. Load this YAML file into a Kubernetes secret under the `cdn` key. For example, to create a secret `gitlab-rails-cdn`:

   ```shell
   kubectl create secret generic gitlab-rails-cdn --from-file=cdn=rails.googlecdn.yml
   ```

1. Set `global.appConfig.artifacts.cdn.secret` to `gitlab-rails-cdn`. If you're setting this via a `helm`
   parameter, use:

    ```shell
    --set global.appConfig.artifacts.cdn.secret=gitlab-rails-cdn
    ```

## Troubleshooting

### Azure Blob: URL \[FILTERED] is blocked: Requests to the local network are not allowed

This happens when the Azure Blob hostname is resolved to a [RFC1918 (local / private) IP address](https://learn.microsoft.com/en-us/azure/storage/common/storage-private-endpoints#dns-changes-for-private-endpoints). As a workaround,
allow [Outbound requests](https://docs.gitlab.com/security/webhooks/#allowlist-for-local-requests)
for your Azure Blob hostname (`yourinstance.blob.core.windows.net`).
