---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Backing up a GitLab installation

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

GitLab backups are taken by running the `backup-utility` command in the Toolbox pod provided in the chart. Backups can also be automated by enabling the [Cron based backup](#cron-based-backup) functionality of this chart.

Before running the backup for the first time, you should ensure the
[Toolbox is properly configured](../charts/gitlab/toolbox/index.md#configuration)
for access to [object storage](index.md#object-storage).

Follow these steps for backing up a GitLab Helm chart based installation.

## Create the backup

1. Ensure the toolbox pod is running, by executing the following command

   ```shell
   kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
   ```

1. Run the backup utility

   ```shell
   kubectl exec <Toolbox pod name> -it -- backup-utility
   ```

1. Visit the `gitlab-backups` bucket in the object storage service and ensure a tarball has been added. It will be named in `<timestamp>_gitlab_backup.tar` format. Read what the [backup timestamp](https://docs.gitlab.com/ee/administration/backup_restore/backup_gitlab.html#backup-timestamp) is about.

1. This tarball is required for restoration.

## Cron based backup

NOTE:
The Kubernetes CronJob created by the Helm chart
sets the `cluster-autoscaler.kubernetes.io/safe-to-evict: "false"`
annotation on the jobTemplate. Some Kubernetes environments, such as
GKE Autopilot, don't allow this annotation to be set and will not create
Job Pods for the backup.
This annotation can be changed by setting the `gitlab.toolbox.backups.cron.safeToEvict` parameter to `true`, which will allow the Jobs to be created but at the risk of being evicted and corrupting the backup.

Cron based backups can be enabled in this chart to happen at regular intervals as defined by the [Kubernetes schedule](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/#schedule).

You need to set the following parameters:

- `gitlab.toolbox.backups.cron.enabled`: Set to true to enable cron based backups
- `gitlab.toolbox.backups.cron.schedule`: Set as per the Kubernetes schedule docs
- `gitlab.toolbox.backups.cron.extraArgs`: Optionally set extra arguments for [backup-utility](https://gitlab.com/gitlab-org/build/CNG/blob/master/gitlab-toolbox/scripts/bin/backup-utility) (like `--skip db` or `--s3tool awscli`)

## Backup utility extra arguments

The backup utility can take some extra arguments.

### Skipping components

Skip components by using the `--skip` argument. Valid components names can be found at [Excluding specific data from the backup](https://docs.gitlab.com/ee/administration/backup_restore/backup_gitlab.html#excluding-specific-data-from-the-backup).

Each component must have its own `--skip` argument. For example:

```shell
kubectl exec <Toolbox pod name> -it -- backup-utility --skip db --skip lfs
```

### Cleanup backups only

Run the backup cleanup without creating a new backup.

```shell
kubectl exec <Toolbox pod name> -it -- backup-utility --cleanup
```

### Specify S3 tool to use

The `backup-utility` command uses `s3cmd` by default to connect to object storage.
You may want to override this extra argument in cases where the `s3cmd` is less reliable
than other S3 tools.

There is a [known issue](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3338)
where a backup job crashes with `ERROR: S3 error: 404 (NoSuchKey): The specified key does not exist.`
when GitLab uses an S3 bucket as CI job artifact storage and the default `s3cmd` CLI tool
is being used. Switching from `s3cmd` to `awscli` allows backup jobs to run successfully.
See [issue 3338](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/3338) for further details.

The S3 CLI tool to use can be either `s3cmd` or `awscli`.

 ```shell
 kubectl exec <Toolbox pod name> -it -- backup-utility --s3tool awscli
 ```

#### Using MinIO with awscli

To use MinIO as the object storage when using `awscli`, set the following parameters:

```yaml
gitlab:
  toolbox:
    extraEnvFrom:
      AWS_ACCESS_KEY_ID:
        secretKeyRef:
          name: <MINIO-SECRET-NAME>
          key: accesskey
      AWS_SECRET_ACCESS_KEY:
        secretKeyRef:
          name: <MINIO-SECRET-NAME>
          key: secretkey
    extraEnv:
      AWS_DEFAULT_REGION: us-east-1 # MinIO default
    backups:
      cron:
        enabled: true
        schedule: "@daily"
        extraArgs: "--s3tool awscli --aws-s3-endpoint-url <MINIO-INGRESS-URL>"
```

NOTE:
The S3 CLI tool `s5cmd` support is under investigation.
See [issue 523](https://gitlab.com/gitlab-org/build/CNG/-/issues/523) to track
the progress.

### Other arguments

To see a complete list of available arguments, run the following command:

```shell
kubectl exec <Toolbox pod name> -it -- backup-utility --help
```

## Back up the secrets

You also need to save a copy of the rails secrets as these are not included in the backup as a security precaution. We recommend keeping your full backup that includes the database separate from the copy of the secrets.

1. Find the object name for the rails secrets

   ```shell
   kubectl get secrets | grep rails-secret
   ```

1. Save a copy of the rails secrets

   ```shell
   kubectl get secrets <rails-secret-name> -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > gitlab-secrets.yaml
   ```

1. Store `gitlab-secrets.yaml` in a secure location. You need it to restore your backups.

## Additional Information

- [GitLab chart Backup/Restore Introduction](index.md)
- [Restoring a GitLab installation](restore.md)
