# Files that require bigbang integration testing

### See [bb MR testing](../docs/test-package-against-bb.md) for details regarding testing changes against bigbang umbrella chart

There are certain integrations within the bigbang ecosystem and this package that require additional testing outside of the specific package tests ran during CI.  This is a requirement when files within those integrations are changed, as to avoid causing breaks up through the bigbang umbrella.  Currently, these include changes to the istio implementation within gitlab (see: [istio templates](../chart/templates/bigbang/istio/), [network policy templates](../chart/templates/bigbang/networkpolicies/), [service entry templates](../chart/templates/bigbang/serviceentries/)).

Be aware that any changes to files listed in the [Modifications made to upstream chart](#modifications-made-to-upstream-chart) section will also require a codeowner to validate the changes using above method, to ensure that they do not affect the package or its integrations adversely.

Be sure to also test against monitoring locally as it is integrated by default with these high-impact service control packages, and needs to be validated using the necessary chart values beneath `istio.hardened` block with `monitoring.enabled` set to true as part of your [dev-overrides.yaml](../docs/dev-overrides.yaml).

# Notice about updating postgres via renovate

Currently, we do not update postgresql via renovate bot unless the [upstream gitlab documentation](https://docs.gitlab.com/ee/install/requirements.html#postgresql-requirements) updates beyond our current supported version of postgres. Due to local in-place image upgrades not working because of limitations around the data directory being initialized by a previous major postgresql version, this requires a manual `pg_dump` from current & `pg_restore` to new updated postgres pod locally (RDS and other non docker DBs will do this automatically). We try to keep all local in-cluster/CI DBs on the same version and upgrade once all are recommended and tested to be on the next major version.

# How to upgrade the Gitlab Package chart

BigBang makes modifications to the upstream helm chart. The full list of changes is at the end of  this document.

1. Read release notes from upstream [Gitlab Releases](https://about.gitlab.com/releases/categories/releases/). Be aware of changes that are included in the upgrade, you can find those by [comparing the current and new revision](https://gitlab.com/gitlab-org/charts/gitlab/-/compare?from=master&to=master). Take note of any manual upgrade steps that customers might need to perform, if any.
1. Do diff of [upstream chart](https://gitlab.com/gitlab-org/charts/gitlab) between old and new release tags to become aware of any significant chart changes. A graphical diff tool such as [Meld](https://meldmerge.org/) is useful. You can see where the current chart version and available versions are at under the `sources` section in Chart.yaml.`
1. Read the /CHANGELOG.md from the release tag from upstream [upstream chart](https://gitlab.com/gitlab-org/charts/gitlab). Also, be aware of changes that could affect the Gitlab chart. Take note of any special upgrade instructions, if any.
1. If Renovate has not created a development branch and merge request then manually create one and tied to the Repo1 issue created for the Gitlab package upgrade.  The association between the branch and the issue can be made by prefixing the branch name with the issue number, e.g. `56-update-gitlab-package`. DO NOT create a branch if working `renovate/ironbank`. Continue edits on `renovate/ironbank`.
1. Reference the "Modifications made to upstream" section in ```/chart/values.yaml```. Exercise caution to preserve essential BigBang Package customizations. The `values.yaml` file includes a mix of updates—some should be overwritten with upstream changes, while others must be retained. Pay close attention during this process, as ```/chart/values.yaml```is the most complex file to update due to its extensive BigBang-specific modifications.
1. Since gitlab is now a subchart In `chart/Chart.yaml` update dependencies section for Gitlab and gluon to the latest version and run `helm dependency update chart` from the top level of the repo to package it up.
1. Run a helm dependency command to update the `chart/charts/*.tgz` archives and create a new requirements.lock file. You will commit the tar archives along with the requirements.lock that was generated.

    ```bash
    helm dependency update ./chart
    ```

1. In ```/chart/values.yaml``` update all the gitlab image tags to the new version. There are 16 gitlab related image tags, 2 minio related image tags, 1 ubi, 2 redis related image tags and 1 postgresql. Renovate might have already done this for you.
1. Update `/CHANGELOG.md` with an entry for "upgrade Gitlab to app version X.X.X chart version X.X.X-bb.X". Or, whatever description is appropriate.
1. Update the `/README.md` following the [gluon library script](https://repo1.dso.mil/platform-one/big-bang/apps/library-charts/gluon/-/blob/master/docs/bb-package-readme.md).
1. Update `/chart/Chart.yaml` to the appropriate versions. The annotation version should match the `appVersion`.

    ```yaml
    version: X.X.X-bb.X
    appVersion: X.X.X
    annotations:
      dev.bigbang.mil/applicationVersions: |
        - Gitlab: X.X.X
    dependencies:
    - name: gitlab
      version: 'X.X.X'
      repository: 'https://charts.gitlab.io'
      alias: upstream
    - name: gluon
      version: 'X.X.X'
      repository: 'oci://registry1.dso.mil/bigbang'
    ```

1. Update `annotations.helm.sh/images` section in `/chart/Chart.yaml` to fix references to updated packages (if needed).
1. Use a development environment to deploy and test Gitlab. See more detailed testing instructions below. Also test with gitlab-runner to make sure it still works with the new Gitlab version. Also test an upgrade by deploying the old version first and then deploying the new version.
1. When the Package pipeline runs expect the cypress tests to fail due to UI changes. Note that most of the cypress test files are synced to the gitlab-runner Package to avoid having two different versions of the same tests. There is one place in particular that frequently fails because the button id number `button[id="__BVID__XX__BV_toggle_"]` changes in `/chart/tests/cypress/03-gitlab-login.spec.js`. It is usually necessary to run the cypress tests locally in order to troubleshoot a failing test. The following steps are about how to set up local cypress testing. There is not good documentation anywhere else so it is included here.
    1. [Install a current version of cypress](https://docs.cypress.io/guides/getting-started/installing-cypress#npm-install) on your workstation.
    1. Make a sibling directory named `cypress` next to where you have gitlab repo cloned.

        ```bash
        mkdir cypress
        ls -l
        drwxrwxr-x cypress
        drwxrwxr-x gitlab
        ```

        Inside the cypress directory create a symbolic link named `integration` that points to the cypress tests inside the gitlab repo.

        ```bash
        cd cypress
        ln -s ../gitlab/chart/tests/cypress integration
        ls -l
        lrwxrwxrwx integration -> ../gitlab/chart/tests/cypress/
        cd ..
        ```

    1. Export the environment variables that are needed by the cypress test. Reference the `bbtests:` at the end of `/chart/values.yaml`.

        ```bash
        export cypress_url=https://gitlab.dev.bigbang.mil
        export cypress_gitlab_first_name=test
        export cypress_gitlab_last_name=user
        export cypress_gitlab_username=testuser
        export cypress_gitlab_email=testuser@example.com
        export cypress_gitlab_project=my-awesome-project

        # actual user password doesn't matter much but gitlab rejects it if it's too simple
        export cypress_gitlab_password=aa32b3ba7d5bbf537d745fd62469b15b

        # fetch gitlab admin password via CLI:
        #   kubectl -n gitlab get secrets gitlab-gitlab-initial-root-password -ojson | jq .data.password -r | base64 -d | pbcopy 
        export cypress_adminpassword=put-the-gitlab-root-password-here
        ```

    1. Run cypress from the parent directory of the gitlab and cypress directories.

        ```bash
        cypress
        ```

    1. When Cypress launches select the same directory where you ran cypress and you should see the gitlab cypress tests listed. Run them manually, in order, one at a time.
    1. Investigate and fix errors in the cypress tests. You can run a separate browser with developer tools to find out names of elements on each page.
1. Update the `/README.md` and `/CHANGELOG.md` again if you have made any additional changes during the upgrade/testing process.

# Testing new Gitlab version

1. Create a k8s dev environment. One option is to use the Big Bang [k3d-dev.sh](https://repo1.dso.mil/platform-one/big-bang/bigbang/-/tree/master/docs/developer/scripts) with no arguments which will give you the default configuration. The following steps assume you are using the script.
1. Follow the instructions at the end of the script to connect to the k8s cluster and install flux.
   1. Deploy gitlab with the dev values overrides from [docs/dev-overrides.yaml](../docs/dev-overrides.yaml). Core apps are disabled for quick deployment.
   1. Example helm upgrade command (run from within your local checkout of the `bigbang` repository):

    ```shell
    helm upgrade -n bigbang --create-namespace --install \
     bigbang ./chart \
     -f https://repo1.dso.mil/big-bang/bigbang/-/raw/master/tests/test-values.yaml \
     -f https://repo1.dso.mil/big-bang/product/packages/gitlab/-/raw/main/docs/dev-overrides.yaml \
     --set addons.gitlab.git.branch=YOUR-WORKING-BRANCH-NAME-HERE
   ```

1. Access Gitlab UI from a browser and login with SSO (to learn about deploying GitLab with a dev version of Keycloak, see [keycloak-dev.md](../docs/keycloak-dev.md)).
1. Test changing your profile image.
1. In your profile create an access token with all privileges. Save the token for later use.
1. Create a group called `test`.
1. Create a project called `test1` with a README.md within the `test` group.
1. From your workstation git clone with https the test1 project.

    ```bash
    git clone https://gitlab.dev.bigbang.mil/test/test1.git
    ```

1. Make a change to README.md and commit and push. Verify that the change shows in Gitlab UI.
1. Test pushing and pulling an image to the project container registry. Use the access token you created.

    ```bash
    docker login registry.dev.bigbang.mil
    docker pull busybox --platform linux/amd64
    docker tag busybox:latest registry.dev.bigbang.mil/test/test1:latest
    docker push registry.dev.bigbang.mil/test/test1:latest --platform linux/amd64
    docker image rm busybox:latest
    docker image rm registry.dev.bigbang.mil/test/test1:latest
    docker pull registry.dev.bigbang.mil/test/test1:latest --platform linux/amd64
    ```

1. Test a pipeline with gitlab-runner. Navigate to `https://gitlab.dev.bigbang.mil/test/test1/-/settings/ci_cd` and disable the Auto DevOps. Navigate to `https://gitlab.dev.bigbang.mil/test/test1/-/ci/editor?branch_name=main` and configure a pipeline. Verify that it completes successfully at `https://gitlab.dev.bigbang.mil/test/test1/-/pipelines`.

   ```yaml
    stages:
      - test
    dogfood:
      stage: test
      script:
        - echo "dogfood" >> file.txt
      artifacts:
        paths:
          - file.txt
    cache:
      paths:
        - file.txt
    ```

1. Perform a manual upgrade test. First deploy the current Gitlab version. Then deploy your development branch. Verify that the upgrade is successful.
1. Retest with monitoring and logging enabled. Verify that the logging and monitoring are working.

# Modifications made to upstream chart

This is a high-level list of modifications that Big Bang has made to the upstream helm chart. You can use this as as cross-check to make sure that no modifications were lost during the upgrade process.

## chart/charts/certmanager-issuer/templates/rbac-config.yaml

- Exposed automountServiceAccountToken for service account.

```
automountServiceAccountToken: {{ template "gitlab.serviceAccount.automountServiceAccountToken" . }}
```

## chart/charts/gitlab/charts/*/templates/serviceaccount.yaml

- Exposed automountServiceAccountToken for service accounts in the following gitlab components: geo-logcursor, gitaly, gitlab-exporter, gitlab-pages, gitlab-shell, kas, mailroom, migrations (_serviceaccountspec.yaml), praefect, sidekiq, spamcheck, toolbox, webservice

```
automountServiceAccountToken: {{ template "gitlab.serviceAccount.automountServiceAccountToken" . }}
```

## chart/charts/gitlab/templates/_serviceAccount.tpl

- Added template that respects the global and specific service account settings pertaining to automountServiceAccountToken

```
{{/*
Return the sub-chart serviceAccount automountServiceAccountToken setting
If that is not present it will use the global chart serviceAccount automountServiceAccountToken setting
*/}}
{{- define "gitlab.serviceAccount.automountServiceAccountToken" -}}
{{- if not (empty .Values.serviceAccount.automountServiceAccountToken) -}}
    {{ .Values.serviceAccount.automountServiceAccountToken }}
{{- else -}}
    {{ .Values.global.serviceAccount.automountServiceAccountToken }}
{{- end -}}
{{- end -}}
```

## chart/charts/nginx-ingress/values.yaml

- Added default for serviceAccount.automountServiceAccountToken in controller.admissionWebhooks to respect implicit default

```
controller:
  admissionWebhooks:
    serviceAccount:
      automountServiceAccountToken: true
```

## chart/templates/shared-secrets/job.yaml && chart/templates/shared-secrets/self-signed-cert-job.yml

- Set automountServiceAccountToken to true for shared-secrets jobs which need this token to be successful

```
automountServiceAccountToken: true
```

## chart/templates/shared-secrets/rbac-config.yaml

- Exposed automountServiceAccountToken for service account.

```
automountServiceAccountToken: {{ template "shared-secrets.automountServiceAccountToken" . }}
```

## chart/charts/registry/templates/_helpers.tpl

- Added template that respects the global and specific service account settings pertaining to automountServiceAccountToken

```
{{/*
Return the sub-chart serviceAccount automountServiceAccountToken setting
If that is not present it will use the global chart serviceAccount automountServiceAccountToken setting
*/}}
{{- define "registry.serviceAccount.automountServiceAccountToken" -}}
{{- if not (empty .Values.serviceAccount.automountServiceAccountToken) -}}
    {{ .Values.serviceAccount.automountServiceAccountToken }}
{{- else -}}
    {{ .Values.global.serviceAccount.automountServiceAccountToken }}
{{- end -}}
{{- end -}}
```

## chart/templates/_helpers.tpl

- Added template that respects the global and specific service account settings pertaining to automountServiceAccountToken

```
{{/*
Return the sub-chart serviceAccount automountServiceAccountToken setting
If that is not present it will use the global chart serviceAccount automountServiceAccountToken setting
*/}}
{{- define "shared-secrets.automountServiceAccountToken" -}}
{{- $sharedSecretValues := index .Values "shared-secrets" -}}
{{- if not (empty $sharedSecretValues.serviceAccount.automountServiceAccountToken) -}}
    {{ $sharedSecretValues.serviceAccount.automountServiceAccountToken }}
{{- else -}}
    {{ .Values.global.serviceAccount.automountServiceAccountToken }}
{{- end -}}
{{- end -}}
```

## `chart/templates/_certificates.tpl`

- Remove the include initContainerSecurityContext function.

```
{{- include "gitlab.init.containerSecurityContext" . | indent 2 }}
```

- Add the logic to use our own configurable securityContext for certificates initContainers.

```
  {{- with .Values.global.certificates.init.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
```

## chart/bigbang/*

- Add DoD approved CA certificates (recursive copy directory from previous release).
- If updating new certificates from new bundle:
  - Check `Department_of_State/` certificates for spaces in name.
  - Check `DigiCert_Federal_SSP/Trust_Chain_2/` certificates for spaces in name.
  - Convert `Entrust_Federal_SSP/Trust_Chain_2/0-Entrust_Managed_Services_Root_CA_rekey3.cer` to pem format.

    ```bash
    openssl x509 -inform der -in 0-Entrust_Managed_Services_Root_CA_rekey3.cer -out 0-Entrust_Managed_Services_Root_CA_rekey3.pem
    ```

  - Remove non-certificate metadata from `Carillon_Federal_Services/Trust_Chain_1/1-Carillon_Federal_Services_PIVI_CA2.cer`.
  - Remove non-certificate metadata from `DigiCert_NFI/Trust_Chain_2/2-Senate_PIV-I_CA_G5.cer`.

## chart/templates/bigbang/*

- Add istio virtual service.
- Add networkpolicies.
- Add istio peerauthentications.
- Add Secrets for DoD certificate authorities.
- Add istio authorization policies.

## chart/templates/tests/*

- Add templates for CI helm tests.

## chart/charts/gitlab/charts/toolbox/templates/configmap-custom-scripts.yaml

- Added custom configmap to mount ruby scripts to toolbox

  ```yaml
  {{- if .Values.enabled -}}
  {{- if .Values.customScripts -}}
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: {{ template "fullname" . }}-custom-scripts
    namespace: {{ $.Release.Namespace }}
    labels:
      {{- include "gitlab.standardLabels" . | nindent 4 }}
      {{- include "gitlab.commonLabels" . | nindent 4 }}
  data:
    {{- range $key, $value := .Values.customScripts }}
    {{ $key }}: |
      {{ $value }}
    {{- end }}
  {{- end }}
  {{- end }}
  ```

## chart/charts/gitlab/charts/toolbox/templates/deployment.yaml

- Added volumeMount and volume for custom ruby script configmap
  volumeMounts:
  
  ```yaml
  ...
              {{- if .Values.customScripts }}
            - name: {{ template "fullname" . }}-custom-scripts
              mountPath: /scripts/custom
              readOnly: true
            {{- end }}
  ...
  ```

  volumes:

  ```yaml
  ...
  {{- if .Values.customScripts }}
      - name: {{ template "fullname" . }}-custom-scripts
        projected:
          sources:
            - configMap:
                name: {{ template "fullname" . }}-custom-scripts
  {{- end }}  
  ```

## chart/charts/gitlab/charts/toolbox/templates/backup-job.yaml

- Added istio shutdown to command on lines 85 and 87.

  ```yaml
  {{- if and .Values.global.istio.enabled (eq .Values.global.istio.injection "enabled") }}{{ .Values.backups.cron.istioShutdown }}{{- end }}
  ```

## chart/charts/gitlab/charts/gitlab-pages/templates/service-custom-domains.yaml

- Ensure the conditional checking for empty `$externalAddresses` is removed from above the entirety of the template, and instead above the first use of it where it checks if the length of the value is `>1`. Add a closing `{{- end }}` after the existing `{{- else }}` and `{{- end }}` around the `loadBalancerIP:` & `externalIPs:` entries.

  ```yaml
  {{- if not (empty ($externalAddresses)) -}}
  {{-   if len $externalAddresses | eq 1 }}
  ...
  {{- end }}
  ```

- Remove the un-indented `{{- end }}` from the very bottom of the template (to complete the removal of the if statement being around the entire template).
- Remove the `{{- if not (empty $.Values.global.pages.externalHttp) }}` and closing `{{- end }}` from around the `80` port definition so it is always present.
- Remove the `{{- if not (empty $.Values.global.pages.externalHttps) }}` and closing `{{- end }}` from around the `443` port definition so it is always present.

## chart/charts/minio/templates/_helper_create_buckets.sh

- Hack the MinIO sub-chart to work with newer mc version in IronBank image, line 65.

  ```bash
  /usr/bin/mc policy set $POLICY myminio/$BUCKET
  ```

## chart/charts/*.tgz

- Run `helm dependency update ./chart` and commit the downloaded archives.
- Commit the tar archives that were downloaded and requirements.lock that was generated from the helm dependency update command.

## chart/tests/*

- Add helm test scripts for CI pipeline.

## chart/templates/_certificates.tpl

- Hack to support pki certificate location within the RedHat UBI image. Is different than Debian based images. Add to definition of `gitlab.certificates.volumeMount`. The volumeMount definition is at the end of the file.

  ```yaml
  - name: etc-ssl-certs
    mountPath: /etc/pki/tls/certs/
    readOnly: true
  - name: etc-ssl-certs
    mountPath: /etc/pki/tls/cert.pem
    subPath: ca-bundle.crt
    readOnly: true
  ```

## chart/.gitignore

- Comment the `charts/*.tgz`.
- Comment the `requirements.lock`.

## chart/.helmignore

- Change `scripts/` to `/scripts/` so that the helm test scripts are not ignored.

## chart/requirements.yaml

- Add latest gluon dependency to the end of the list.

  ```yaml
  - name: gluon
    version: "x.x.x"
    repository: "oci://registry.dso.mil/platform-one/big-bang/apps/library-charts/gluon"
  ```

## chart/values.yaml

- Disable all internal services other than postgres, minio, and redis.
- Add BigBang additional values at bottom of `values.yaml`.
- Add prometheus exporter:  gitlab.gitlab-exporter.
- Add default dev.bigbang.mil hostnames for global.hosts.
- Add IronBank hardened images.
- Add pullSecrets for each IronBank image.
- Add default dev.bigbang.mil hostnames at global.hosts.
- Add customCAs (the cert files and secrets need to be added in the next 2 steps for this to work).
  - Run this to get a list of secrets:

  ```bash
  for i in $(helm template -s templates/bigbang/secrets/DoD_CA_certs.yaml . | grep "name:" | cut -d ":" -f 2); do echo "- secret: $i"; done
  ``````

- Add `global.certificates.init.securityContext` and it's 3 entries
- Add `postgresqlInitdbArgs`, `securityContext`, `postgresqlDataDir` and `persistence` to get IB image working with postgres subchart.
- Add `upgradeCheck.annotations`: sidecar.istio.io/inject: "false".
- Add `shared-secrets.annotations`: sidecar.istio.io/inject: "false".
- Add `gitlab.migrations.annotations`: sidecar.istio.io/inject: "false".
- Add `minio.jobAnnotations`: sidecar.istio.io/inject: "false".
- Add `gitlab.toolbox.annotations`: `sidecar.istio.io/proxyMemory: 512Mi` and `sidecar.istio.io/proxyMemoryLimit: 512Mi`.
- Change default value for `global.ingress.configureCertmanager` to `false`
- Add `gitlab.toolbox.customScripts` with example `testing.rb` script for custom ruby scripts in toolbox.

# chart/Chart.yaml

- Change version key to Big Bang composite version.
- Add Big Bang `annotations.dev.bigbang.mil/applicationVersions` and `annotations.helm.sh/images` keys to support release automation.
- Add the required kubeversion
