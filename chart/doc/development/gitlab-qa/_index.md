---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Running GitLab QA
---

The following documentation is meant to provide instructions for running
[GitLab QA](https://gitlab.com/gitlab-org/gitlab-qa) against a deployed cloud
native GitLab installation. These steps are performed as a part of the
[CI for this project](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/.gitlab-ci.yml)
but manual runs may be requested during development or a demo.

## Preparation

Before running GitLab QA, there are a few things to do.

### Determine running version of GitLab

From your deployed GitLab chart, visit `/admin` and see the Components panel
for the version of GitLab that is running. If this is `X.Y.Z-pre`, then you
will want the `nightly` image. If this is `X.Y.Z-ee`, then you will want this
version of GitLab QA image.

Export `GITLAB_VERSION` based on what you have observed:

```shell
export GITLAB_VERSION=11.0.3-ee
```

or:

```shell
export GITLAB_VERSION=nightly
```

### Network access

To run GitLab QA, you will need sustained network access to the deployed instance.
Ensure this by visiting the deployment from any browser, or via cURL.

## Running GitLab QA in pipeline

To run GitLab QA tests against the deployed instance you can use [GitLab QA Executor](https://gitlab.com/gitlab-org/quality/gitlab-qa-executor). This project contains CI configuration to run GitLab QA against GitLab Self-Managed environments with parallelization that automates the following manual steps for running GitLab QA from a local machine.

## Running GitLab QA from local machine

Follow below instructions to run GitLab QA against the deployed instance
from your local machine.

### Install the `gitlab-qa` gem

Ensure you have a functional version of Ruby, preferably of the `3.0` branch.
Install the `gitlab-qa` gem:

```shell
gem install gitlab-qa
```

For more info, see the [GitLab QA documentation](https://gitlab.com/gitlab-org/gitlab-qa#how-can-you-use-it).

### Docker

GitLab QA makes use of Docker, so you will need to have an operational
installation. Ensure that the daemon is running. If you have set `GITLAB_VERSION=nightly`,
pull the GitLab QA nightly image to ensure that the latest nightly is used for
testing, in conjunction with the nightly builds of the CNG containers:

```shell
docker pull gitlab/gitlab-ee-qa:$GITLAB_VERSION
```

### Configuration

Items needed for execution, which
[will be set as environment variables](https://gitlab.com/gitlab-org/gitlab-qa#supported-environment-variables):

- `GITLAB_VERSION`: The version of GitLab QA version to run. See [determine running version of GitLab](#determine-running-version-of-gitlab) above.
- `GITLAB_USERNAME`: This will be `root`.
- `GITLAB_PASSWORD`: This will be the password for the `root` user.
- `GITLAB_ADMIN_USERNAME`: This will be `root`.
- `GITLAB_ADMIN_PASSWORD`: This will be the password for the `root` user.
- `GITLAB_URL`: The fully-qualified URL to the deployed instance. This should be
  in the form of `https://gitlab.domain.tld`.
- `EE_LICENSE`: A string containing a GitLab EE license. This can be handled
  via `export EE_LICENSE=$(cat GitLab.gitlab-license)`.

Retrieve the above items, and export them as environment variables.

### Select test suite

GitLab QA has multiple test suites to run against the standalone environment. Suite consists of subset of tests
when end-to-end tests are grouped by various [RSpec metadata](https://docs.gitlab.com/development/testing_guide/end_to_end/rspec_metadata_tests/):

- _Smoke suite_: small [subset of fast end-to-end functional tests](https://docs.gitlab.com/development/testing_guide/smoke/)
to quickly ensure that basic functionality is working
  - Enable this suite via `export QA_OPTIONS="--tag smoke"`
- _Full suite_: running all tests against the environment. Test run will take more than an hour.
  - Enable this suite via `--tag ~skip_live_env --tag ~orchestrated --tag ~requires_praefect --tag ~github --tag ~requires_git_protocol_v2 --tag ~transient`

Selecting a test suite depends on the use case. In the majority of cases, running
Smoke suite should give quick and consistent test results
as well as a good test coverage. This suite is being used as a sanity
check in [GitLab.com deployments](https://handbook.gitlab.com/handbook/engineering/deployments-and-releases/deployments/#gitlabcom-deployments-process).

Full suite should be used to get full test results on the environment. It can be resource
intensive to run this suite from a local machine. Use `export CHROME_DISABLE_DEV_SHM=true`
when running Full suite from a single machine.

## Execution

Assuming you have set the environment variables from the
[Configuration](#configuration) step and selected [test suite](#select-test-suite),
the following command will perform the tests against the deployed GitLab instance:

```shell
gitlab-qa Test::Instance::Any EE:$GITLAB_VERSION $GITLAB_URL -- $QA_OPTIONS
```

{{< alert type="note" >}}

The above command runs with _nightly_ because the containers used as a
part of this chart are currently based on nightly builds of the `master` branches
of `gitlab-(ee|ce)` repositories.

{{< /alert >}}
