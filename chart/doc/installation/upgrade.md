---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Upgrade Guide

Before upgrading your GitLab installation, you need to check the
[changelog](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md)
corresponding to the specific release you want to upgrade to and look for any
[release notes](../releases/index.md) that might pertain to the new GitLab chart
version.

WARNING:
If you are upgrading from the `3.x` version of the chart to the latest `4.0` release, you need
to first update to the latest `3.3.x` patch release in order for the upgrade to work.
The [4.0 release notes](../releases/4_0.md) describe the supported upgrade path.

WARNING:
If you are upgrading from the `2.x` version of the chart to the latest 3.0 release, you need
to first update to the latest `2.6.x` patch release in order for the upgrade to work.
The [3.0 release notes](../releases/3_0.md) describe the supported upgrade path.

We also recommend that you take a [backup](../backup-restore/index.md) first. Also note that you
must provide all values using `helm upgrade --set key=value` syntax or `-f values.yml` instead of
using `--reuse-values`, because some of the current values might be deprecated.

You can retrieve your previous `--set` arguments cleanly, with
`helm get values <release name>`. If you direct this into a file
(`helm get values <release name> > gitlab.yaml`), you can safely pass this
file via `-f`. Thus `helm upgrade gitlab gitlab/gitlab -f gitlab.yaml`.
This safely replaces the behavior of `--reuse-values`

