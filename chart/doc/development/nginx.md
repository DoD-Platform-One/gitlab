---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Working with the bundled NGINX
---

## NGINX

We provide a fork of NGINX with this chart that we maintain via patch files. 
This approach was choosen to easier upgrade NGINX chart versions and have
a better overview of changes that we made.

### Add a new patch

1. Edit the NGINX manifests like you normally would.
1. Create a new patch file based on the diff:

   ```script
   git diff charts/nginx-ingress/ > scripts/nginx-patches/00_new.patch
   ```

   Multiple patch files can change the same NGINX manifest files. That's why patches need to be sorted. When adding a new patch, make sure to increment the `00_` above to a number greater than the last patch we have.

1. Commit the new changes and the patchfile.
1. Run `scripts/update-nginx-chart.sh` to validate all patches apply
   without any uncommited changes.

### Changing an existing patch

1. Apply the patches that are applied before the patch you want to change.
   For example if you want to edit patch 05:

   ```scripts
   scripts/update-nginx-chart.sh 05
   ```

1. Commit the current status.

   ```script
   git add charts/nginx-ingress
   git commit -m "WiP"
   ```

1. Apply the change you want to edit.

   ```script
   git apply ./scripts/nginx-updates/05_*.patch
   ```

1. Edit the NGINX manifests.
1. Update the patch file:

   ```script
   git diff charts/nginx-ingress/ > scripts/nginx-patches/05_updated.patch
   ```

1. Commit the updated manifest and patch files.

   ```script
   git add charts/nginx-ingress/ scripts/
   git commit --amend -m "Update patch 05"
   ```

1. Run `scripts/update-nginx-chart.sh` to validate all patches apply.
1. Commit the updated manifest and patch files.

   ```script
   git commit --amend --no-edit
   ```

### Update the NGINX chart version

1. Edit the version in `update-nginx-chart.sh`.
1. Run `scripts/update-nginx-chart.sh` to validate all patches apply
   without any uncommited changes.
