---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Maintaining the upgrade stop in the charts project

The GitLab chart creates a pre-upgrade hook that checks if the upgrade follows a
[valid upgrade path](https://docs.gitlab.com/ee/update/#upgrade-paths).

If the upgrade path is invalid, the upgrade will be aborted.

To apply a new upgrade stop:

1. A new upgrade stop must be applied in the next minor release. For example, the 16.3 upgrade stop must be merged into 16.4.
1. Change `MIN_VERSION` and `CHART_MIN_VERSION` in `templates/_runcheck.tpl`.
1. Update the test cases in `scripts/debug/test_runcheck.sh`.
1. Confirm that the test cases pass.
