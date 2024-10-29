# Gitlab 17.x upgrade

Gitlab is migrating to a new [runner registration workflow](https://docs.gitlab.com/ee/ci/runners/new_creation_workflow.html) utilizing runner authentication tokens.  Currently, these can be generated via the Admin Area UI following [these steps](https://docs.gitlab.com/ee/ci/runners/runners_scope.html#create-an-instance-runner-with-a-runner-authentication-token), or [programatically](https://docs.gitlab.com/ee/tutorials/automate_runner_creation/index.html) via the REST API available on gitlab. Note that programatically requires an existing administrator level access token.  The secret used by gitlab-runner must be modified so that the new runner authentication token generated from above is available. See below examples, where `REDACTED` in the new workflow would be the newly generated authentication token.

In the legacy runner registration workflow, fields were specified with:

```
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-gitlab-runner-secret
type: Opaque
data:
  runner-registration-token: "REDACTED" # DEPRECATED, set to ""
  runner-token: ""
```

In the new runner registration workflow, you must use runner-token instead:

```
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-gitlab-runner-secret
type: Opaque
data:
  runner-registration-token: "" # need to leave as an empty string for compatibility reasons
  runner-token: "REDACTED"
```

### Re-enable legacy workflow

The alternative is to manually re-enable the legacy workflow, which should be available until the next major release of Gitlab 18.0.  This is accomplished following [these steps](https://docs.gitlab.com/ee/administration/settings/continuous_integration.html#enable-runner-registrations-tokens) in the Admin Area UI.
