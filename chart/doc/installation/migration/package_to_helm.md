---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Migrate from the Linux package to the Helm chart

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

This guide will help you migrate from a package-based GitLab installation to
the Helm chart.

## Prerequisites

Before the migration, a few prerequisites must be met:

- The package-based GitLab instance must be up and running. Run `gitlab-ctl status`
  and confirm no services report a `down` state.
- It is a good practice to
  [verify the integrity](https://docs.gitlab.com/ee/administration/raketasks/check.html)
  of Git repositories prior to the migration.
- A Helm charts based deployment running the same GitLab version as the
  package-based installation is required.
- You need to set up the object storage which the Helm chart based deployment
  will use. For production use, we recommend you use an [external object storage](../../advanced/external-object-storage/index.md)
  and have the login credentials to access it ready. If you are using the built-in
  MinIO service, [read the docs](minio.md) on how to grab the login credentials
  from it.

## Migration steps

1. Migrate any existing data from the package-based
   installation to object storage:

   1. [Migrate to object storage](https://docs.gitlab.com/ee/administration/object_storage.html#migrate-to-object-storage).

   1. Visit the package-based GitLab instance and make sure the
      migrated data are available. For example check if user, group and project
      avatars are rendered fine, image and other files added to issues load
      correctly, etc.

1. [Create a backup tarball](https://docs.gitlab.com/ee/administration/backup_restore/backup_gitlab.html) and [exclude all the already migrated directories](https://docs.gitlab.com/ee/administration/backup_restore/backup_gitlab.html#excluding-specific-directories-from-the-backup).

   For local backups (default), the backup file is stored under `/var/opt/gitlab/backups`, unless you
   [explicitly changed the location](https://docs.gitlab.com/omnibus/settings/backups.html#manually-manage-backup-directory).
   For [remote storage backups](https://docs.gitlab.com/ee/administration/backup_restore/backup_gitlab.html#upload-backups-to-a-remote-cloud-storage),
   the backup file is stored in the configured bucket.
1. [Restore from the package-based installation](../../backup-restore/restore.md)
   to the Helm chart, starting with the secrets. You will need to migrate the
   values of `/etc/gitlab/gitlab-secrets.json` to the YAML file that will be
   used by Helm.
1. Restart all pods to make sure changes are applied:

   ```shell
   kubectl delete pods -lrelease=<helm release name>
   ```

1. Visit the Helm-based deployment and confirm projects, groups, users, issues
   etc. that existed in the package-based installation are restored.
   Also, verify if the uploaded files (avatars, files uploaded to issues, etc.)
   are loaded fine.
