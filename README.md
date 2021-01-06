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