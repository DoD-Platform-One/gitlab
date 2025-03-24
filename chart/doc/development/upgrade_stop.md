---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Maintaining the upgrade stop in the charts project
---

The GitLab chart creates a pre-upgrade hook that checks if the upgrade follows a
[valid upgrade path](https://docs.gitlab.com/update/#upgrade-paths).

If the upgrade path is invalid, the upgrade will be aborted.

The release-tools automatically bumps the upgrade stops. [Here is an example](https://gitlab.com/gitlab-org/charts/gitlab/-/commit/60003f89c8ab633d4e4b16cbc4002c1059627bac).
