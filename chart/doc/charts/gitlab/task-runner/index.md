---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Task Runner

The Task Runner Pod is used to execute periodic housekeeping tasks within
the GitLab application. These tasks include backups, Sidekiq maintenance,
and Rake tasks.

## Configuration

The following configuration settings are the default settings provided by the
Task Runner chart:

```yaml
gitlab:
  ## doc/charts/gitlab/task-runner
  task-runner:
    enabled: true
    replicas: 1
    backups:
      cron:
        enabled: false
        concurrencyPolicy: Replace
        persistence:
          enabled: false
          accessMode: 'ReadWriteOnce'
          size: '10Gi'
        resources:
          requests:
            cpu: '50m'
            memory: '350M'
        schedule: '0 1 * * *'
      objectStorage:
        backend: 's3'
        config: {}
    persistence:
      enabled: false
      accessMode: 'ReadWriteOnce'
      size: '10Gi'
    resources:
      requests:
        cpu: '50m'
        memory: '350M'
    securityContext:
      fsGroup: '1000'
      runAsUser: '1000'
```

| Parameter                                   | Description                                  | Default                      |
|---------------------------------------------|----------------------------------------------|------------------------------|
| `annotations`                               | Annotations to add to the Task Runner Pods and Jobs | {}                      |
| `antiAffinityLabels.matchLabels`            | Labels for setting anti-affinity options     |                              |
| `backups.cron.concurrencyPolicy`            | Kubernetes Job concurrency policy            | `Replace`                    |
| `backups.cron.enabled`                      | Backup CronJob enabled flag                  | false                        |
| `backups.cron.extraArgs`                    | String of arguments to pass to the backup utility |                              |
| `backups.cron.failedJobsHistoryLimit`       | Number of failed backup jobs list in history | `1`                          |
| `backups.cron.persistence.accessMode`       | Backup cron persistence access mode          | `ReadWriteOnce`              |
| `backups.cron.persistence.enabled`          | Backup cron enable persistence flag          | false                        |
| `backups.cron.persistence.matchExpressions` | Label-expression matches to bind             |                              |
| `backups.cron.persistence.matchLabels`      | Label-value matches to bind                  |                              |
| `backups.cron.persistence.size`             | Backup cron persistence volume size          | `10Gi`                       |
| `backups.cron.persistence.storageClass`     | StorageClass name for provisioning           |                              |
| `backups.cron.persistence.subPath`          | Backup cron persistence volume mount path    |                              |
| `backups.cron.persistence.volumeName`       | Existing persistent volume name              |                              |
| `backups.cron.resources.requests.cpu`       | Backup cron minimum needed CPU               | `50m`                        |
| `backups.cron.resources.requests.memory`    | Backup cron minimum needed memory            | `350M`                       |
| `backups.cron.schedule`                     | Cron style schedule string                   | `0 1 * * *`                  |
| `backups.cron.successfulJobsHistoryLimit`   | Number of successful backup jobs list in history | `3`                      |
| `backups.objectStorage.backend`             | Object storage provider to use (`s3` or `gcs`) | `s3`                       |
| `backups.objectStorage.config.gcpProject`   | GCP Project to use when backend is `gcs`     | ""                           |
| `backups.objectStorage.config.key`          | Key containing credentials in secret         | ""                           |
| `backups.objectStorage.config.secret`       | Object storage credentials secret            | ""                           |
| `common.labels`                             | Supplemental labels that are applied to all objects created by this chart. | `{}` |
| `deployment.strategy`                       | Allows one to configure the update strategy utilized by the deployment | { `type`: `Recreate` } |
| `enabled`                                   | Task Runner enablement flag                  | true                         |
| `extra`                                     | YAML block for [extra `gitlab.yml` configuration](https://gitlab.com/gitlab-org/gitlab/-/blob/8d2b59dbf232f17159d63f0359fa4793921896d5/config/gitlab.yml.example#L1193-1199) | {}                          |
| `image.pullPolicy`                          | Task Runner image pull policy                | `IfNotPresent`               |
| `image.pullSecrets`                         | Task Runner image pull secrets               |                              |
| `image.repository`                          | Task Runner image repository                 | `registry.gitlab.com/gitlab-org/build/cng/gitlab-task-runner-ee` |
| `image.tag`                                 | Task Runner image tag                        | `master`                     |
| `init.image.repository`                     | Task Runner init image repository            |                              |
| `init.image.tag`                            | Task Runner init image tag                   |                              |
| `init.resources`                            | Task Runner init container resource requirements | { `requests`: { `cpu`: `50m` }} |
| `nodeSelector`                              | Task Runner and backup job node selection    |                              |
| `persistence.accessMode`                    | Task Runner persistence access mode          | `ReadWriteOnce`              |
| `persistence.enabled`                       | Task Runner enable persistence flag          | false                        |
| `persistence.matchExpressions`              | Label-expression matches to bind             |                              |
| `persistence.matchLabels`                   | Label-value matches to bind                  |                              |
| `persistence.size`                          | Task Runner persistence volume size          | `10Gi`                       |
| `persistence.storageClass`                  | StorageClass name for provisioning           |                              |
| `persistence.subPath`                       | Task Runner persistence volume mount path    |                              |
| `persistence.volumeName`                    | Existing PersistentVolume name               |                              |
| `podLabels`                                 | Labels for running Task Runner Pods          | {}                           |
| `replicas`                                  | Number of Task Runner Pods to run            | `1`                          |
| `resources.requests`                        | Task Runner minimum requested resources      | { `cpu`: `50m`, `memory`: `350M` |
| `securityContext.fsGroup`                   | Group ID under which the pod should be started | `1000`                     |
| `securityContext.runAsUser`                 | User ID under which the pod should be started  | `1000`                     |
| `serviceAccount.annotations`                | Annotations for ServiceAccount               | {}                           |
| `serviceAccount.enabled`                    | Flag for using ServiceAccount                | false                        |
| `serviceAccount.create`                     | Flag for creating a ServiceAccount           | false                        |
| `serviceAccount.name`                       | Name of ServiceAccount to use                |                              |
| `tolerations`                               | Tolerations to add to the Task Runner        |                              |

## Configuring backups

Information concerning configuring backups in the
[backup and restore documentation](../../../backup-restore/index.md). Additional
information about the technical implementation of how the backups are
performed can be found in the
[backup and restore architecture documentation](../../../architecture/backup-restore.md).]

## Persistence configuration

The persistent stores for backups and restorations are configured separately.
Please review the following considerations when configuring GitLab for
backup and restore operations.

Backups use the `backup.cron.persistence.*` properties and restorations
use the `persistence.*` properties. Further descriptions concerning the
configuration of a persistence store will use just the final property key
(e.g. `.enabled` or `.size`) and the appropriate prefix will need to be
added.

The persistence stores are disabled by default, thus `.enabled` needs to
be set to `true` for a backup or restoration of any appreciable size.
In addition, either `.storageClass` needs to be specified for a PersistentVolume
to be created by Kubernetes or a PersistentVolume needs to be manually created.
If `.storageClass` is specified as '-', then the PersistentVolume will be
created using the [default StorageClass](https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/)
as specified in the Kubernetes cluster.

If the PersistentVolume is created manually, then the volume can be specified
using the `.volumeName` property or by using the selector `.matchLables` /
`.matchExpressions` properties.

In most cases the default value of `.accessMode` will provide adequate
controls for only Task Runner accessing the PersistentVolumes. Please consult
the documentation for the CSI driver installed in the Kubernetes cluster to
ensure that the setting is correct.

### Backup considerations

A backup operation needs an amount of disk space to hold the individual
components that are being backed up before they are written to the backup
object store. The amount of disk space depends on the following factors:

- Number of projects and the amount of data stored under each project
- Size of the PostgresSQL database (issues, MRs, etc.)
- Size of each object store backend

Once the rough size has been determined, the `backup.cron.persistence.size`
property can be set so that backups can commence.

### Restore considerations

During the restoration of a backup, the backup needs to be extracted to disk
before the files are replaced on the running instance. The size of this
restoration disk space is controlled by the `persistence.size` property. Be
mindful that as the size of the GitLab installation grows the size of the
restoration disk space also needs to grow accordingly. In most cases the
size of the restoration disk space should be the same size as the backup
disk space.

## Task Runner included tools

The Task Runner container contains useful GitLab tools such as Rails console,
Rake tasks, etc. These commands allow one to check the status of the database
migrations, execute Rake tasks for administrative tasks, interact with
the Rails console:

```shell
# locate the Task Runner pod
kubectl get pods -lapp=task-runner

# Launch a shell inside the pod
kubectl exec -it <Task Runner pod name> bash

# open Rails console
gitlab-rails console -e production

# execute a Rake task
gitlab-rake gitlab:env:info
```
