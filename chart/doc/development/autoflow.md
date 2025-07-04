---
stage: GitLab Delivery
group: Self Managed
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
title: AutoFlow
---

The KAS chart can be configured with AutoFlow support.
Currently, the AutoFlow support is limited to what is strictly required
for the [GitLab internal-use experiment](https://gitlab.com/groups/gitlab-org/-/epics/16181).

This specifically means that only a subset of configuration
options are available and only Temporal Cloud via
mTLS worker authentication and with data encryption
is supported.

## Configuration

AutoFlow is configured with the `autoflow` value node in the KAS subchart.

A minimal working configuration has the following anatomy:

```yaml
autoflow:
  enabled: true
  temporal:
    namespace: <unique temporal cloud namespace name>
    workerMtls:
      secretName: <name of the k8s secret with the mTLS worker certs>
    workflowDataEncryption:
      codecServer:
        authorizedUserEmails: <list of authorized temporal cloud users>
```

The values within `<>` need to be provided by the user of the chart:

- `<unique temporal cloud namespace name>`: this is the unique name of the
  Temporal Cloud namespace.
  The namespace must be created before by the KAS / AutoFlow maintainers.
  Reach out to `#f_autoflow` to get help with that.
- `<name of the k8s secret with the mTLS worker certs>`: this is the name of an
  already existing Kubernetes secret the KAS deployment will have access to.
  The secret must be of type `tls` and contain the `tls.crt` and `tls.key`
  data values. It can be created with a command like this:
  `kubectl create secret tls kas-autoflow-temporal-worker-mtls --cert <path-to-worker-mtls.crt> --key <path-to-worker-mtls.key>`.
  The mTLS certificate and key can be generated by following [this guide](https://docs.temporal.io/cloud/certificates#option-2-you-dont-have-certificate-management-infrastructure).
  The generated CA certificate must be configured in the Temporal namespace settings
- `<list of authorized temporal cloud users>`: this is a list of email
  addresses to should have access to the AutoFlow [codec server](https://docs.temporal.io/production-deployment/data-encryption)
  and have already been granted access to the configured namespace.

### Manual secret creation (optional)

This section is an addition to the official [manual secret creation section in the installation guide](../installation/secrets.md#manual-secret-creation-optional).

#### GitLab KAS AutoFlow Temporal Workflow Data Encryption Secret (experimental)

You can leave it to the chart to auto-generate the secret, or you can create this secret manually (replace `<name>` with the name of the release):

```shell
openssl rand 32 > secret.bin
kubectl create secret generic <name>-kas-autoflow-temporal-workflow-data-encryption-secret --from-literal=kas_autoflow_temporal_workflow_data_encryption=secret.bin
shred --remove secret.bin
```

This secret is referenced by the `gitlab.kas.autoflow.temporal.workflowDataEncryption.secret` setting.

## Verification

The [Configuration](#configuration) section must be followed in order
to verify (smoke test) the AutoFlow functionality.
Follow this step-by-step guide:

1. After installing the chart make sure the KAS pods are running without
   logging any errors.
1. Create a new project in the GitLab instance
1. Create a AutoFlow script at `.gitlab/autoflow/main.star` with the following
   contents: (you don't really need to understand it at this point)

   ```python
   # -*- mode: python -*-

   def handle_event(w, ev):
     print("Handling event: {}".format(ev["type"]))

   on_event(
     type="com.gitlab.events.issue_updated",
     handler=handle_event,
   )
   ```

1. Enable feature flags in Rails for AutoFlow using the `gitlab-rails console` in the toolbox pod:

   ```ruby
   Feature.enable(:autoflow_enabled)
   Feature.enable(:autoflow_issue_events_enabled)
   ```

1. Update an existing issue in that project and verify the KAS logs
   that it contains logs about handling that event and running the
   workflow script.

1. You can also emit events manually via the rails console.

   ```ruby
   client = Gitlab::Kas::Client.new()
   # Replace the issue and project IDs to match your setup.
   client.send_autoflow_event(
     project: Project.find(1),
     type: "com.gitlab.events.issue_updated",
     id: "1",
     data: {"project": {"id": 1}, "issue": {"iid": 1}}
   )
   ```

If you are interested in running more complex workflows,
see this snippet: <https://gitlab.com/-/snippets/4800564>.
