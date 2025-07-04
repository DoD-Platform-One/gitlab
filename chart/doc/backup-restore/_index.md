---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Backup and restore a GitLab instance
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

GitLab Helm chart provides a utility pod from the Toolbox sub-chart that acts as an interface for the purpose of backing up and restoring GitLab instances. It is equipped with a `backup-utility` executable which interacts with other necessary pods for this task.
Technical details for how the utility works can be found in the [architecture documentation](../architecture/backup-restore.md).

## Prerequisites

- Backup and Restore procedures described here have only been tested with S3 compatible APIs. Support for other object storage services, like Google Cloud Storage, will be tested in future revisions.

- During restoration, the backup tarball needs to be extracted to disk. This means the Toolbox pod should have disk of [necessary size available](../charts/gitlab/toolbox/_index.md#restore-considerations).

- This chart relies on the use of [object storage](#object-storage) for `artifacts`, `uploads`, `packages`, `registry` and `lfs` objects, and does not currently migrate these for you during restore. If you are restoring a backup taken from another instance, you must migrate your existing instance to using object storage before taking the backup. See [issue 646](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/646).

## Backup and Restoring procedures

- [Backing up a GitLab installation](backup.md)
- [Restoring a GitLab installation](restore.md)

## Object storage

We provide a MinIO instance out of the box when using this charts unless an [external object storage](../advanced/external-object-storage/_index.md) is specified. The Toolbox connects to the included MinIO by default, unless specific settings are given. The Toolbox can also be configured to back up to Amazon S3 or Google Cloud Storage (GCS).

### Backups to S3

The Toolbox uses `s3cmd` by default to connect to object storage unless you [specify another s3 tool to use](../backup-restore/backup.md#specify-s3-tool-to-use). In order to configure connectivity to external object storage `gitlab.toolbox.backups.objectStorage.config.secret` should be specified which points to a Kubernetes secret containing a `.s3cfg` file. `gitlab.toolbox.backups.objectStorage.config.key` should be specified if different from the default of `config`. This points to the key containing the contents of a `.s3cfg` file.

It should look like this:

```shell
helm install gitlab gitlab/gitlab \
  --set gitlab.toolbox.backups.objectStorage.config.secret=my-s3cfg \
  --set gitlab.toolbox.backups.objectStorage.config.key=config .
```

s3cmd `.s3cfg` file documentation can be found [here](https://s3tools.org/kb/item14.htm)

In addition, two bucket locations need to be configured, one for storing the backups, and one temporary bucket that is used
when restoring a backup.

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
```

### Backups to Google Cloud Storage (GCS)

To backup to GCS, you must first set `gitlab.toolbox.backups.objectStorage.backend` to `gcs`. This ensures
that the Toolbox uses the `gsutil` CLI when storing and retrieving
objects.

In addition, two bucket locations need to be configured, one for storing
the backups, and one temporary bucket that is used when restoring a
backup.

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
```

The backup utility needs access to these buckets. There are two ways to grant access:

- Specifying credentials in a Kubernetes secret.
- Configuring [Workload Identity Federation for GKE](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity).

#### GCS credentials

First, set `gitlab.toolbox.backups.objectStorage.config.gcpProject` to the project ID of the GCP project that contains your storage buckets.

You must create a Kubernetes secret with the contents of an active service account JSON key where the service account has the `storage.admin` role for the buckets
you will use for backup. Below is an example of using the `gcloud` and `kubectl` to create the secret.

```shell
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create gitlab-gcs --display-name "Gitlab Cloud Storage"
gcloud projects add-iam-policy-binding --role roles/storage.admin ${PROJECT_ID} --member=serviceAccount:gitlab-gcs@${PROJECT_ID}.iam.gserviceaccount.com
gcloud iam service-accounts keys create --iam-account gitlab-gcs@${PROJECT_ID}.iam.gserviceaccount.com storage.config
kubectl create secret generic storage-config --from-file=config=storage.config
```

Configure your Helm chart as follows to use the service account key to authenticate to GCS for backups:

```shell
helm install gitlab gitlab/gitlab \
  --set gitlab.toolbox.backups.objectStorage.config.secret=storage-config \
  --set gitlab.toolbox.backups.objectStorage.config.key=config \
  --set gitlab.toolbox.backups.objectStorage.config.gcpProject=my-gcp-project-id \
  --set gitlab.toolbox.backups.objectStorage.backend=gcs
```

#### Configuring Workload Identity Federation for GKE

See the [documentation on Workload Identity Federation for GKE using the GitLab chart](../advanced/external-object-storage/gke-workload-identity.md).

When creating an IAM allow policy that references the Kubernetes ServiceAccount, grant the `roles/storage.objectAdmin` role.

For backups, ensure that Google's Application Default Credentials are used by making sure that
`gitlab.toolbox.backups.objectStorage.config.secret`, `gitlab.toolbox.backups.objectStorage.config.key`, and `gitlab.toolbox.backups.objectStorage.config.gcpProject` are NOT set.

### Backups to Azure blob storage

Azure blob storage can be used to store backups by setting
`gitlab.toolbox.backups.objectStorage.backend` to `azure`. This enables
Toolbox to use the included copy of `azcopy` to transmit and retrieve the
backup files to the Azure blob storage.

To use Azure blob storage, one will need to create a storage account
in an existing resource group. Create a config secret with your storage
account's name, access key and blob host.

Create a config file containing the paramters:

```yaml
# azure-backup-conf.yaml
azure_storage_account_name: <storage account>
azure_storage_access_key: <access key value>
azure_storage_domain: blob.core.windows.net # optional
```

The following `kubectl` command can be used to create the Kubernetes Secret:

```shell
kubectl create secret generic backup-azure-creds \
  --from-file=config=azure-backup-conf.yaml
```

Once the Secret has been created, the GitLab Helm chart can be
configured by adding the backup settings to your deployed values or by supplying
the settings on the Helm command line. For example:

```shell
helm install gitlab gitlab/gitlab \
  --set gitlab.toolbox.backups.objectStorage.config.secret=backup-azure-creds \
  --set gitlab.toolbox.backups.objectStorage.config.key=config \
  --set gitlab.toolbox.backups.objectStorage.backend=azure
```

The access key from the Secret is used to generate and refresh shorter-lived shared
access signature (SAS) tokens to access the storage account.

In addition, two buckets/containers need to be created beforehand, one for storing the
backups, and one temporary bucket that is used when restoring a backup. Add the
bucket names to your values or settings. For example:

```shell
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
```

## Troubleshooting

### Pod eviction issues

As the backups are assembled locally outside of the object storage target, temporary disk space is needed. The required space might exceed the size of the actual backup archive.
The default configuration will use the Toolbox pod's file system to store the temporary data. If you find pod being evicted due to low resources, you should attach a persistent volume to the pod to hold the temporary data.
On GKE, add the following settings to your Helm command:

```shell
--set gitlab.toolbox.persistence.enabled=true
```

If your backups are being run as part of the included backup cron job, then you will want to enable persistence for the cron job as well:

```shell
--set gitlab.toolbox.backups.cron.persistence.enabled=true
```

For other providers, you may need to create a persistent volume. See our [Storage documentation](../installation/storage.md) for possible examples on how to do this.

### "Bucket not found" errors

If you see `Bucket not found` errors during backups, check the
credentials are configured for your bucket.

The command depends on the cloud service provider:

- For AWS S3, the credentials are stored on the toolbox pod in `~/.s3cfg`. Run:

  ```shell
  s3cmd ls
  ```

- For GCP GCS, run:

  ```shell
  gsutil ls
  ```

You should see a list of available buckets.

### "AccessDeniedException: 403" errors in GCP

An error like `[Error] AccessDeniedException: 403 <GCP Account> does not have storage.objects.list access to the Google Cloud Storage bucket.`
usually happens during a backup or restore of a GitLab instance, because of missing permissions.

The backup and restore operations use all buckets in the environment, so
confirm that all buckets in your environment have been created, and that the GCP account can access (list, read, and write) all buckets:

1. Find your toolbox pod:

   ```shell
   kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
   ```

1. Get all buckets in the pod's environment. Replace `<toolbox-pod-name>` with your actual toolbox pod name, but leave `"BUCKET_NAME"` as it is:

   ```shell
   kubectl describe pod <toolbox-pod-name> | grep "BUCKET_NAME"
   ```

1. Confirm that you have access to every bucket in the environment:

   ```shell
   # List
   gsutil ls gs://<bucket-to-validate>/

   # Read
   gsutil cp gs://<bucket-to-validate>/<object-to-get> <save-to-location>

   # Write
   gsutil cp -n <local-file> gs://<bucket-to-validate>/
   ```

### "ERROR: `/home/git/.s3cfg`: None" error when running `backup-utility` with `--backend s3`

This error happens when a Kubernetes secret containing a `.s3cfg` file was not specified through the `gitlab.toolbox.backups.objectStorage.config.secret` value.

To fix this, follow the instructions in [backups to S3](_index.md#backups-to-s3).

### "PermissionError: File not writable" errors using S3

An error like `[Error] WARNING: <file> not writable: Operation not permitted` happens if the toolbox user does not have
permissions to write files that match the stored permissions of the bucket items.

To prevent this, configure `s3cmd` not to preserve file owner, mode and timestamps by adding the
following flag to your `.s3cfg` file referenced via `gitlab.toolbox.backups.objectStorage.config.secret`.

```toml
preserve_attrs = False
```

### Repositories skipped on restore

Starting with GitLab 16.6/Chart 7.6 repositories may be skipped on restore if the backup archive has been renamed.
To avoid this, do not rename backup archives and rename backups to their original names (`{backup_id}_gitlab_backup.tar`).

The original backup ID can be extracted from the repository backup directory structure: `repositories/@hashed/*/*/*/{backup_id}/LATEST`