Mappings between chart versioning and GitLab versioning can be found [here](../index.md#gitlab-version-mappings).

## Steps

NOTE:
If you're upgrading to the `4.0` version of the chart, follow the [manual upgrade steps for 4.0](#upgrade-steps-for-40-release).
If you're upgrading to the `3.0` version of the chart, follow the [manual upgrade steps for 3.0](#upgrade-steps-for-30-release).

The following are the steps to upgrade GitLab to a newer version:

1. Check the [change log](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md) for the specific version you would like to upgrade to
1. Go through [deployment documentation](deployment.md) step by step
1. Extract your previous `--set` arguments with

   ```shell
   helm get values gitlab > gitlab.yaml
   ```

1. Decide on all the values you need to set
1. If you were using the GitLab Operator, it is [**deprecated**](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2210), and will be removed in the future.
1. Perform the upgrade, with all `--set` arguments extracted in step 4

   ```shell
   helm upgrade gitlab gitlab/gitlab \
     --version <new version> \
     -f gitlab.yaml \
     --set gitlab.migrations.enabled=true \
     --set ...
   ```

During a major database upgrade, we ask you to set `gitlab.migrations.enabled` set to `false`.
Ensure that you explicitly set it back to `true` for future updates.

## Upgrade the bundled PostgreSQL to version 12 (optional)

NOTE:
If you aren't using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need to
perform this step.

Upgrading to PostgreSQL 12 for GitLab 13.x is optional. PostgreSQL 12 is supported by GitLab 13.4 and later. PostgreSQL 12 will become the minimum required PostgreSQL version in [GitLab 14.0, scheduled for April 2021](https://gitlab.com/groups/gitlab-org/-/epics/2374#phased-plan). [PostgreSQL 12 brings significant performance improvements](https://www.postgresql.org/about/news/postgresql-12-released-1976/).

To upgrade the bundled PostgreSQL to version 12, the following steps are required:

1. [Prepare the existing database](#prepare-the-existing-database).
1. [Delete existing PostgreSQL data](#delete-existing-postgresql-data).
1. Update the `postgresql.image.tag` value to `12.4.0` and [reinstall the chart](#upgrade-gitlab) to create a new PostgreSQL 12 database.
1. [Restore the database](#restore-the-database).

## Upgrade the bundled PostgreSQL chart

As part of the `4.0.0` release of this chart, we upgraded the bundled [PostgreSQL chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) from `7.7.0` to `8.9.4`. This is not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [4.0 upgrade steps](#upgrade-steps-for-40-release).

As part of the `3.0.0` release of this chart, we upgraded the bundled [PostgreSQL chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql) from 0.11.0 to 7.7.0. This is not a drop in replacement. Manual steps need to be performed to upgrade the database.
The steps have been documented in the [3.0 upgrade steps](#upgrade-steps-for-30-release).

## Upgrade steps for 4.0 release

The `4.0.0` release requires manual steps in order to perform the upgrade. If you're using the
bundled PostgreSQL, the best way to perform this upgrade is to back up your old database, and
restore into a new database instance.

WARNING:
Remember to make a [backup](../backup-restore/index.md)
before proceeding with the upgrade. Failure to perform these steps as documented **may** result in
the loss of your database. Ensure you have a separate backup.

### Prepare the existing database

Note the following:

- If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
  to perform this step.
- If you have multiple charts installed in the same namespace. It may be necessary to pass the Helm
  release name to the database-upgrade script as well. Replace `bash -s STAGE` with
  `bash -s -- -r RELEASE STAGE` in the example commands provided later.
- If you installed a chart to a namespace other than your `kubectl` context's default, you must pass
  the namespace to the database-upgrade script. Replace `bash -s STAGE` with
  `bash -s -- -n NAMESPACE STAGE` in the example commands provided later. This option can be used
  along with `-r RELEASE`. You can set the context's default namespace by running
  `kubectl config set-context --current --namespace=NAMESPACE`, or using
  [`kubens` from kubectx](https://github.com/ahmetb/kubectx).

The `pre` stage will create a backup of your database using the backup-utility script in the Task Runner, which gets saved to the configured s3 bucket (MinIO by default):

```shell
# GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v4.0.0
curl -s "https://gitlab.com/gitlab-org/charts/gitlab/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s pre
```

### Delete existing PostgreSQL data

NOTE:
If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
to perform this step.

WARNING:
Ensure that you have created a database backup in the previous step. Without a backup, GitLab data
will be lost.

The `4.0` release updates the default bundled PostgreSQL version from 10.9.0 to 11.7.0. Since the
data format has changed, upgrading requires removing the existing PostgreSQL StatefulSet before
upgrading to the `4.0` release. The StatefulSet will be recreated in the next step.

```shell
kubectl delete statefulset RELEASE-NAME-postgresql
kubectl delete pvc data-RELEASE_NAME-postgresql-0
```

### Upgrade GitLab

Upgrade GitLab following our [standard procedure](#steps), with the following additions of:

If you are using the bundled PostgreSQL, disable migrations using the following flag on your upgrade command:

1. `--set gitlab.migrations.enabled=false`

We will perform the migrations for the Database in a later step for the bundled PostgreSQL.

### Restore the Database

Note the following:

- If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
  to perform this step.
- You'll need to be using Bash 4.0 or above to run the script successfully as it requires the use of
  bash associative arrays.

1. Wait for the upgrade to complete for the Task Runner pod. RELEASE_NAME should be the name of the GitLab release from `helm list`

   ```shell
   kubectl rollout status -w deployment/RELEASE_NAME-task-runner
   ```

1. After the Task Runner pod is deployed successfully, run the `post` steps:

   This step will do the following:

   1. Set replicas to 0 for the `webservice`, `sidekiq`, and `gitlab-exporter` deployments. This will prevent any other application from altering the database while the backup is being restored.
   1. Restore the database from the backup created in the pre stage.
   1. Run database migrations for the new version.
   1. Resume the deployments from the first step.

   ```shell
   # GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v4.0.0
   curl -s "https://gitlab.com/gitlab-org/charts/gitlab/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s post
   ```

### Troubleshooting 4.0 release upgrade process

- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```

#### 4.8: Repository data appears to be lost upgrading Praefect

The Praefect chart is not yet considered suitable for production use.

If you have enabled Praefect before upgrading to version 4.8 of the chart (GitLab 13.8),
note that the StatefulSet name for Gitaly will now include the virtual storage name.

In version 4.8 of the Praefect chart, the ability to specify multiple virtual storages
was added, making it necessary to change the StatefulSet name.

Any existing Praefect-managed Gitaly StatefulSet names (and, therefore, their
associated PersistentVolumeClaims) will change as well, leading to repository data
appearing to be lost.

Prior to upgrading, ensure that:

- All your repositories are in sync across the Gitaly Cluster, and GitLab
is not in use during the upgrade.
- You have a complete and tested backup.

Repository data can be restored by following the
[managing persistent volumes documentation](../advanced/persistent-volumes/),
which provides guidance on reconnecting existing PersistentVolumeClaims to previous
PersistentVolumes.

A key step of the process is setting the old persistent volumes' `persistentVolumeReclaimPolicy`
to `Retain`. If this step is missed, actual data loss will likely occur.

After reviewing the documentation, there is a scripted summary of the procedure
[in a comment on one of a related issues](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2532#note_506467539).

Having reconnected the PersistentVolumes, it is likely that all your repositories
will be set `read-only` by Praefect, as shown by running the following in a
Praefect container:

```plaintext
praefect -config /etc/gitaly/config.toml dataloss
```

If all your Git repositories are in sync across the old persistent volumes, use the
`accept-dataloss` procedure for each repository to fix the Gitaly Cluster in Praefect.

[We have an issue open](https://gitlab.com/gitlab-org/gitaly/-/issues/3448) to verify
that this is the best approach to fixing Praefect.

## Upgrade steps for 3.0 release

The `3.0.0` release requires manual steps in order to perform the upgrade.

WARNING:
Remember to make a [backup](../backup-restore/index.md)
before proceeding with the upgrade. Failure to perform these steps as documented **may** result in
the loss of your database. Ensure you have a separate backup.

If you're using the bundled PostgreSQL, the best way to perform this upgrade is to backup your old
database, and restore into a new database instance. We've automated some of the steps, as an
alternative, you can perform the steps manually.

### Prepare the existing database

Note the following:

- If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
  to perform this step.
- If you have multiple charts installed in the same namespace. It may be necessary to pass the Helm
  release name to the database-upgrade script as well. Replace `bash -s STAGE` with
  `bash -s -- -r RELEASE STAGE` in the example commands provided later.
- If you installed a chart to a namespace other than your `kubectl` context's default, you must pass
  the namespace to the database-upgrade script. Replace `bash -s STAGE` with
  `bash -s -- -n NAMESPACE STAGE` in the example commands provided later. This option can be used
  along with `-r RELEASE`. You can set the context's default namespace by running
  `kubectl config set-context --current --namespace=NAMESPACE`, or using
  [`kubens` from kubectx](https://github.com/ahmetb/kubectx).

The `pre` stage will create a backup of your database using the backup-utility script in the Task Runner, which gets saved to the configured s3 bucket (MinIO by default):

```shell
# GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v3.0.0
curl -s "https://gitlab.com/gitlab-org/charts/gitlab/-/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s pre
```

### Prepare the cluster database secrets

> **NOTICE:** If you are not using the bundled PostgreSQL chart (`postgresql.install` is false):
>
> - If you have supplied `global.psql.password.key`, you do not need to perform this step.
> - If you have supplied `global.psql.password.secret`, additionally set `global.psql.password.key` to the name of your existing key to bypass this step.

The secret key for the application database key is changing from `postgres-password`, to `postgresql-password`. Use one of the two steps described below to update your database password secret:

1. If you'd like to use an auto-generated PostgreSQL password, delete the existing secret to allow the upgrade to generate a new password for you. RELEASE-NAME should be the name of the GitLab release from `helm list`:

   ```shell
   # Create a local copy of the old secret in case we need to restore the old database
   kubectl get secret RELEASE-NAME-postgresql-password -o yaml > postgresql-password.backup.yaml
   # Delete the secret so a new one can be created
   kubectl delete secret RELEASE-NAME-postgresql-password
   ```

1. If you want to use the same password, edit the secret, and change the key from `postgres-password` to `postgresql-password`. Additionally, we need a secret for the superuser account. Add a key for that user `postgresql-postgres-password`:

   ```shell
   # Encode the superuser password into base64
   echo SUPERUSER_PASSWORD | base64
   kubectl edit secret RELEASE-NAME-postgresql-password
   # Make the appropriate changes in your EDITOR window
   ```

### Delete existing services

The `3.0` release updates an immutable field in the NGINX Ingress, this requires us to first delete all the services
before upgrading. You can see more details in our troubleshooting documentation, under [Immutable Field Error, spec.clusterIP](../troubleshooting/index.md#specclusterip).

1. Remove all affected services. RELEASE_NAME should be the name of the GitLab release from `helm list`:

   ```shell
   kubectl delete services -lrelease=RELEASE_NAME
   ```

WARNING:
This will change any dynamic value for the `LoadBalancer` for NGINX Ingress from this chart, if in use. See
[global Ingress settings documentation](../charts/globals.md#configure-ingress-settings) for more details regarding
`externalIP`. You may be required to update DNS records!

### Upgrade GitLab

Upgrade GitLab following our [standard procedure](#steps), with the following additions of:

If you are using the bundled PostgreSQL, disable migrations using the following flag on your upgrade command:

1. `--set gitlab.migrations.enabled=false`

We will perform the migrations for the Database in a later step for the bundled PostgreSQL.

### Restore the Database

Note the following:

- If you are not using the bundled PostgreSQL chart (`postgresql.install` is false), you do not need
  to perform this step.
- You'll need to be using Bash 4.0 or above to run the script successfully as it requires the use of
  bash associative arrays.

1. Wait for the upgrade to complete for the Task Runner pod. RELEASE_NAME should be the name of the GitLab release from `helm list`

   ```shell
   kubectl rollout status -w deployment/RELEASE_NAME-task-runner
   ```

1. After the Task Runner pod is deployed successfully, run the `post` steps:

   This step will do the following:

   1. Set replicas to 0 for the `webservice`, `sidekiq`, and `gitlab-exporter` deployments. This will prevent any other application from altering the database while the backup is being restored.
   1. Restore the database from the backup created in the pre stage.
   1. Run database migrations for the new version.
   1. Resume the deployments from the first step.

   ```shell
   # GITLAB_RELEASE should be the version of the chart you are installing, starting with 'v': v3.0.0
   curl -s "https://gitlab.com/gitlab-org/charts/gitlab/-/raw/${GITLAB_RELEASE}/scripts/database-upgrade" | bash -s post
   ```

### Troubleshooting 3.0 release upgrade process

- Make sure that you are using Helm 2.14.3 or >= 2.16.1 [due to the bug in 2.15.x](../releases/3_0.md#problematic-helm-215).
- If you see any failure during the upgrade, it may be useful to check the description of `gitlab-upgrade-check` pod for details:

  ```shell
  kubectl get pods -lrelease=RELEASE,app=gitlab
  kubectl describe pod <gitlab-upgrade-check-pod-full-name>
  ```

- You may face the error below when running `helm upgrade`:

  ```plaintext
  Error: kind ConfigMap with the name "gitlab-gitlab-shell-sshd" already exists in the cluster and wasn't defined in the previous release.
  Before upgrading, please either delete the resource from the cluster or remove it from the chart
  Error: UPGRADE FAILED: kind ConfigMap with the name "gitlab-gitlab-shell-sshd" already exists in the cluster and wasn't defined in the previous release.
  Before upgrading, please either delete the resource from the cluster or remove it from the chart
  ```

  The error message can also mention other configmaps like `gitlab-redis-health`, `gitlab-redis-headless`, etc.
  To fix it, make sure that the services were removed as mentioned in the [upgrade steps for 3.0 release](#delete-existing-services).
  After that, also delete the configmaps shown in the error message with: `kubectl delete configmap <configmap-name>`.
