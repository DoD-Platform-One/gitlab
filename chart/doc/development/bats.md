---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Writing bats tests for scripts used in the charts project

The following are notes and conventions used for creating bats tests for the
GitLab chart.

## Naming and structure

Bats test files should be placed in the same directory as the shell script they are testing, with the same file name using `.bats` extension instead of `.sh`.

```shell
./scripts/ci/pin_image_digests.sh    # Script to be tested
./scripts/ci/pin_image_digests.bats  # Bats tests
```

This convention makes it easy to find bats test files alongside the scripts they are testing.

## Filtering bats tests

To aid in development it is possible to filter which tests are executed by
passing the `-f` flag to regex match by test case names.

The following example will run only tests with "rendering" in their name.

```shell
bats scripts/ci/pin_image_digests.bats -f 'rendering'
```

Tests can also be filtered by tag, see [bats documentation](https://bats-core.readthedocs.io/en/stable/writing-tests.html#tagging-tests) for examples.

## Viewing output of run commands

When writing or debugging tests, running bats with the `--verbose-run` flag will print `$output` to the screen.
This is often helpful when debugging regex matches, and is used when running bats in CI.
