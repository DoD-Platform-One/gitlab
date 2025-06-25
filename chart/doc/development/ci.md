---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: CI setup and use
---

## CI Variables

| Variable           | Default Value                        | Description |
|--------------------|--------------------------------------|-------------|
| `LIMIT_TO`         | `""`                                 | Limit pipeline execution to a specific logical block. Available blocks: `eks131`, `gke130`, `gke131`, `gke131a`, `vcluster`. Empty value implies absence of limits - i.e. all components shall be considered for execution. |
| `DOCKERHUB_PREFIX` | `docker.io`                          | Override the prefix of DockerHub images. Allows to pull DockerHub from the dependency proxy or another mirror. |
| `DOCKER_MIRROR`    | `https://mirror.gcr.io`              | Default Docker mirror in DinD jobs. |
| `DOCKER_OPTIONS`   | `--registry-mirror ${DOCKER_MIRROR}` | Flags passed to the Docker daemon. |

### LIMIT_TO

`LIMIT_TO` allows to isolate singular logical block of pipeline and *only* execute that block skipping all other blocks. This allows for faster iteration as developer may choose to test only a singular platform before code is ready for more thorough testing. It also allows for external pipeline invocations for very specific scenarios.

`LIMIT_TO` accepts only a single value.

Empty value implies that there are no limits and that pipeline shall be executed in full.

### Docker and DockerHub variables

By default, CI uses some images from DockerHub. The shared runners by use a
mirror to avoid hitting DockerHub rate limits. If your fork uses custom
runnners, that don't use caching or mirroring, you should enable the [dependency proxy](https://docs.gitlab.com/user/packages/dependency_proxy/)
by setting the `DOCKERHUB_PREFIX` to your proxy, for example
`DOCKERHUB_PREFIX: ${CI_DEPENDENCY_PROXY_GROUP_IMAGE_PREFIX}`.

The container build context by default uses the gcr DockerHub mirror. This
behavior can be changed by overriding the `DOCKER_OPTIONS` or `DOCKER_MIRROR`
variables.
