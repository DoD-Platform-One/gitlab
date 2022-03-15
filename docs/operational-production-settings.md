# Operational configuration and settings for production environments
This document provides suggested settings for operational/production environment. Of course every environment is unique. These suggestions are a good starting point. Also consult the upstream Gitlab documentation and the other documents in the [./docs](./docs) directory.

## Use external database and object storage 
For production deployments you must externalize the postgres and MinIO services. If you are deploying with BigBang the most common value overrides will passthrough to the Gitlab Package chart.  
You should disable the internal postgres.
```
postgresql:
  install: false
```
Enable an external database. Preferably a cloud database service. Customize the values for your external database credentials. If you are using BigBang the values will pass through to this Gitlab Package chart.
```
global:
  ## doc/charts/globals.md#configure-postgresql-settings
  psql:
    password: {}
      # secret:
      # key:
    # host: postgresql.hostedsomewhere.else
    # port: 123
    # username: gitlab
    # database: gitlabhq_production
    # pool: 1
    # preparedStatements: false
```
Disable the internal MinIO instance
```
global:
  minio:
    enabled: false
```
Customize the values for external object storage. If you are using BigBang the values will pass through to this Gitlab Package chart.
```
global:
  appConfig:
    object_store:
    lfs:
    artifacts:
    uploads:
    packages: 
    externalDiffs:
    terraformState:
    dependencyProxy:
    pseudonymizer:
    backups:
```

## Flux settings
When deploying this Gitlab Package chart with BigBang the deployment is controlled by the FluxCD GitOps tool. Large Gitlab installations should increase the Flux timeout in the BigBang value (addons.gitlab.flux.timeout) to around 30m to 45m. And the BigBang Flux retries value (addons.gitlab.flux.upgrade.retries) should be adjusted to around 8 to 10.

## Kubernetes resource request/limit settings
K8s resource requests/limits for webservice and gitaly workloads should be increased from the defaults. Gitlab engineers state predicting Gitaly's resource consumption is very difficult, and will require testing to find the applicable limits/requests for each individual installation. See this [Gitlab Epic](https://gitlab.com/groups/gitlab-org/-/epics/6127) for more information. See the [docs/k8s-resources.md](./k8s-resources.md) for a list of all possible configuration values. 

Recommended starting point:
```
gitlab:
  webservice:
    resources:
      limits:
        cpu: 2
        memory: 4G
      requests:
        cpu: 2
        memory: 4G
  gitaly:
    resources:
      limits:
        cpu: 2
        memory: 4G
      requests:
        cpu: 2
        memory: 4G
```

## Backup and rename gitlab-rails-secret
If the Kubernetes gitlab-rails-secret happens to get overwritten Gitlab will no longer be able to access the encrypted data in the database. You will get errors like this in the logs.
```
OpenSSL::Cipher::CipherError ()
```
Many things break when this happens and the recovery is ugly with serious user impacts.  

At a minimum an operational deployment of Gitlab should export and save the gitlab-rails-secret somewhere secure outside the cluster.
```
kubectl get secret/gitlab-rails-secret -n gitlab -o yaml > cya.yaml
```
Ideally, an operational deployment should create a secret with a different name as [documented here](https://docs.gitlab.com/charts/installation/secrets.html#gitlab-rails-secret). The helm chart values ```global.railsSecrets.secret``` can be overridden to point to the secret.
```
global:
  railsSecrets:
    secret:  my-gitlab-rails-secret
```
This secret should be backed up somewhere secure outside the cluster.
