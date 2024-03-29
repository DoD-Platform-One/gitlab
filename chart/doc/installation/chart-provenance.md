---
stage: Systems
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://handbook.gitlab.com/handbook/product/ux/technical-writing/#assignments
---

# GitLab Helm chart provenance

You can verify the integrity and origin of GitLab Helm charts by using
[Helm provenance](https://helm.sh/docs/topics/provenance/).

The GitLab Helm charts are signed with a GNUPG keypair. The public portion of
the keypair must be downloaded and possibly exported before it can be used to
verify the charts. The
[GNU Privacy Handbook](https://www.gnupg.org/gph/en/manual/x56.html) has
detailed instructions on how to manage GPG keys.

## Download and export the GitLab Helm chart signing key

The official GitLab Helm Chart public signing key must be used to verify the
provenance of the GitLab Helm charts. The key must first be downloaded and then
possibly exported into a local keyring.

### Download the public signing key

To download the official GitLab Helm chart signing key, run:

```shell
gpg --receive-keys --keyserver hkps://keys.openpgp.org '5E46F79EF5836E986A663B4AE30F9C687683D663'
```

For example:

```shell
$ gpg --receive-keys --keyserver hkps://keys.openpgp.org '5E46F79EF5836E986A663B4AE30F9C687683D663'
gpg: key E30F9C687683D663: public key "GitLab, Inc. Helm charts <distribution@gitlab.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

This command downloads the key and adds it to your default keyring. You should
put the GitLab Helm chart signing key into a separate keyring. You can use the
`--no-default-keyring --keyring <keyring>` `gpg` options to create a new keyring
that contains just the GitLab Chart signing key.

For example:

```shell
$ gpg --keyring $HOME/.gnupg/gitlab.pubring.kbx --keyserver hkps://keys.openpgp.org --no-default-keyring --receive-keys '5E46F79EF5836E986A663B4AE30F9C687683D663'
gpg: keybox '$HOME/.gnupg/gitlab.pubring.kbx' created
gpg: key E30F9C687683D663: public key "GitLab, Inc. Helm charts <distribution@gitlab.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

### Export the signing key

By default, GnuPG v2 stores keyrings in a format that is incompatible with Helm
chart provenance verification. You must first export the keyring into the legacy
format before it can be used to verify an Helm chart. To export the keyring into
the proper format, either:

- Export from the default keyring:

  ```shell
  gpg --export --output gitlab.pubring.gpg '5E46F79EF5836E986A663B4AE30F9C687683D663'
  ```

- Use the `--no-default-keyring --keyring <keyring>` options to export the key
  from a separate keyring:

  ```shell
  gpg --export --output $HOME/.gnupg/gitlab.pubring.gpg  --keyring $HOME/.gnupg/gitlab.pubring.kbx  --no-default-keyring '5E46F79EF5836E986A663B4AE30F9C687683D663'
  ```

## Verify a chart

A GitLab Helm chart can be verified either by:

- Downloading the chart and running `helm verify`.
- Using the `--verify` option during chart installation.

### Verify a downloaded chart

You can use the `helm verify` command to verify a downloaded chart. To download a
verifiable chart, use the `helm pull --prov` command. For example:

```shell
helm pull --prov gitlab/gitlab
```

Use the `--version` option to download a specify chart version. For example:

```shell
helm pull --prov gitlab/gitlab --version 7.9.0
```

You can then use the `helm verify` command to verify the downloaded chart.

For example:

```shell
helm verify --keyring $HOME/.gnupg/gitlab.pubring.gpg gitlab-7.9.0.tgz
Signed by: GitLab, Inc. Helm charts <distribution@gitlab.com>
Using Key With Fingerprint: 5E46F79EF5836E986A663B4AE30F9C687683D663
Chart Hash Verified: sha256:789ec56d929c7ec403fc05249639d0c48ff6ab831f90db7c6ac133534d0aba19
```

You can combine the pull and verify commands using the `--verify` option with the `helm pull command`.

For example:

```shell
helm pull --prov gitlab/gitlab --verify --keyring $HOME/.gnupg/gitlab.pubring.gpg
Signed by: GitLab, Inc. Helm charts <distribution@gitlab.com>
Using Key With Fingerprint: 5E46F79EF5836E986A663B4AE30F9C687683D663
Chart Hash Verified: sha256:789ec56d929c7ec403fc05249639d0c48ff6ab831f90db7c6ac133534d0aba19
```

### Verify a chart during installation

You can verify a chart during installation by using the `--verify` option to
either the `helm install` or `helm upgrade` command.

- For example, `helm install`:

  ```shell
  helm install --verify --keyring $HOME/.gnupg/gitlab.pubring.gpg gitlab gitlab/gitlab --set certmanager-issuer.email=<me@example.com> --set global.hosts.domain=<example.com>
  ```

- For example, `helm upgrade`:

  ```shell
  helm upgrade --install --verify --keyring $HOME/.gnupg/gitlab.pubring.gpg gitlab gitlab/gitlab --set certmanager-issuer.email=<me@example.com> --set global.hosts.domain=<example.com>
  ```
