---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# Deprecations and removals

## Deprecations

Deprecated features are features that are still supported, but are scheduled for removal in a later
milestone. The chart's [NOTES.txt](https://helm.sh/docs/chart_template_guide/notes_files/) checks
for enabled deprecated features and displays an informational message if found.

### Considerations in detection

You should be careful not to assume that a key, or parent key will exist. Judicious application of
`if`, `hasKey`, and `empty` are strongly recommended. It is just as likely for a single key to be present as
it is for the entire property map to be missing several branches before that key. Helm _will_ complain if you
attempt to access a property that does not exist within the map structure, generally in a vague manor. Save
time, be explicit.

### Message format

All messages should have the following format:

```plaintext

chart:
    message
```

- The `if` statement preceding the message _should not_ trim the newline after it (`}}` not `-}}`).
  This ensures proper formatting, and readability for the user.
- The message should declare the chart, relative to the global chart, that is affected. This helps
  the user understand where the property came from in the charts, and configuration properties.
  Example: `gitlab.webservice`, `minio`, `registry`.
- The message should inform the user of the property that has been altered / relocated / deprecated,
  and what action should be taken. Name the property relative to the affected chart. For example,
  `gitlab.webservice.minio.enabled` would be referenced as `minio.enabled` because the chart
  affected by the deprecation is `gitlab.webservice`.

Example message:

```plaintext

gitlab.webservice:
    Chart-local configuration of Minio features has been moved to global. Please remove `gitlab.webservice.minio.enabled` from your properties, and set `global.minio.enabled` instead.
```

## Removals

After a deprecated feature is removed, the deprecation message is moved to a removal template. If a
removed feature is enabled, the `helm upgrade` will be blocked.

### General concept

1. The last item in `templates/NOTES.txt` `include`s the `gitlab.removals` template from `templates/_removals.tpl`.
1. The `gitlab.removals` template `include`s further templates in the same file, collecting their outputs (strings)
   into a `list`.
1. Each individual template handles detection of now errant configuration, and outputs messages informing the user of
   how to address the change, or outputs nothing.
1. The `gitlab.removals` template checks if any messages were collected. If any messages were, it outputs them under
   a header of `REMOVALS:` using the `fail` function.
1. The `fail` function results in the termination of the deployment process, preventing the user from deploying with
   a broken configuration.

### Template naming

Templates defined within, and used with this pattern should follow the naming convention of `gitlab.removal.*`.
Replace `*` here with an informative name, such as `rails.appConfig` or `registry.storage` to denote what this
deprecation is related to.

### Activating new removals

After a template has been defined, and logic placed in it for the detection of affected properties, activate the new template by adding a line beneath `add templates here` in the `gitlab.removals` template,
according to the format presented.
