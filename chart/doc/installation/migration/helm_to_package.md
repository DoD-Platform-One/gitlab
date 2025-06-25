---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Migrate from the Helm chart to the Linux package
---

{{< details >}}

- Tier: Free, Premium, Ultimate
- Offering: GitLab Self-Managed

{{< /details >}}

To migrate from a Helm installation to a Linux package (Omnibus) installation:

1. On the left sidebar, at the bottom, select **Admin Area**.
1. Select **Overview > Components** to check your current version of GitLab.
1. Prepare a clean machine and
   [install the Linux package](https://docs.gitlab.com/update/package/)
   that matches your GitLab Helm chart version.
1. [Verify the integrity of Git repositories](https://docs.gitlab.com/administration/raketasks/check/)
   on your GitLab Helm chart instance before the migration.
1. Create [a backup of your GitLab Helm chart instance](../../backup-restore/backup.md),
   and make sure to [back up the secrets](../../backup-restore/backup.md#back-up-the-secrets)
   as well.
1. Back up `/etc/gitlab/gitlab-secrets.json` on your Linux package instance.
1. Install the [yq](https://github.com/mikefarah/yq) tool (version 4.21.1 or later) on the workstation where you run `kubectl` commands.
1. Create a copy of your `/etc/gitlab/gitlab-secrets.json` file on your workstation.
1. Run the following command to obtain the secrets from your GitLab Helm chart instance.
   Replace `GITLAB_NAMESPACE` and `RELEASE` with appropriate values:

   ```shell
   kubectl get secret -n GITLAB_NAMESPACE RELEASE-rails-secret -ojsonpath='{.data.secrets\.yml}' | yq '@base64d | from_yaml | .production' -o json > rails-secrets.json
   yq eval-all 'select(filename == "gitlab-secrets.json").gitlab_rails = select(filename == "rails-secrets.json") | select(filename == "gitlab-secrets.json")' -ojson  gitlab-secrets.json rails-secrets.json > gitlab-secrets-updated.json
   ```

1. The result is `gitlab-secrets-updated.json`, which you can use to replace the old version of `/etc/gitlab/gitlab-secrets.json`
   on your Linux package instance.
1. After replacing `/etc/gitlab/gitlab-secrets.json`, reconfigure your Linux package instance:

   ```shell
   sudo gitlab-ctl reconfigure
   ```

1. In the Linux package instance, configure [object storage](https://docs.gitlab.com/administration/object_storage/),
   and make sure it works by testing LFS, artifacts, uploads, and so on.
1. If you use the Container Registry, [configure its object storage separately](https://docs.gitlab.com/administration/packages/container_registry/#use-object-storage). It does not support
   the consolidated object storage.
1. Sync the data from your object storage connected to the Helm chart instance with the new storage
   connected to the Linux package instance. A couple of notes:

   - For S3-compatible storages, use the `s3cmd` utility to copy the data.
   - If you plan to use an S3-compatible object storage like MinIO with your
     Linux package instance, you should configure the options `endpoint`
     pointing to your MinIO and set `path_style` to `true` in
     `/etc/gitlab/gitlab.rb`.
   - You may re-use your old object storage with the new Linux package instance. In this case, you
     do not need to sync data between two object storages. However, the storage could be de-provisioned when
     you uninstall GitLab Helm chart if you are using the built-in MinIO instance.

1. Copy the GitLab Helm backup to `/var/opt/gitlab/backups` on your Linux package GitLab instance, and
   [perform the restore](https://docs.gitlab.com/administration/backup_restore/restore_gitlab/#restore-for-linux-package-installations).
1. (Optional) Restore SSH host keys to avoid host mismatch errors on Git SSH clients:

   1. Convert [`<name>-gitlab-shell-host-keys` secret](../secrets.md#ssh-host-keys) back to files using the following script (required tools: `jq`, `base64`, and `kubectl`):

      ```shell
      mkdir ssh
      HOSTKEYS_JSON="hostkeys.json"
      GITLAB_NAMESPACE="my_namespace"
      kubectl get secret -n ${GITLAB_NAMESPACE} gitlab-gitlab-shell-host-keys -o json > ${HOSTKEYS_JSON}

      for k in $(jq -r '.data | keys | .[]' ${HOSTKEYS_JSON}); \
      do \
        jq -r --arg host_key ${k} '.data[$host_key]' ${HOSTKEYS_JSON}  | base64 --decode > ssh/$k ; \
      done
      ```
       
   1. Upload the converted files to the GitLab Rails nodes.
   1. On the target Rails node:
      1. Back up the `/etc/ssh/` directory, for example:

         ```shell
         sudo tar -czvf /root/ssh_dir.tar.gz -C /etc ssh
         ```

      1. Remove the existing host keys:

         ```shell
         sudo find /etc/ssh -type f -name "/etc/ssh/ssh_*_key*" -delete
         ```

      1. Move the converted host key files in place (`/etc/ssh`):
        
         ```shell
         for f in ssh/*; do sudo install -b -D  -o root -g root -m 0600 $f /etc/${f} ; done
         ```

      1. Restart the SSH daemon:

         ```shell
         sudo systemctl restart ssh.service
         ```

1. After the restore is complete, run the [doctor Rake tasks](https://docs.gitlab.com/administration/raketasks/check/)
   to make sure that the secrets are valid.
1. After everything is verified, you may [uninstall](../uninstall.md)
   the GitLab Helm chart instance.
