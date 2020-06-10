# Gitlab for Kubernetes

[gitlab](https://docs.gitlab.com/) provides  is the main repository for the DSOP Pipeline.  From the Docs:

GitLab is a web-based DevOps lifecycle tool that provides a Git-repository manager providing wiki, issue-tracking and continuous integration/continuous deployment pipeline features, using an open-source license, developed by GitLab Inc.

## Usage

### Prerequisites

* Kubernetes cluster deployed
* Kubernetes config installed in `~/.kube/config`
* Elasticsearch and Kibana deployed to Kubernetes namespace

Install kubectl

```
brew install kubectl
```

Install kustomize

```
brew install kustomize
```

### Deployment

Clone repository

```
git clone https://repo1.dsop.io/platform-one/apps/gitlab.git

cd gitlab
```

Apply kustomized manifest

```
kubectl -k ./
```

### Container Environment Variables

These variables are patched in via kustomize and may require modifications depending on your environment. Refer to the helm chart:

apps/gitlab/base/gitlab-pkg/chart.yaml


## Contributing

TBD