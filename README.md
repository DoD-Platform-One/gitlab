# Gitlab

```

# Modify gitlab URL

# Remove webhooks
```

1. helm template gitlab gitlab/gitlab -f values.yaml --namespace gitlab --set global.hosts.gitlab.name=CHANGEME
update gitlab runner URL to use internal unicorn service http://gitlab-unicorn.gitlab.svc.cluster.local:8181
All helm hooks were removed from gitlab-template.yaml


1. Generate helm template from values:

```
helm template gitlab gitlab/gitlab -f generated/values.yaml --namespace gitlab > generated/generated.yaml
```

2. Modify gitlab runner to use internal hostname

```
CI_SERVER_URL: http://gitlab-unicorn.gitlab.svc.cluster.local:8181
```

3. Remove all helm hooks
