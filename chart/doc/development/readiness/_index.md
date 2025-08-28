---
stage: GitLab Delivery
group: Operate
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: Contribute to Helm chart development
---

## Adding new components and charts

When you need to add new components to the GitLab chart, always start by evaluating
existing community or vendor charts. This is the recommended approach rather than
building a new chart from scratch.

To add a new component the order of preference should be to:

1. Reuse an existing community or vendor chart.
1. Fork an existing community or vendor chart.
1. Add a new GitLab-owned chart and maintain it as dependency of GitLab chart.

### Community or vendor charts

Community or vendor charts should be the preferred approach to add new components
to GitLab chart.

When an existing chart can be used as is or with modifications that can be
upstreamed, the chart can be added as a dependency to GitLab chart.

When a chart requires GitLab-specific functionality that upstream maintainers
won't accept, or when it includes features that shouldn't be exposed to GitLab
users, you can fork it to a separate repository, apply your patches, and integrate
it into the GitLab chart - provided the license permits this approach.

### Adding a new chart

If you must create a new chart, follow these guidelines. While you can deviate
from these recommendations, please document your reasons and alternative approach.

#### Project setup

- [ ] Create a new project in the [`gitlab-org/cloud-native/charts`](https://gitlab.com/gitlab-org/cloud-native/charts)
      group.
- [ ] Create the chart in its own separate repository following the default Helm
      project layout (initialised with `helm create`).
- [ ] Treat the chart as a dependency of GitLab chart.

#### Kubernetes compatibility

Only use Kubernetes APIs and features compatible with the [Kubernetes versions](../../installation/cloud/_index.md#supported-kubernetes-releases)
currently supported by GitLab chart.

#### Integrate with GitLab chart

To integrate the new chart with GitLab chart make use of templates and (global) values:

1. Template overrides: Templates can be defined by the subchart and overridden by
   the parent chart. This allows to separate logic if the chart is used in standalone
   mode or if it's used as part of the GitLab (parent) chart.

   Example: The GitLab chart [overrides templates defined by the OpenBao chart to inject it's database configuration](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/302d58ed9de62ce61133662def9c8984974122f0/templates/_openbao.tpl#L65).

1. [(Global) values](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/):
   Use and override (global) values to share information between two charts and define
   proper defaults in both the subcharts values file and the GitLab charts values.

   Example: The GitLab chart allows to specify a [global API version for HPAs](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/f811c66630a1c7ae28041157b048540ee8f23273/values.yaml#L79)
   which can be consumed by all subcharts and dependency charts.

1. Template values: Values can contain templates and can be rendered by using `tpl` in
   the subchart. This has similar use cases like template overrides but allows additional
   flexibility if the same chart is imported twice by allowing to customize the
   template/value for each instance, while a regular template override impacts all chart
   instances.

   Example: The GitLab NGINX fork [templates the external LoadBalancer IP from a value](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/f811c66630a1c7ae28041157b048540ee8f23273/charts/nginx-ingress/templates/_helpers.tpl#L297)
   to allow different behavior in the default and the Geo NGINX instance.

#### Best practices

- [ ] Follow the [style guide](../style_guide.md) to ensure a consistent naming and value structure.
- [ ] Use [Cloud Native GitLab images](https://gitlab.com/gitlab-org/build/CNG) for all containers.
- [ ] Handle sensitive data, such as passwords or cryptographic keys [using `initContainers`](../../architecture/decisions.md#preference-of-secrets-in-initcontainer-over-environment).
- [ ] Define a security context for all Pods and containers.
- [ ] Use the [unittest plugin](https://github.com/helm-unittest/helm-unittest) to test your manifests.
- [ ] Use [standardized CI tasks](https://gitlab.com/gitlab-com/gl-infra/mstaff/-/issues/460) to run
      common Helm jobs as part of your CI.
- [ ] Use a [lightweight Kubernetes integration in CI](https://gitlab.com/gitlab-org/cluster-integration/test-utils/k3s-gitlab-ci)
      to perform end to end testing in a live cluster.
- [ ] Avoid using [Helm hooks](https://helm.sh/docs/topics/charts_hooks/) if possible, as they are not
      available for `helm template` based workflows.
- [ ] Ingresses should consume GitLab chart's:

  - [host configuration](../../charts/globals.md#configure-host-settings),
  - [certmanager configuration](../../charts/globals.md#globalingressconfigurecertmanager), and
  - [global Ingress configuration](../../charts/globals.md#configure-ingress-settings)

  to ensure a consistent TLS and domain configuration.

- [ ] Workloads should optionally support [internal TLS](../../advanced/internal-tls/_index.md).

#### Chart delivery

- [ ] Use [semver](https://semver.org/) versioning.
- [ ] Publish the new chart to [`charts.gitlab.io`](https://gitlab.com/charts/charts.gitlab.io).
- [ ] The chart version bundled with GitLab chart should be managed by [renovate](https://gitlab.com/gitlab-org/frontend/renovate-gitlab-bot).

### Examples

A list of forked charts is available maintained in the [architecture decisions](../../architecture/decisions.md#forked-charts).

Charts that are being maintained as a separate repository are [GitLab Zoekt](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-zoekt)
and [OpenBao](https://gitlab.com/gitlab-org/cloud-native/charts/openbao).
