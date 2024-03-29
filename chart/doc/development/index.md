---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Contribute to Helm chart development

Our contribution policies can be found in [CONTRIBUTING.md](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/CONTRIBUTING.md)

Contributing documentation changes to the charts requires only a text editor. Documentation is stored in the [`doc/`](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/) directory.

## Architecture

Before starting development, it is helpful to review the goals, architecture, and design decisions for the charts.

See [Architecture of GitLab Helm charts](../architecture/index.md) for this information.

## Environment setup

See [setting up your development environment](environment_setup.md) to prepare your workstation for charts development.

## Style guide

See the [chart development style guide](style_guide.md) for guidelines and best practices for chart development.

## Writing and running tests

We run several different types of tests to validate the charts work as intended.

### Developing RSpec tests

Unit tests are written in RSpec and stored in the `spec/` directory of the chart repository.

Read the notes on [creating RSpec tests](rspec.md) to validate the
functionality of the chart.

### Developing bats tests

Unit tests for functions in shell scripts are written in [bats](https://bats-core.readthedocs.io/en/stable/) and stored next to the script file they are testing in the `scripts/` directory of the chart repository.

Read the notes on [creating bats tests](bats.md) to validate functions in the scripts used in this project.

### Running GitLab QA

[GitLab QA](https://gitlab.com/gitlab-org/gitlab-qa) can be used to run integrations and functional tests against a deployed cloud-native GitLab installation.

[Read more in the GitLab QA chart docs](gitlab-qa/index.md).

### ChaosKube

ChaosKube can be used to test the fault tolerance of highly available cloud-native GitLab installations.

[Read more in the ChaosKube chart docs](chaoskube/index.md).

### ClickHouse

[Instructions](clickhouse.md) for configuring an external ClickHouse server with GitLab.

## Versioning and Release

Details on the version scheme, branching and tags can be found in [release document](release.md).

## Changelog Entries

All `CHANGELOG.md` entries should be created via the [changelog entries](changelog.md) workflow.

## Pipelines

GitLab CI pipelines run on pipelines for:

- Merge requests
- Default branch
- Stable branches
- Tags

The configuration for these CI pipelines is managed in:

- [`.gitlab-ci.yml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/.gitlab-ci.yml)
- Files under [`.gitlab/ci/`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/.gitlab/ci/)

### Review apps

We use [Review apps](https://docs.gitlab.com/ee/ci/review_apps/) in CI to
deploy running instances of the Helm Charts and test against them.

We deploy these Review apps to our EKS and GKE clusters, confirm that the Helm
release is created successfully, and then run [GitLab QA](gitlab-qa/index.md)
and other [RSpec tests](rspec.md).

For merge requests specifically, we make use of
[`vcluster`](https://www.vcluster.com) to create ephemeral clusters. This
allows us to test against newer versions of Kubernetes more quickly due to the
ease of configuration and simplified environments that do not include External
DNS or Cert Manager dependencies. In this case, we simply deploy the Helm
Charts, confirm the release was created successfully, and validate that
Webservice is in the `Ready` state. This approach takes advantage of
[Kubernetes readiness probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
to ensure that the application is in a healthy state. See
[issue 5013](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/5013) for
more information on our `vcluster` implementation plan.

### Managing Review apps

Review apps will stay active for two hours by default, at which time they will be stopped automatically
by associated CI jobs. The process works as follows:

1. `create_review_*` jobs create the Review App environment.
   - These jobs only `echo` environment information. This ensures that these jobs do not fail, meaning we
     can create environments consistently and avoid leaving them in a broken state where they cannot be
     automaticaly stopped by future CI Jobs.
1. `review_*` jobs install the Helm Chart to the environment.
1. `stop_review_*` jobs run after the duration defined in the variable named `REVIEW_APPS_AUTO_STOP_IN`.

If you notice that one or more of the `review_*` jobs have failed and need to debug the environment, you can:

1. Find the associated `create_review_*` job.
1. At the top of the job page, click the environment link titled something like `This job is deployed to <cluster>/<commit>`.
1. At the top right of the environment page, you will see buttons to:
   - Pin the environment: marked by a pin icon, this button will prevent the environment from being stopped automatically.
     If you click this, it will cancel the `stop_review_*` job. Be sure to run that job manually when you have finished debugging.
     This option is helpful if you need more time to debug a failed environment.
   - View deployment: this button will open the environment URL of the running instance of GitLab.
   - Stop: this buttton will run the associated `stop_review_*` job.

## When to fork upstream charts

### No changes, no fork

Let it be stated that any chart that does not require changes to function
for our use *should not* be forked into this repository.

### Guidelines for forking

#### Sensitive information

If a given chart expects that sensitive communication secrets will be presented
from within environment, such as passwords or cryptographic keys,
[we prefer to use `initContainers`](../architecture/decisions.md#preference-of-secrets-in-initcontainer-over-environment).

#### Extending functionality

There are some cases where it is needed to extend the functionality of a chart in
such a way that an upstream may not accept.

## Handling configuration deprecations

There are times in a development where changes in behavior require a functionally breaking change. We try to avoid such changes, but some items can not be handled without such a change.

To handle this, we have implemented the [deprecations template](deprecations.md). This template is designed to recognize properties that need to be replaced or relocated, and inform the user of the actions they need to take. This template will compile all messages into a list, and then cause the deployment to stop via a `fail` call. This provides a method to inform the user at the same time as preventing the deployment the chart in a broken or unexpected state.

See the documentation of the [deprecations template](deprecations.md) for further information on the design, functionality, and how to add new deprecations.

## Attempt to catch problematic configurations

Due to the complexity of these charts and their level of flexibility, there are some overlaps where it is possible to produce a configuration that would lead to an unpredictable, or entirely non-functional deployment. In an effort to prevent known problematic settings combinations, we have the following two patterns in place:

- We use [schema validations](https://helm.sh/docs/topics/charts/#schema-files) for all
  our sub-charts to ensure the user-specified values meet expectations. See
  [the documentation](validation.md) to learn more.
- We implement template logic designed to detect and warn the user that their
  configuration will not work. See the documentation of the
  [`checkConfig` template](checkconfig.md) for further information on the design and
  functionality, and how to add new configuration checks.

## Verifying registry

In development mode, verifying Registry with Docker clients can be difficult. This is partly due to issues with certificate of
the registry. You can either [add the certificate](https://distribution.github.io/distribution/about/insecure/#use-self-signed-certificates) or
[expose the registry over HTTP](https://distribution.github.io/distribution/about/insecure/#deploy-a-plain-http-registry) (see `global.hosts.registry.https`).
Note that adding the certificate is more secure than the insecure registry solution.

Please keep in mind that Registry uses the external domain name of MinIO service (see `global.hosts.minio.name`). You may
encounter an error when using internal domain names, e.g. with custom TLDs for development environment. The common symptom
is that you can log in to the Registry but you can't push or pull images. This is generally because the Registry container(s)
can not resolve the MinIO domain name and find the correct endpoint (you can see the errors in container logs).

## Troubleshooting a development environment

Developers may encounter unique issues while working on new chart features.
[Refer to the troubleshooting guide](troubleshooting.md) for
information if your **_development_** cluster seems to have strange issues.

NOTE:
The troubleshooting steps outlined in the link above are for development
clusters only. Do not use these procedures in a production environment or
data will be lost.

## Additional Helm information

Some information on how all the inner Helm workings behave:

- The Distribution Team has a [training presentation for Helm charts](https://docs.google.com/presentation/d/1CStgh5lbS-xOdKdi3P8N9twaw7ClkvyqFN3oZrM1SNw/present).
- Templating in Helm is done via Go [text/template](https://pkg.go.dev/text/template)
  and [sprig](https://pkg.go.dev/github.com/Masterminds/sprig?utm_source=godoc%27).
- Helm repository has some additional information on developing with Helm in its
  [tips and tricks section](https://helm.sh/docs/howto/charts_tips_and_tricks/).
- [Functions and Pipelines](https://helm.sh/docs/chart_template_guide/functions_and_pipelines/).
- [Subcharts and Globals](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/).
