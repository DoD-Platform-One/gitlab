require 'spec_helper'
require 'helm_template_helper'
require 'runtime_template_helper'
require 'tomlrb'
require 'yaml'
require 'hash_deep_merge'

describe 'Gitaly configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  def render_toml(raw_template, env = {})
    # provide the gitaly_token
    files = { '/etc/gitlab-secrets/gitaly/gitaly_token' => RuntimeTemplate::JUNK_TOKEN,
              '/etc/gitlab-secrets/gitaly-pod-cgroup' => RuntimeTemplate::JUNK_TOKEN }

    toml = RuntimeTemplate.gomplate(raw_template: raw_template, files: files, env: env)

    Tomlrb.parse(toml)
  end

  def render_erb(raw_template)
    yaml = RuntimeTemplate.erb(raw_template: raw_template, files: RuntimeTemplate.mock_files)
    YAML.safe_load(yaml)
  end

  context 'When disabled and provided external instances' do
    let(:values) do
      YAML.safe_load(%(
        global:
          gitaly:
            enabled: false
            external:
            - name: default
              hostname: git.example.com
      )).deep_merge(default_values)
    end

    it 'populates external instances to gitlab.yml' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0)
      # check that gitlab.yml.erb contains production.repositories.storages
      gitlab_yml = render_erb(t.dig('ConfigMap/test-webservice','data','gitlab.yml.erb'))
      storages = gitlab_yml['production']['repositories']['storages']
      expect(storages).to have_key('default')
      expect(storages['default']['gitaly_address']).to eq('tcp://git.example.com:8075')
    end

    context 'when external is configured with tlsEnabled' do
      let(:values) do
        YAML.safe_load(%(
          global:
            gitaly:
              enabled: false
              external:
              - name: default
                hostname: git.example.com
                tlsEnabled: true
        )).deep_merge(default_values)
      end

      it 'populates a tls uri' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that gitlab.yml.erb contains production.repositories.storages
        gitlab_yml = render_erb(t.dig('ConfigMap/test-webservice','data','gitlab.yml.erb'))
        storages = gitlab_yml['production']['repositories']['storages']
        expect(storages).to have_key('default')
        expect(storages['default']['gitaly_address']).to eq('tls://git.example.com:8076')
      end
    end

    context 'when tls is enabled' do
      let(:values) do
        YAML.safe_load(%(
          global:
            gitaly:
              enabled: false
              external:
              - name: default
                hostname: git.example.com
              tls:
                enabled: true
        )).deep_merge(default_values)
      end

      it 'populates a tls uri' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that gitlab.yml.erb contains production.repositories.storages
        gitlab_yml = render_erb(t.dig('ConfigMap/test-webservice','data','gitlab.yml.erb'))
        storages = gitlab_yml['production']['repositories']['storages']
        expect(storages).to have_key('default')
        expect(storages['default']['gitaly_address']).to eq('tls://git.example.com:8076')
      end
    end

    context 'when tls is enabled, and instance disables tls' do
      let(:values) do
        YAML.safe_load(%(
          global:
            gitaly:
              enabled: false
              external:
              - name: default
                hostname: git.example.com
                tlsEnabled: false
              tls:
                enabled: true
        )).deep_merge(default_values)
      end

      it 'populates a tcp uri' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that gitlab.yml.erb contains production.repositories.storages
        gitlab_yml = render_erb(t.dig('ConfigMap/test-webservice','data','gitlab.yml.erb'))
        storages = gitlab_yml['production']['repositories']['storages']
        expect(storages).to have_key('default')
        expect(storages['default']['gitaly_address']).to eq('tcp://git.example.com:8075')
      end
    end
  end

  context 'when rendering gitaly securityContexts' do
    context 'when the administrator changes or deletes values' do
      using RSpec::Parameterized::TableSyntax
      where(:fsGroup, :runAsUser, :fsGroupChangePolicy, :expectedContext) do
        nil | nil | "OnRootMismatch" | { 'fsGroup' => 1000, 'runAsUser' => 1000, 'fsGroupChangePolicy' => "OnRootMismatch" }
        nil | ""  | nil              | { 'fsGroup' => 1000 }
        nil | 24  | ""               | { 'fsGroup' => 1000, 'runAsUser' => 24 }
        42  | nil | "OnRootMismatch" | { 'fsGroup' => 42, 'runAsUser' => 1000, 'fsGroupChangePolicy' => "OnRootMismatch" }
        42  | ""  | nil              | { 'fsGroup' => 42 }
        42  | 24  | ""               | { 'fsGroup' => 42, 'runAsUser' => 24 }
        ""  | nil | "OnRootMismatch" | { 'runAsUser' => 1000 }
        ""  | ""  | nil              | nil
        ""  | 24  | ""               | { 'runAsUser' => 24 }
      end

      with_them do
        let(:values) do
          YAML.safe_load(%(
            gitlab:
              gitaly:
                securityContext:
                  #{"fsGroup: #{fsGroup}" unless fsGroup.nil?}
                  #{"fsGroupChangePolicy: #{fsGroupChangePolicy}" unless fsGroupChangePolicy.nil?}
                  #{"runAsUser: #{runAsUser}" unless runAsUser.nil?}
          )).deep_merge(default_values)
        end

        let(:gitaly_stateful_set) { 'StatefulSet/test-gitaly' }

        it 'should render securityContext correctly' do
          t = HelmTemplate.new(values)
          gitaly_set = t.resources_by_kind('StatefulSet').select { |key| key == gitaly_stateful_set }
          security_context = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['securityContext']

          # Helm 3.2+ renders the full security context. So we check given
          # the expected context from the table above and then check the
          # additional attributes that are not specified in the table above.
          full_context = { "runAsUser" => 1000, "fsGroup" => 1000 }
          expectedContext&.each_key do |expected_key|
            expect(security_context[expected_key]).to eq(expectedContext[expected_key])
            full_context.delete(expected_key)
          end

          full_context.each_key do |unexpected_key|
            expect(security_context[unexpected_key]).to eq(full_context[unexpected_key])
          end
        end
      end
    end
  end

  context 'With additional gitconfig' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            git:
              config:
              - {key: "pack.threads", value: "4"}
              - {key: "fetch.fsckObjects", value: "false"}
      )).deep_merge(default_values)
    end

    it 'populates [[git.config]] sections' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0)

      config = t.dig('ConfigMap/test-gitaly', 'data', 'config.toml.tpl')
      expect(config).to include(
        <<~CONFIG
        [[git.config]]
        key = "pack.threads"
        value = "4"

        [[git.config]]
        key = "fetch.fsckObjects"
        value = "false"
        CONFIG
      )
    end
  end

  context 'When customer provides additional labels' do
    let(:labeled_values) do
      YAML.safe_load(%(
        global:
          common:
            labels:
              global: global
              foo: global
          pod:
            labels:
              global_pod: true
          service:
            labels:
              global_service: true
        gitlab:
          gitaly:
            common:
              labels:
                global: gitaly
                gitaly: gitaly
            podLabels:
              pod: true
              global: pod
            serviceAccount:
              create: true
              enabled: true
            serviceLabels:
              service: true
              global: service
            persistence:
              labels:
                foo: global
      )).deep_merge(default_values)
    end

    context 'with only gitaly' do
      it 'Populates the additional labels in the expected manner' do
        t = HelmTemplate.new(labeled_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('ConfigMap/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(t.dig('StatefulSet/test-gitaly', 'metadata', 'labels')).to include('foo' => 'global')
        expect(t.dig('StatefulSet/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(t.dig('StatefulSet/test-gitaly', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('StatefulSet/test-gitaly', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(t.dig('StatefulSet/test-gitaly', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
        expect(t.dig('StatefulSet/test-gitaly', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(t.dig('StatefulSet/test-gitaly', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).not_to include('global' => 'gitaly')
        expect(t.dig('StatefulSet/test-gitaly', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).to include('foo' => 'global')
        expect(t.dig('PodDisruptionBudget/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(t.dig('Service/test-gitaly', 'metadata', 'labels')).to include('global' => 'service')
        expect(t.dig('Service/test-gitaly', 'metadata', 'labels')).to include('gitaly' => 'gitaly')
        expect(t.dig('Service/test-gitaly', 'metadata', 'labels')).to include('global_service' => 'true')
        expect(t.dig('Service/test-gitaly', 'metadata', 'labels')).to include('service' => 'true')
        expect(t.dig('Service/test-gitaly', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('ServiceAccount/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
      end

      it 'renders a TOML configuration file' do
        t = HelmTemplate.new(labeled_values)
        config = t.dig('ConfigMap/test-gitaly', 'data', 'config.toml.tpl')
        toml = render_toml(config, 'HOSTNAME' => 'default')

        expect(toml.keys).to match_array(%w[auth bin_dir git gitlab gitlab-shell hooks listen_addr logging prometheus_listen_addr storage])
        expect(toml['storage']).to eq([{ 'name' => 'default', 'path' => '/home/git/repositories' }])
        expect(toml['auth']['token'].length).to eq(32)
      end
    end

    context 'with praefect enabled' do
      let(:praefect_labeled_values) do
        YAML.safe_load(%(
          global:
            praefect:
              enabled: true
              virtualStorages:
              - name: default
                gitalyReplicas: 3
        )).deep_merge(default_values).deep_merge(labeled_values)
      end

      it 'Populates the additional labels in the expected manner' do
        t = HelmTemplate.new(praefect_labeled_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('ConfigMap/test-gitaly-praefect', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(t.dig('StatefulSet/test-gitaly-default', 'metadata', 'labels')).to include('foo' => 'global')
        expect(t.dig('StatefulSet/test-gitaly-default', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(t.dig('StatefulSet/test-gitaly-default', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('StatefulSet/test-gitaly-default', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(t.dig('StatefulSet/test-gitaly-default', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
        expect(t.dig('StatefulSet/test-gitaly-default', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(t.dig('StatefulSet/test-gitaly-default', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).to include('storage' => 'default')
        expect(t.dig('StatefulSet/test-gitaly-default', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).not_to include('global' => 'gitaly')
        expect(t.dig('PodDisruptionBudget/test-gitaly-default', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(t.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('gitaly' => 'gitaly')
        expect(t.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('global' => 'service')
        expect(t.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('global_service' => 'true')
        expect(t.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('service' => 'true')
        expect(t.dig('Service/test-gitaly-default', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('ServiceAccount/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
      end

      it 'renders a TOML configuration file' do
        t = HelmTemplate.new(praefect_labeled_values)
        config = t.dig('ConfigMap/test-gitaly-praefect', 'data', 'config.toml.tpl')
        toml = render_toml(config, 'HOSTNAME' => 'test-gitaly-default-0')

        expect(toml.keys).to match_array(%w[auth bin_dir git gitlab gitlab-shell hooks listen_addr logging prometheus_listen_addr storage])
        expect(toml['storage']).to eq([{ 'name' => 'test-gitaly-default-0', 'path' => '/home/git/repositories' }])
        expect(toml['auth']['token'].length).to eq(32)
      end
    end
  end

  context 'packObjectsCache' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            packObjectsCache:
              enabled: #{pack_objects_cache_enabled}
              dir: #{pack_objects_cache_dir}
              max_age: #{pack_objects_cache_max_age}
              min_occurrences: #{pack_objects_cache_min_occurrences}
      )).merge(default_values)
    end

    context 'when enabled' do
      let(:pack_objects_cache_enabled) { 'true' }
      let(:pack_objects_cache_dir) { '/pack-objects-cache' }
      let(:pack_objects_cache_max_age) { '10m' }
      let(:pack_objects_cache_min_occurrences) { '1' }

      let(:template) { HelmTemplate.new(values) }

      it 'populates a pack_objects_cache section in config.toml.tpl' do
        config_toml = template.dig('ConfigMap/test-gitaly','data','config.toml.tpl')

        pack_objects_cache_section = <<~CONFIG
          [pack_objects_cache]
          enabled = #{pack_objects_cache_enabled}
          dir = "#{pack_objects_cache_dir}"
          max_age = "#{pack_objects_cache_max_age}"
          min_occurrences = #{pack_objects_cache_min_occurrences}
        CONFIG

        expect(config_toml).to include(pack_objects_cache_section)
      end
    end

    context 'when not enabled' do
      let(:pack_objects_cache_enabled) { 'false' }
      let(:pack_objects_cache_dir) { '/pack-objects-cache' }
      let(:pack_objects_cache_max_age) { '10m' }
      let(:pack_objects_cache_min_occurrences) { '1' }

      let(:template) { HelmTemplate.new(values) }

      it 'does not populate a pack_objects_cache section in config.toml.tpl' do
        config_toml = template.dig('ConfigMap/test-gitaly','data','config.toml.tpl')

        expect(config_toml).not_to match(/^\[pack_objects_cache\]/)
      end
    end
  end

  context 'gpg signing' do
    let(:values) do
      HelmTemplate.with_defaults %(
        gitlab:
          gitaly:
            gpgSigning:
              enabled: #{gpg_signing_enabled}
              secret: #{gpg_secret_name}
              key: #{gpg_secret_key}
      )
    end

    context 'when enabled' do
      let(:gpg_signing_enabled) { true }
      let(:gpg_secret_name) { 'gpgSecret' }
      let(:gpg_secret_key) { 'gpgisfun' }

      let(:template) { HelmTemplate.new(values) }

      it 'populates a signing_key field in config.toml.tpl' do
        config_toml = template.dig('ConfigMap/test-gitaly','data','config.toml.tpl')

        expect(config_toml).to include "signing_key = '/etc/gitlab-secrets/gitaly/signing_key.gpg'"
      end
    end

    context 'when disabled' do
      let(:gpg_signing_enabled) { false }
      let(:gpg_secret_name) { 'dont use me' }
      let(:gpg_secret_key) { 'gpgisunfun' }

      let(:template) { HelmTemplate.new(values) }

      it 'does not populate a signing_key field in config.toml.tpl' do
        config_toml = template.dig('ConfigMap/test-gitaly','data','config.toml.tpl')

        expect(config_toml).not_to match(/^signing_key = /)
      end
    end
  end

  context 'with extraVolumes' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            extraVolumes: |-
             - name: #{volume_name}
      )).deep_merge(default_values)
    end

    let(:template) { HelmTemplate.new(values) }

    shared_examples 'a deprecated gitconfig volume' do
      it 'fails due to gitconfig deprecation' do
        expect(template.exit_code).not_to eq(0)
        expect(template.stderr).to include("Gitaly have stopped reading `gitconfig`")
      end
    end

    context 'with gitconfig volume' do
      let(:volume_name) { "gitconfig" }

      it_behaves_like 'a deprecated gitconfig volume'
    end

    context 'with git-config volume' do
      let(:volume_name) { "git-config" }

      it_behaves_like 'a deprecated gitconfig volume'
    end

    context 'with gitaly-gitconfig volume' do
      let(:volume_name) { "gitaly-gitconfig" }

      it_behaves_like 'a deprecated gitconfig volume'
    end

    context 'with gitaly-config volume' do
      let(:volume_name) { "gitaly-config" }

      it 'successfully renders the template' do
        expect(template.exit_code).to eq(0)
        expect(template.stderr).not_to include("Gitaly have stopped reading `gitconfig`")
      end
    end
  end

  context 'server side backups' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            backup:
              goCloudUrl: 'gs://gitaly-backups'
      )).deep_merge(default_values)
    end

    let(:template) { HelmTemplate.new(values) }
    let(:gitaly_config) { template.dig('ConfigMap/test-gitaly', 'data', 'config.toml.tpl') }

    it 'renders the template' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    it 'sets the object storage url' do
      expect(gitaly_config).to include(
        <<~CONFIG
        [backup]
        go_cloud_url = "gs://gitaly-backups"
        CONFIG
      )
    end
  end

  context 'gomemlimit' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            resources:
              limits:
                memory: #{resources_limits_memory}
            gomemlimit:
              enabled: #{gomemlimit_enabled}
      )).merge(default_values)
    end

    let(:gitaly_stateful_set) { 'StatefulSet/test-gitaly' }

    context 'when enabled' do
      let(:gomemlimit_enabled) { 'true' }
      let(:resources_limits_memory) { '100Mi' }

      it 'sets the env var GOMEMLIMIT' do
        t = HelmTemplate.new(values)
        gitaly_set = t.resources_by_kind('StatefulSet').select { |key| key == gitaly_stateful_set }
        gitaly_container_env = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]['env']
        expect(gitaly_container_env).to include(
          'name' => 'GOMEMLIMIT',
          'valueFrom' => { 'resourceFieldRef' => { 'containerName' => 'gitaly', 'resource' => 'limits.memory' } })
      end
    end

    context 'when not enabled' do
      let(:gomemlimit_enabled) { 'false' }
      let(:resources_limits_memory) { '' }

      it 'does not set the env var GOMEMLIMIT' do
        t = HelmTemplate.new(values)
        gitaly_set = t.resources_by_kind('StatefulSet').select { |key| key == gitaly_stateful_set }
        gitaly_container_env = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]['env']
        expect(gitaly_container_env.map { |env| env['name'] }).not_to include('GOMEMLIMIT')
      end
    end
  end

  context 'cgroups' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            cgroups:
              enabled: #{cgroups_enabled}
              initContainer:
                image:
                  repository: registry.gitlab.com/gitlab-org/build/cng/gitaly-init-cgroups
                  tag: master
                  pullPolicy: IfNotPresent
              mountpoint: '{% file.Read "/etc/gitlab-secrets/gitaly-pod-cgroup" | strings.TrimSpace %}'
              hierarchyRoot: gitaly
              memoryBytes: 64424509440
              cpuShares: 1024
              cpuQuotaUs: 400000
              repositories:
                count: 1000
                memoryBytes: 32212254720
                cpuShares: 512
                cpuQuotaUs: 200000
      )).deep_merge(default_values)
    end

    let(:gitaly_stateful_set) { 'StatefulSet/test-gitaly' }

    context 'when enabled' do
      let(:cgroups_enabled) { true }

      let(:template) { HelmTemplate.new(values) }
      let(:gitaly_config) { template.dig('ConfigMap/test-gitaly', 'data', 'config.toml.tpl') }

      it 'renders the template' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'sets the cgroups config' do
        expect(gitaly_config).to include(
          <<~CONFIG
          [cgroups]
          mountpoint = "{% file.Read "/etc/gitlab-secrets/gitaly-pod-cgroup" | strings.TrimSpace %}"
          hierarchy_root = "gitaly"
          memory_bytes = 64424509440
          cpu_shares = 1024
          cpu_quota_us = 400000
          [cgroups.repositories]
          count = 1000
          memory_bytes = 32212254720
          cpu_shares = 512
          cpu_quota_us = 200000
          CONFIG
        )
      end

      it 'sets the cgroups init container' do
        gitaly_set = template.resources_by_kind('StatefulSet').select { |key| key == gitaly_stateful_set }
        gitaly_init_container = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['initContainers'][0]
        gitaly_init_container_env = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['initContainers'][0]['env']
        expect(gitaly_init_container['name']).to eq('init-cgroups')
        expect(gitaly_init_container['image']).to eq('registry.gitlab.com/gitlab-org/build/cng/gitaly-init-cgroups:master')
        expect(gitaly_init_container['imagePullPolicy']).to eq('IfNotPresent')
        expect(gitaly_init_container['securityContext']).to include('runAsUser' => 0, 'runAsGroup' => 0)
        expect(gitaly_init_container_env.map { |env| env['name'] }).to match_array(['GITALY_POD_UID', 'CGROUP_PATH', 'OUTPUT_PATH'])
      end
    end

    context 'when disabled' do
      let(:cgroups_enabled) { false }

      let(:template) { HelmTemplate.new(values) }

      it 'does not populate a cgroups field in config.toml.tpl' do
        config_toml = template.dig('ConfigMap/test-gitaly','data','config.toml.tpl')

        expect(config_toml).not_to match(/^\[cgroups\]/)
        expect(config_toml).not_to match(/^\[cgroups.repositories\]/)
      end

      it 'does not add an initContainer to gitaly' do
        gitaly_set = template.resources_by_kind('StatefulSet').select { |key| key == gitaly_stateful_set }
        gitaly_init_containers = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['initContainers']
        expect(gitaly_init_containers.map { |c| c['name'] }).not_to include('init-cgroups')
      end
    end
  end

  context 'startupProbe' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            statefulset:
              startupProbe:
                enabled: #{startup_probe_enabled}
                initialDelaySeconds: 5
                periodSeconds: 1
                timeoutSeconds: 2
                successThreshold: 1
                failureThreshold: 30
      )).merge(default_values)
    end

    let(:gitaly_stateful_set) { 'StatefulSet/test-gitaly' }

    context 'when enabled' do
      let(:startup_probe_enabled) { 'true' }

      it 'sets the startup probe config' do
        t = HelmTemplate.new(values)
        gitaly_set = t.resources_by_kind('StatefulSet').select { |key| key == gitaly_stateful_set }
        gitaly_startup_probe = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]['startupProbe']
        gitaly_readiness_probe = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]['readinessProbe']
        gitaly_liveness_probe = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]['livenessProbe']

        expect(gitaly_startup_probe).to include(
          'initialDelaySeconds' => 5,
          'exec' => { "command" => ["/scripts/healthcheck"] },
          'failureThreshold' => 30,
          'periodSeconds' => 1,
          'timeoutSeconds' => 2,
          'successThreshold' => 1
        )

        expect(gitaly_readiness_probe).to include(
          'initialDelaySeconds' => 0
        )

        expect(gitaly_liveness_probe).to include(
          'initialDelaySeconds' => 0
        )
      end
    end

    context 'when not enabled' do
      let(:startup_probe_enabled) { 'false' }

      it 'does not set startup probe for the Gitaly container' do
        t = HelmTemplate.new(values)
        gitaly_set = t.resources_by_kind('StatefulSet').select { |key| key == gitaly_stateful_set }
        gitaly_container = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]
        gitaly_readiness_probe = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]['readinessProbe']
        gitaly_liveness_probe = gitaly_set[gitaly_stateful_set]['spec']['template']['spec']['containers'][0]['livenessProbe']

        expect(gitaly_container).not_to have_key('startupProbe')
        expect(gitaly_readiness_probe).to include(
          'initialDelaySeconds' => 10
        )
        expect(gitaly_liveness_probe).to include(
          'initialDelaySeconds' => 30
        )
      end
    end
  end
end
