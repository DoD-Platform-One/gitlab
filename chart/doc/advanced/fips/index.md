---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab with FIPS-compliant images

GitLab offers [FIPS-compliant](https://docs.gitlab.com/ee/development/fips_compliance.html)
versions of its images, allowing you to run GitLab on FIPS-enabled clusters.

We meet this need via our [FIPS-compatible images](../fips/index.md).

## Sample values

We provide an example for GitLab Chart values in
[`examples/fips/values.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/fips/values.yaml)
which can help you to build a FIPS-compatible GitLab deployment.

Note the comment under the `nginx-ingress.controller` key that provides the
relevant configuration to use a FIPS-compatible NGINX Ingress Controller image. This image is
maintained in our [NGINX Ingress Controller fork](https://gitlab.com/gitlab-org/cloud-native/charts/gitlab-ingress-nginx).
