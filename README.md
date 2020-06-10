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
    v4auth: 
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


