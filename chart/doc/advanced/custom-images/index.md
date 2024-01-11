---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Use custom Docker images for the GitLab chart

In certain scenarios (i.e. offline environments), you may want to bring your own images rather than pulling them down from the Internet. This requires specifying your own Docker image registry/repository for each of the charts that make up the GitLab release.

## Default image format

Our default format for the image in most cases includes the full path to the image, excluding the tag:

```yaml
image:
  repository: repo.example.com/image
  tag: custom-tag
```

The end result will be `repo.example.com/image:custom-tag`.

## Current images and tags

When planning an upgrade, your current `values.yaml` and the target version of the
GitLab chart can be used to generate a [Helm template](https://helm.sh/docs/helm/helm_template/).
This template will contain the images and their respective tags that will be
needed by the specified version of the chart.

```shell
# Gather the latest values
helm get values gitlab > gitlab.yaml

# Use the gitlab.yaml to find the images and tags
helm template versionfinder gitlab/gitlab -f gitlab.yaml --version 7.3.0 | grep 'image:' | tr -d '[[:blank:]]' | sort --unique
```

This command can also be used to verify any custom configurations.

## Example values file

There is an [example values file](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/custom-images/values.yaml) that demonstrates how to configure a custom Docker registry/repository and tag. You can copy relevant sections of this file for your own releases.

NOTE:
Some of the charts (especially third party charts) sometimes have slightly different conventions for specifying the image registry/repository and tag. You can find documentation for third party charts on the [Artifact Hub](https://artifacthub.io/).
