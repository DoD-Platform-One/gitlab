# Gitlab Package chart

This is a modified upstream chart. Custom templates and values are added to support the BigBang Umbrella chart.

Temporarily the subchart dependencies were downloaded as tar archives in the chart/charts/ directory.  These will need to be replaced with BigBang packages
```
helm dependency update
```

This package can be deployed independently from the BigBang umbrella with this helm command
```
helm upgrade -i gitlab chart -n gitlab --create-namespace -f chart/values.yaml
```

And it can be deleted with this helm command
```
helm delete gitlab -n gitlab
```

## Initial admin login

The initial admin login is user ```root```.  The password can be obtained with the following command.
```
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode ; echo
```

##  Deployment

For production deployments you must externalize the postgres and MinIO services. See docs/README.md.  

WARNING FOR OPERATIONAL ENVIRONMENTS:  
If the gitlab-rails-secret happens to get overwritten, Gitlab will no longer be able to access the encrypted data in the database. You will get errors like this in the logs.
```
OpenSSL::Cipher::CipherError ()
```
Many things break when this happens and the recovery is ugly with serious user impacts.  

At a minimum an operational deployment of Gitlab should export and save the gitlab-rails-secret somewhere safe outside the cluster.
```
kubectl get secret/gitlab-rails-secret -n gitlab -o yaml > cya.yaml
```
Ideally, an operational deployment should create a secret with a different name as [documented here](https://docs.gitlab.com/charts/installation/secrets.html#gitlab-rails-secret). The helm chart values ```global.railsSecrets.secret``` can be overridden to point to the secret.
```
global:
  railsSecrets:
    secret:  my-gitlab-rails-secret
```
This secret should be backed up somewhere safe outside the cluster.

## Configuring Gitlab with custom certificate authorities

Create a k8s secret in the Gitlab namespace. The secret can have multiple keys but each key must be a single pem encoded certificate, not a bundle of multiple secrets. Each key in the secret must be unique. Reference the [Gitlab documentation](https://docs.gitlab.com/charts/charts/globals.html#custom-certificate-authorities).  
Then in your values overrides add the name of the secret
```
global:
  certificates:
    customCAs:
      - secret: my-custom-ca-secret-name
```
