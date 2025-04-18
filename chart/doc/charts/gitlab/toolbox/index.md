---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Toolbox

DETAILS:
**Tier:** Free, Premium, Ultimate
**Offering:** Self-managed

The Toolbox Pod is used to execute periodic housekeeping tasks within
the GitLab application. These tasks include backups, Sidekiq maintenance,
and Rake tasks.

## Configuration

The following configuration settings are the default settings provided by the
Toolbox chart:

```yaml
gitlab:
  ## doc/charts/gitlab/toolbox
  toolbox:
    enabled: true
    replicas: 1
    backups:
      cron:
        enabled: false
        concurrencyPolicy: Replace
        failedJobsHistoryLimit: 1
        schedule: "0 1 * * *"
        successfulJobsHistoryLimit: 3
        suspend: false
        backoffLimit: 6
        safeToEvict: false
        restartPolicy: "OnFailure"
        resources:
          requests:
            cpu: 50m
            memory: 350M
        persistence:
          enabled: false
          accessMode: ReadWriteOnce
          useGenericEphemeralVolume: false
          size: 10Gi
      objectStorage:
        backend: s3
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
      runAsGroup: '1000'
    containerSecurityContext:
      runAsUser: '1000'
    affinity: {}
```

| Parameter                                                | Description                                                                                                                                                                                                               | Default                                                      |
|----------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| `affinity`                                  | [Affinity rules](../index.md#affinity) for pod assignment                                                                                                                                                                 | `{}`                         |
| `annotations`                                            | Annotations to add to the Toolbox Pods and Jobs                                                                                                                                                                           | `{}`                                                         |
| `common.labels`                                          | Supplemental labels that are applied to all objects created by this chart.                                                                                                                                                | `{}`                                                         |
| `antiAffinityLabels.matchLabels`                         | Labels for setting anti-affinity options                                                                                                                                                                                  |                                                              |
| `backups.cron.activeDeadlineSeconds`                     | Backup CronJob active deadline seconds (if null, no active deadline is applied)                                                                                                                                           | `null` |
| `backups.cron.ttlSecondsAfterFinished`      | Backup CronJob job time to live after finished (if null, no time to liveis applied)                                                                                                                                       | `null`                                                       |
| `backups.cron.safeToEvict`                               | Autoscaling safe-to-evict annotation                                                                                                                                                                                      | false                                                        |
| `backups.cron.backoffLimit`                              | Backup CronJob backoff limit                                                                                                                                                                                              | `6`                                                          |
| `backups.cron.concurrencyPolicy`                         | Kubernetes Job concurrency policy                                                                                                                                                                                         | `Replace`                                                    |
| `backups.cron.enabled`                                   | Backup CronJob enabled flag                                                                                                                                                                                               | false                                                        |
| `backups.cron.extraArgs`                                 | String of arguments to pass to the backup utility                                                                                                                                                                         |                                                              |
| `backups.cron.failedJobsHistoryLimit`                    | Number of failed backup jobs list in history                                                                                                                                                                              | `1`                                                          |
| `backups.cron.persistence.accessMode`                    | Backup cron persistence access mode                                                                                                                                                                                       | `ReadWriteOnce`                                              |
| `backups.cron.persistence.enabled`                       | Backup cron enable persistence flag                                                                                                                                                                                       | false                                                        |
| `backups.cron.persistence.matchExpressions`              | Label-expression matches to bind                                                                                                                                                                                          |                                                              |
| `backups.cron.persistence.matchLabels`                   | Label-value matches to bind                                                                                                                                                                                               |                                                              |
| `backups.cron.persistence.useGenericEphemeralVolume`     | Use a [generic ephemeral volume](https://kubernetes.io/docs/concepts/storage/ephemeral-volumes/#generic-ephemeral-volumes)                                                                                                | false                                                        |
| `backups.cron.persistence.size`                          | Backup cron persistence volume size                                                                                                                                                                                       | `10Gi`                                                       |
| `backups.cron.persistence.storageClass`                  | StorageClass name for provisioning                                                                                                                                                                                        |                                                              |
| `backups.cron.persistence.subPath`                       | Backup cron persistence volume mount path                                                                                                                                                                                 |                                                              |
| `backups.cron.persistence.volumeName`                    | Existing persistent volume name                                                                                                                                                                                           |                                                              |
| `backups.cron.resources.requests.cpu`                    | Backup cron minimum needed CPU                                                                                                                                                                                            | `50m`                                                        |
| `backups.cron.resources.requests.memory`                 | Backup cron minimum needed memory                                                                                                                                                                                         | `350M`                                                       |
| `backups.cron.restartPolicy`                             | Backup cron restart policy (`Never` or `OnFailure`)                                                                                                                                                                       | `OnFailure`                                                  |
| `backups.cron.schedule`                                  | Cron style schedule string                                                                                                                                                                                                | `0 1 * * *`                                                  |
| `backups.cron.startingDeadlineSeconds`                   | Backup cron job starting deadline, in seconds (if null, no starting deadline is applied)                                                                                                                                  | `null`                                                       |
| `backups.cron.successfulJobsHistoryLimit`                | Number of successful backup jobs list in history                                                                                                                                                                          | `3`                                                          |
| `backups.cron.suspend`                                   | Backup cron job is suspended                                                                                                                                                                                              | `false`                                                      |
| `backups.cron.timeZone`                     | Time zone for the backup schedule. For more information, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#time-zones). Uses the cluster time zone if not specified. | ""                      |
| `backups.cron.tolerations`                  | Tolerations to add to the backup cron job                                                                                                                                                                                 | ""                           |
| `backups.cron.nodeSelector`                 | Backup cron job node selection                                                                                                                                                                                            | ""                           |
| `backups.objectStorage.backend`                          | Object storage provider to use (`s3`, `gcs` or `azure`)                                                                                                                                                                   | `s3`                                                         |
| `backups.objectStorage.config.gcpProject`                | GCP Project to use when backend is `gcs`                                                                                                                                                                                  | ""                                                           |
| `backups.objectStorage.config.key`                       | Key containing credentials in secret                                                                                                                                                                                      | ""                                                           |
| `backups.objectStorage.config.secret`                    | Object storage credentials secret                                                                                                                                                                                         | ""                                                           |
| `common.labels`                                          | Supplemental labels that are applied to all objects created by this chart.                                                                                                                                                | `{}`                                                         |
| `deployment.strategy`                                    | Allows one to configure the update strategy utilized by the deployment                                                                                                                                                    | { `type`: `Recreate` }                                       |
| `enabled`                                                | Toolbox enablement flag                                                                                                                                                                                                   | true                                                         |
| `extra`                                                  | YAML block for [extra `gitlab.yml` configuration](https://gitlab.com/gitlab-org/gitlab/-/blob/8d2b59dbf232f17159d63f0359fa4793921896d5/config/gitlab.yml.example#L1193-1199)                                              | {}                                                           |
| `image.pullPolicy`                                       | Toolbox image pull policy                                                                                                                                                                                                 | `IfNotPresent`                                               |
| `image.pullSecrets`                                      | Toolbox image pull secrets                                                                                                                                                                                                |                                                              |
| `image.repository`                                       | Toolbox image repository                                                                                                                                                                                                  | `registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee` |
| `image.tag`                                              | Toolbox image tag                                                                                                                                                                                                         | `master`                                                     |
| `init.image.repository`                                  | Toolbox init image repository                                                                                                                                                                                             |                                                              |
| `init.image.tag`                                         | Toolbox init image tag                                                                                                                                                                                                    |                                                              |
| `init.resources`                                         | Toolbox init container resource requirements                                                                                                                                                                              | { `requests`: { `cpu`: `50m` }}                              |
| `init.containerSecurityContext`                          | initContainer specific [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core)                                                                                    |                                                              |
| `init.containerSecurityContext.allowPrivilegeEscalation` | initContainer specific: Controls whether a process can gain more privileges than its parent process                                                                                                                       | `false`                                                      |
| `init.containerSecurityContext.runAsUser`                | initContainer specific: User ID under which the container should be started                                                                                                                                               | `1000`                                                       |
| `init.containerSecurityContext.allowPrivilegeEscalation` | initContainer specific: Controls whether a process can gain more privileges than its parent process                                                                                                                       | `false`                                                      |
| `init.containerSecurityContext.runAsNonRoot`             | initContainer specific: Controls whether the container runs with a non-root user                                                                                                                                          | `true`                                                       |
| `init.containerSecurityContext.capabilities.drop`        | initContainer specific: Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the container                                                                                         | `[ "ALL" ]`                                                  |
| `nodeSelector`                                           | Toolbox and backup job node selection                                                                                                                                                                                     |                                                              |
| `persistence.accessMode`                                 | Toolbox persistence access mode                                                                                                                                                                                           | `ReadWriteOnce`                                              |
| `persistence.enabled`                                    | Toolbox enable persistence flag                                                                                                                                                                                           | false                                                        |
| `persistence.matchExpressions`                           | Label-expression matches to bind                                                                                                                                                                                          |                                                              |
| `persistence.matchLabels`                                | Label-value matches to bind                                                                                                                                                                                               |                                                              |
| `persistence.size`                                       | Toolbox persistence volume size                                                                                                                                                                                           | `10Gi`                                                       |
| `persistence.storageClass`                               | StorageClass name for provisioning                                                                                                                                                                                        |                                                              |
| `persistence.subPath`                                    | Toolbox persistence volume mount path                                                                                                                                                                                     |                                                              |
| `persistence.volumeName`                                 | Existing PersistentVolume name                                                                                                                                                                                            |                                                              |
| `podLabels`                                              | Labels for running Toolbox Pods                                                                                                                                                                                           | {}                                                           |
| `priorityClassName`                                      | [Priority class](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/) assigned to pods.                                                                                                      |                                                              |
| `replicas`                                               | Number of Toolbox Pods to run                                                                                                                                                                                             | `1`                                                          |
| `resources.requests`                                     | Toolbox minimum requested resources                                                                                                                                                                                       | { `cpu`: `50m`, `memory`: `350M`                             |
| `securityContext.fsGroup`                                | File System Group ID under which the pod should be started                                                                                                                                                                | `1000`                                                       |
| `securityContext.runAsUser`                              | User ID under which the pod should be started                                                                                                                                                                             | `1000`                                                       |
| `securityContext.runAsGroup`                             | Group ID under which the pod should be started                                                                                                                                                                            | `1000`                                                       |
| `securityContext.fsGroupChangePolicy`                    | Policy for changing ownership and permission of the volume (requires Kubernetes 1.23)                                                                                                                                     |                                                              |
| `securityContext.seccompProfile.type`                    | Seccomp profile to use                                                                                                                                                                                                    | `RuntimeDefault`                                             |
| `containerSecurityContext`                               | Override container [securityContext](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.25/#securitycontext-v1-core) under which the container is started                                                   |                                                              |
| `containerSecurityContext.runAsUser`                     | Allow to overwrite the specific security context under which the container is started                                                                                                                                     | `1000`                                                       |
| `containerSecurityContext.allowPrivilegeEscalation`      | Controls whether a process of the container can gain more privileges than its parent process                                                                                                                              | `false`                                                      |
| `containerSecurityContext.runAsNonRoot`                  | Controls whether the container runs with a non-root user                                                                                                                                                                  | `true`                                                       |
| `containerSecurityContext.capabilities.drop`             | Removes [Linux capabilities](https://man7.org/linux/man-pages/man7/capabilities.7.html) for the Gitaly container                                                                                                          | `[ "ALL" ]`                                                  |
| `serviceAccount.annotations`                             | Annotations for ServiceAccount                                                                                                                                                                                            | {}                                                           |
| `serviceAccount.automountServiceAccountToken`| Indicates whether or not the default ServiceAccount access token should be mounted in pods                                                                                                                                | `false`    |
| `serviceAccount.enabled`                                 | Indicates whether or not to use a ServiceAccount                                                                                                                                                                          | false                                                        |
| `serviceAccount.create`                                  | Indicates whether or not a ServiceAccount should be created                                                                                                                                                               | false                                                        |
| `serviceAccount.name`                                    | Name of the ServiceAccount. If not set, the full chart name is used                                                                                                                                                       |                                                              |
| `tolerations`                                            | Tolerations to add to the Toolbox                                                                                                                                                                                         |                                                              |
| `extraEnvFrom`                                           | List of extra environment variables from other data sources to expose                                                                                                                                                     |                                                              |

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

Backups use the `backups.cron.persistence.*` properties and restorations
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
controls for only Toolbox accessing the PersistentVolumes. Please consult
the documentation for the CSI driver installed in the Kubernetes cluster to
ensure that the setting is correct.

### Backup considerations

A backup operation needs an amount of disk space to hold the individual
components that are being backed up before they are written to the backup
object store. The amount of disk space depends on the following factors:

- Number of projects and the amount of data stored under each project
- Size of the PostgresSQL database (issues, MRs, etc.)
- Size of each object store backend

Once the rough size has been determined, the `backups.cron.persistence.size`
property can be set so that backups can commence.

### Restore considerations

During the restoration of a backup, the backup needs to be extracted to disk
before the files are replaced on the running instance. The size of this
restoration disk space is controlled by the `persistence.size` property. Be
mindful that as the size of the GitLab installation grows the size of the
restoration disk space also needs to grow accordingly. In most cases the
size of the restoration disk space should be the same size as the backup
disk space.

## Toolbox included tools

The Toolbox container contains useful GitLab tools such as Rails console,
Rake tasks, etc. These commands allow one to check the status of the database
migrations, execute Rake tasks for administrative tasks, interact with
the Rails console:

```shell
# locate the Toolbox pod
kubectl get pods -lapp=toolbox

# Launch a shell inside the pod
kubectl exec -it <Toolbox pod name> -- bash

# open Rails console
gitlab-rails console -e production

# execute a Rake task
gitlab-rake gitlab:env:info
```

### affinity

For more information, see [`affinity`](../index.md#affinity).
