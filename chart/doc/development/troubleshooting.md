---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Troubleshooting GitLab chart development environment

All steps noted here are for **DEVELOPMENT ENVIRONMENTS ONLY**.
Administrators may find the information insightful, but the outlined fixes
are destructive and would have a major negative impact on production
systems.

## Passwords and secrets failing or unsynchronized

Developers commonly deploy, delete, and re-deploy a release into the same
cluster multiple times. Kubernetes secrets and persistent volume claims created by StatefulSets are
intentionally not removed by `helm delete RELEASE_NAME`.

Removing only the Kubernetes secrets leads to interesting problems. For
example, a new deployment's migration pod will fail because **GitLab Rails**
cannot connect to the database because it has the wrong password.

To completely wipe a release from a development environment including
secrets, a developer must remove both the secrets and the persistent volume
claims.

```shell
# DO NOT run these commands in a production environment. Disaster will strike.
kubectl delete secrets,pvc -lrelease=RELEASE_NAME
```

NOTE:
This deletes all Kubernetes secrets including TLS certificates and all data
in the database. This should not be performed in a production instance.

## Database is broken and needs reset

The database environment can be reset in a development environment by:

1. Delete the PostgreSQL StatefulSet
1. Delete the PostgreSQL PersistentVolumeClaim
1. Deploy GitLab again with `helm upgrade --install`

NOTE:
This will delete all data in the databases and should not be run in
production.

## Backup used for testing needs to be updated

Certain jobs in CI use a backup of GitLab during testing. Complete the steps below to update this backup when needed:

1. Generate the desired backup by running a CI pipeline for the matching stable branch.
   1. For example: run a CI pipeline for branch `5-4-stable` if current release is `5-5-stable` to create a backup of 14.4.
   1. Note that this will require the Maintainer role.
1. In that pipeline, cancel the QA jobs (but leave the spec tests) so that we don't get extra data in the backup.
1. Let the spec tests finish. They will have installed the old backup, and migrated the instance to the version we want.
1. Edit the `gitlab-runner` Deployment replicas to 0, so the Runner turns off.
1. Log in to the UI and delete the Runner from the admin section. This should help avoid cipher errors later.
1. [Ensure the background migrations all complete](https://docs.gitlab.com/ee/update/#check-for-background-migrations-before-upgrading), forcing them to complete if needed.
1. Delete the `toolbox` Pod to ensure there is no existing `tmp` data, keeping the backup small.
1. If any manual work is needed to modify the contents of the backup, complete it before moving on to the next step.
1. [Create a new backup](../backup-restore/backup.md) from the new `toolbox` Pod.
1. Download the new backup from the CI instance of MinIO in the `gitlab-backups` bucket.
1. Upload the backup to the proper location in Google Cloud Storage (GCS):
   1. Project: `cloud-native-182609`, path: `gitlab-charts-ci/test-backups/`
   1. Edit access and add `Entity=Public`, `Name=allUsers`, and `Access=Reader`.
1. Finally, update `.variables.TEST_BACKUP_PREFIX` in `.gitlab-ci.yml` to the new version of the backup.
   - For example: If the filename is `1708623546_2024_02_22_16.9.1-ee_gitlab_backup`, then the prefix is `1708623546_2024_02_22_16.9.1-ee`.

Future pipelines will now use the new backup artifact during testing.

## CI clusters are low on available resources

You may notice one or more CI clusters run low on available resources like CPU
and memory. Our clusters are configured to automatically scale the available
nodes, but sometimes we hit the upper limit and therefore no more nodes can be
created. In this case, a good first step is to see if any installations of the
GitLab Helm Charts in the clusters can be removed.

Installations are usually cleaned up automatically by the Review Apps logic in
the pipeline, but this can fail for various reasons. See the following issues
for more details:

- [What can we do about cleaning up failed deploys in CI?](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/2076)
- [https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5338](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5338)

As a workaround, these installations can be manually deleted by running the associated
`stop_review` job(s) in CI. To make this easier, use the
[`helm_ci_triage.sh`](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/ci/helm_ci_triage.sh)
script to get a list of running installations and open the associated pipeline to run
the `stop_review` job(s). Further usage details are available in the script.
