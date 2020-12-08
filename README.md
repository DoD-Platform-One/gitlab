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

