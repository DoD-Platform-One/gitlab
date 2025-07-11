---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Restoring a GitLab installation
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

To obtain a backup tarball of an existing GitLab instance that used other installation methods like the Linux
package or GitLab Helm chart, follow the instructions
[given in documentation](https://docs.gitlab.com/administration/backup_restore/backup_gitlab/).

If you are restoring a backup taken from another instance, you must migrate your existing instance to using object storage
before taking the backup. See [issue 646](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/646).

It is recommended that you restore a backup to the same version of GitLab on which it was created.

GitLab backup restores are taken by running the `backup-utility` command on the Toolbox pod provided in the chart.

Before running the restore for the first time, you should ensure the [Toolbox is properly configured](_index.md) for
access to [object storage](_index.md#object-storage)

The backup utility provided by GitLab Helm chart supports restoring a tarball from any of the following locations

1. The `gitlab-backups` bucket in the object storage service associated to the instance. This is the default scenario.
1. A public URL that can be accessed from the pod.
1. A local file that you can copy to the Toolbox pod using `kubectl cp`

## Restoring the secrets

### Restore the rails secrets

{{<alert type="note">}}

Hybrid environments deployed using the [GitLab Environment Toolkit (GET)](https://docs.gitlab.com/install/install_methods/#gitlab-environment-toolkit-get) perform automatic secret
synchronisation between Omnibus nodes and Kubernetes that needs to be considered when performing a restore. Refer to
[this section](https://gitlab.com/gitlab-org/gitlab-environment-toolkit/-/blob/main/docs/environment_post_considerations.md#restores) of the GET documentation for details.

{{</alert>}}

The GitLab chart expects rails secrets to be provided as a Kubernetes Secret with content in YAML. If you are restoring
the rails secret from a Linux package instance, secrets are stored in JSON format in the `/etc/gitlab/gitlab-secrets.json` file. To convert the file and create the secret in YAML format:

1. Copy the file `/etc/gitlab/gitlab-secrets.json` to the workstation where you run `kubectl` commands.

1. Install the [yq](https://github.com/mikefarah/yq) tool (version 4.21.1 or later) on your workstation.

1. Run the following command to convert your `gitlab-secrets.json` to YAML format:

   ```shell
   yq -P '{"production": .gitlab_rails}' gitlab-secrets.json -o yaml >> gitlab-secrets.yaml
   ```

1. Check that the new `gitlab-secrets.yaml` file has the following contents:

   ```YAML
   production:
     db_key_base: <your key base value>
     secret_key_base: <your secret key base value>
     otp_key_base: <your otp key base value>
     openid_connect_signing_key: <your openid signing key>
     active_record_encryption_primary_key:
     - 'your active record encryption primary key'
     active_record_encryption_deterministic_key:
     - 'your active record encryption deterministic key'
     active_record_encryption_key_derivation_salt: 'your active record key derivation salt'
   ```

To restore the rails secrets from a YAML file:

1. Find the object name for the rails secrets:

   ```shell
   kubectl get secrets | grep rails-secret
   ```

1. Delete the existing secret:

   ```shell
   kubectl delete secret <rails-secret-name>
   ```

1. Create the new secret using the same name as the old, and passing in your local YAML file

   ```shell
   kubectl create secret generic <rails-secret-name> --from-file=secrets.yml=gitlab-secrets.yaml
   ```

### Restart the pods

In order to use the new secrets, the Webservice, Sidekiq and Toolbox pods
need to be restarted. The safest way to restart those pods is to run:

```shell
kubectl delete pods -lapp=sidekiq,release=<helm release name>
kubectl delete pods -lapp=webservice,release=<helm release name>
kubectl delete pods -lapp=toolbox,release=<helm release name>
```

## Restoring the backup file

The steps for restoring a GitLab installation are

1. Make sure you have a running GitLab instance by deploying the charts. Ensure the Toolbox pod is enabled and running by executing the following command

   ```shell
   kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
   ```

1. Get the tarball ready in any of the above locations. Make sure it is named in the `<backup_ID>_gitlab_backup.tar` format. Read what the [backup ID](https://docs.gitlab.com/administration/backup_restore/backup_archive_process/#backup-id) is about.

1. Note the current number of replicas for database clients for subsequent restart:

   ```shell
   kubectl get deploy -n <namespace> -lapp=sidekiq,release=<helm release name> -o jsonpath='{.items[].spec.replicas}{"\n"}'
   kubectl get deploy -n <namespace> -lapp=webservice,release=<helm release name> -o jsonpath='{.items[].spec.replicas}{"\n"}'
   kubectl get deploy -n <namespace> -lapp=prometheus,release=<helm release name> -o jsonpath='{.items[].spec.replicas}{"\n"}'
   ```

1. Stop the clients of the database to prevent locks interfering with the restore process:

   ```shell
   kubectl scale deploy -lapp=sidekiq,release=<helm release name> -n <namespace> --replicas=0
   kubectl scale deploy -lapp=webservice,release=<helm release name> -n <namespace> --replicas=0
   kubectl scale deploy -lapp=prometheus,release=<helm release name> -n <namespace> --replicas=0
   ```

1. Run the backup utility to restore the tarball

   ```shell
   kubectl exec <Toolbox pod name> -it -- backup-utility --restore -t <backup_ID>
   ```

   Here, `<backup_ID>` is from the name of the tarball stored in `gitlab-backups` bucket. In case you want to provide a public URL, use the following command:

   ```shell
   kubectl exec <Toolbox pod name> -it -- backup-utility --restore -f <URL>
   ```

    You can provide a local path as a URL as long as it's in the format: `file:///<path>`

1. This process will take time depending on the size of the tarball.
1. The restoration process will erase the existing contents of database, move existing repositories to temporary locations and extract the contents of the tarball. Repositories will be moved to their corresponding locations on the disk and other data, like artifacts, uploads, LFS etc. will be uploaded to corresponding buckets in Object Storage.

1. Restart the application:

   ```shell
   kubectl scale deploy -lapp=sidekiq,release=<helm release name> -n <namespace> --replicas=<value>
   kubectl scale deploy -lapp=webservice,release=<helm release name> -n <namespace> --replicas=<value>
   kubectl scale deploy -lapp=prometheus,release=<helm release name> -n <namespace> --replicas=<value>
   ```

{{< alert type="note" >}}

During restoration, the backup tarball needs to be extracted to disk.
This means the Toolbox pod should have disk of necessary size available.
For more details and configuration please see the [Toolbox documentation](../charts/gitlab/toolbox/_index.md#persistence-configuration).

{{< /alert >}}

### Restore the runner registration token

After restoring, the included runner will not be able to register to the instance because it no longer has the correct registration token.
Follow these [troubleshooting steps](../troubleshooting/_index.md#included-gitlab-runner-failing-to-register) to get it updated.

## Enable Kubernetes related settings

If the restored backup was not from an existing installation of the chart, you will also need to enable some Kubernetes specific features after the restore. Such as
[incremental CI job logging](https://docs.gitlab.com/administration/cicd/job_logs/#incremental-logging-architecture).

1. Find your Toolbox pod by executing the following command

   ```shell
   kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
   ```

1. Run the instance setup script to enable the necessary features

   ```shell
   kubectl exec <Toolbox pod name> -it -- gitlab-rails runner -e production /scripts/custom-instance-setup
   ```

## Restart the pods

In order to use the new changes, the Webservice and Sidekiq pods need to be restarted. The safest way to restart those pods is to run:

```shell
kubectl delete pods -lapp=sidekiq,release=<helm release name>
kubectl delete pods -lapp=webservice,release=<helm release name>
```

## (Optional) Reset the root user's password

The restoration process does not update the `gitlab-initial-root-password` secret with the value from backup. For logging in as `root`, use the original password included in the backup. In the case that the password is no longer accessible, follow the steps below to reset it.

1. Attach to the Webservice pod by executing the command

   ```shell
   kubectl exec <Webservice pod name> -it -- bash
   ```

1. Run the following command to reset the password of `root` user. Replace `#{password}` with a password of your choice

   ```shell
   /srv/gitlab/bin/rails runner "user = User.first; user.password='#{password}'; user.password_confirmation='#{password}'; user.save!"
   ```

## Additional Information

- [GitLab chart Backup/Restore Introduction](_index.md)
- [Backing up a GitLab installation](backup.md)
