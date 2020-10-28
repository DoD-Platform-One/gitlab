# GitLab

## Table of Contents

- Application Deployment
- Integrations
    - ECK
    - Keycloak


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

The Variables required to deploy will need to be added to a Secrets folder unique to your environment.  The Secrets folder and sops are described in the documentation wiki read me.  The following yaml files will define the variables.  These variables should be encrypted following the sops processes:

### registry.s3.yaml
s3:  
    bucket:  
    accesskey:  
    secretkey:  
    region:  
   x v4auth:  
sops:  
    kms:  
    arn: arn:aws-us-gov:kms:  
    created_at:  
    enc:  
    gcp_kms: []  
    azure_kv: []  
    lastmodified:  
    mac:  
pgp: []  
    unencrypted_suffix:  
    version:  

### rails.s3.yaml

provider:  
region:  
aws_access_key_id:  
G4=,tag:  
aws_secret_access_key:  
sops:  
    kms:  
    arn: arn:aws-us-gov:kms:  
    created_at:  
    enc:  
aws_profile: ""  
    gcp_kms: []  
    azure_kv: []  
    lastmodified:  
    mac:  
    pgp: []  
    unencrypted_suffix:  
    version:  

## db-creds.env

PGDATABASE=  
PGHOST=  
PGPASSWORD=  
PGUSER=  
sops_kms__list_0__map_enc=  
sops_mac=  
tag:  
sops_kms__list_0__map_arn=arn:  
sops_kms__list_0__map_aws_profile=  
sops_lastmodified=  
sops_unencrypted_suffix=_  
sops_version=  
sops_kms__list_0__map_created_at=  

## db-creds-generator.yaml

## s3-creds-generator.yaml


## elasticsearch notes

create an index pattern for fluentd if not already created for you
```
logstash-*
```
Build filter for gitlab namespace
```
{
  "query": {
    "match_phrase": {
      "kubernetes.namespace_name": "gitlab"
    }
  }
}
```
There are more than 15 pods in a Gitlab delployment.
```
[p1dev@p1dev-vm gitlab]$ kubectl get pods -n gitlab
NAME                                           READY   STATUS      RESTARTS   AGE
gitlab-gitaly-0                                1/1     Running     0          4h57m
gitlab-gitlab-exporter-668767985c-gqlf5        1/1     Running     0          4h57m
gitlab-gitlab-shell-697df76cc6-c72s4           1/1     Running     0          4h56m
gitlab-gitlab-shell-697df76cc6-hfv8v           1/1     Running     0          4h57m
gitlab-gitlab-upgrade-check-fc7k9              0/1     Completed   0          4h57m
gitlab-migrations.1-2rphn                      0/1     Completed   0          4h57m
gitlab-minio-86d86968bb-7mlj4                  1/1     Running     0          4h57m
gitlab-minio-create-buckets.1-g5zl8            0/1     Completed   0          4h57m
gitlab-prometheus-server-855c7b6999-sk4r8      2/2     Running     0          4h57m
gitlab-redis-master-0                          2/2     Running     0          4h57m
gitlab-registry-74566cb6f-k5rrx                1/1     Running     0          4h57m
gitlab-registry-74566cb6f-w9vbc                1/1     Running     0          4h57m
gitlab-shared-secrets.1-s6g-selfsign-bmtw5     0/1     Completed   0          143m
gitlab-shared-secrets.1-v1t-mkqqx              0/1     Completed   0          143m
gitlab-sidekiq-all-in-1-v1-86dbff87f9-wp2fr    1/1     Running     0          4h57m
gitlab-task-runner-584579cf87-mh4vb            1/1     Running     0          4h57m
gitlab-webservice-7ff8956d8b-8zcj2             2/2     Running     0          4h56m
gitlab-webservice-7ff8956d8b-9l8sj             2/2     Running     0          143m
global-shared-gitlab-runner-567cf8df54-8dzfw   1/1     Running     0          4h50m
```
Here is a document that lists the Gitlab components and what each one does  
https://docs.gitlab.com/ce/development/architecture.html#component-details

Here are some an examples of a filter for a secific containers:  
front-end webservice
```
{
  "query": {
    "match_phrase": {
      "kubernetes.container_name": "webservice"
    }
  }
}
```
gitlab-workhorse - a gateway for routing http requests to the proper component
```
{
  "query": {
    "match_phrase": {
      "kubernetes.container_name": "gitlab-workhorse"
    }
  }
}
```
cli git commands
```
{
  "query": {
    "match_phrase": {
      "kubernetes.container_name": "gitlab-shell"
    }
  }
}
```
In the KQL field you can text search within a source field such as log
```
log: "error"
```
```
log:
    F 2020-07-10T18:23:01.255Z 8 TID-go4bqp7cw ERROR: Error fetching job: Error connecting to Redis on gitlab-redis-master:6379 (Redis::TimeoutError)
kubernetes.namespace_name:
    gitlab
stream:
    stdout
docker.container_id:
    0ce16032685fdc72f9e2395872b525155f50893684f273ccef8f163a06164705
kubernetes.container_name:
    sidekiq
kubernetes.pod_name:
    gitlab-sidekiq-all-in-1-v1-86dbff87f9-wp2fr
kubernetes.container_image:
    registry.dsop.io/platform-one/apps/gitlab/gitlab-sidekiq-ee:v13.0.3
kubernetes.container_image_id:
    registry.dsop.io/platform-one/apps/gitlab/gitlab-sidekiq-ee@sha256:9e859328c5dfb685b5ccf176b15361091f0e58a935c770eadb80c909b67c4ac3
kubernetes.pod_id:
    53fa245b-c148-40f1-acc0-41fc687a6f2c
kubernetes.host:
    ip-10-39-105-148.us-gov-west-1.compute.internal
kubernetes.labels.app:
    sidekiq
kubernetes.labels.pod-template-hash:
    86dbff87f9
kubernetes.labels.queue-pod-name:
    all-in-1
kubernetes.labels.release:
    gitlab
```

