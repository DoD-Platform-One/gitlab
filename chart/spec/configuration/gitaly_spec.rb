require 'spec_helper'
require 'helm_template_helper'
require 'runtime_template_helper'
require 'tomlrb'
require 'yaml'
require 'hash_deep_merge'

describe 'Gitaly configuration' do
  let(:default_values) { HelmTemplate.defaults }
  let(:values) { default_values }
  let(:template) { HelmTemplate.new(values) }

  let(:configmap_name) { 'ConfigMap/test-gitaly' }
  let(:statefulset_name) { 'StatefulSet/test-gitaly' }
  let(:service_name) { 'Service/test-gitaly' }

  let(:configmap) { template.resources_by_kind('ConfigMap')[configmap_name] }
  let(:statefulset) { template.resources_by_kind('StatefulSet')[statefulset_name] }
  let(:service) { template.resources_by_kind('Service')[service_name] }

  let(:config_toml) { configmap['data']['config.toml.tpl'] }
  let(:gitlab_yml) { render_erb(template.dig('ConfigMap/test-webservice','data','gitlab.yml.erb')) }

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
      # check that gitlab.yml.erb contains production.repositories.storages
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
        # check that gitlab.yml.erb contains production.repositories.storages
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
        # check that gitlab.yml.erb contains production.repositories.storages
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
        # check that gitlab.yml.erb contains production.repositories.storages
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
        nil | nil | 'OnRootMismatch' | { 'fsGroup' => 1000, 'runAsUser' => 1000, 'fsGroupChangePolicy' => 'OnRootMismatch' }
        nil | ''  | nil              | { 'fsGroup' => 1000 }
        nil | 24  | ''               | { 'fsGroup' => 1000, 'runAsUser' => 24 }
        42  | nil | 'OnRootMismatch' | { 'fsGroup' => 42, 'runAsUser' => 1000, 'fsGroupChangePolicy' => 'OnRootMismatch' }
        42  | ''  | nil              | { 'fsGroup' => 42 }
        42  | 24  | ''               | { 'fsGroup' => 42, 'runAsUser' => 24 }
        ''  | nil | 'OnRootMismatch' | { 'runAsUser' => 1000, 'fsGroupChangePolicy' => 'OnRootMismatch' }
        ''  | ''  | nil              | nil
        ''  | 24  | ''               | { 'runAsUser' => 24 }
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

        it 'should render securityContext correctly' do
          security_context = statefulset['spec']['template']['spec']['securityContext']
          expect(security_context).to eq(expectedContext)
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
      expect(config_toml).to include(
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
      ))
    end

    let(:values) { labeled_values.deep_merge(default_values) }

    context 'with only gitaly' do
      it 'Populates the additional labels in the expected manner' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
        expect(template.dig('ConfigMap/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(template.dig('StatefulSet/test-gitaly', 'metadata', 'labels')).to include('foo' => 'global')
        expect(template.dig('StatefulSet/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(template.dig('StatefulSet/test-gitaly', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(template.dig('StatefulSet/test-gitaly', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(template.dig('StatefulSet/test-gitaly', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
        expect(template.dig('StatefulSet/test-gitaly', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(template.dig('StatefulSet/test-gitaly', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).not_to include('global' => 'gitaly')
        expect(template.dig('StatefulSet/test-gitaly', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).to include('foo' => 'global')
        expect(template.dig('PodDisruptionBudget/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(template.dig('Service/test-gitaly', 'metadata', 'labels')).to include('global' => 'service')
        expect(template.dig('Service/test-gitaly', 'metadata', 'labels')).to include('gitaly' => 'gitaly')
        expect(template.dig('Service/test-gitaly', 'metadata', 'labels')).to include('global_service' => 'true')
        expect(template.dig('Service/test-gitaly', 'metadata', 'labels')).to include('service' => 'true')
        expect(template.dig('Service/test-gitaly', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(template.dig('ServiceAccount/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
      end

      it 'renders a TOML configuration file' do
        rendered_toml = render_toml(config_toml, 'HOSTNAME' => 'default')

        expect(rendered_toml.keys).to match_array(%w[auth bin_dir git gitlab gitlab-shell hooks listen_addr logging prometheus_listen_addr storage graceful_restart_timeout])
        expect(rendered_toml['storage']).to eq([{ 'name' => 'default', 'path' => '/home/git/repositories' }])
        expect(rendered_toml['auth']['token'].length).to eq(32)
      end
    end

    context 'with praefect enabled' do
      let(:values) do
        YAML.safe_load(%(
          global:
            praefect:
              enabled: true
              virtualStorages:
              - name: default
                gitalyReplicas: 3
        )).deep_merge(default_values).deep_merge(labeled_values)
      end

      let(:configmap_name) { 'ConfigMap/test-gitaly-praefect' }

      it 'Populates the additional labels in the expected manner' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
        expect(template.dig('ConfigMap/test-gitaly-praefect', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(template.dig('StatefulSet/test-gitaly-default', 'metadata', 'labels')).to include('foo' => 'global')
        expect(template.dig('StatefulSet/test-gitaly-default', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(template.dig('StatefulSet/test-gitaly-default', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(template.dig('StatefulSet/test-gitaly-default', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(template.dig('StatefulSet/test-gitaly-default', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
        expect(template.dig('StatefulSet/test-gitaly-default', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(template.dig('StatefulSet/test-gitaly-default', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).to include('storage' => 'default')
        expect(template.dig('StatefulSet/test-gitaly-default', 'spec', 'volumeClaimTemplates', 0, 'metadata', 'labels')).not_to include('global' => 'gitaly')
        expect(template.dig('PodDisruptionBudget/test-gitaly-default', 'metadata', 'labels')).to include('global' => 'gitaly')
        expect(template.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('gitaly' => 'gitaly')
        expect(template.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('global' => 'service')
        expect(template.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('global_service' => 'true')
        expect(template.dig('Service/test-gitaly-default', 'metadata', 'labels')).to include('service' => 'true')
        expect(template.dig('Service/test-gitaly-default', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(template.dig('ServiceAccount/test-gitaly', 'metadata', 'labels')).to include('global' => 'gitaly')
      end

      it 'renders a TOML configuration file' do
        rendered_toml = render_toml(config_toml, 'HOSTNAME' => 'test-gitaly-default-0')

        expect(rendered_toml.keys).to match_array(%w[auth bin_dir git gitlab gitlab-shell hooks listen_addr logging prometheus_listen_addr storage graceful_restart_timeout])
        expect(rendered_toml['storage']).to eq([{ 'name' => 'test-gitaly-default-0', 'path' => '/home/git/repositories' }])
        expect(rendered_toml['auth']['token'].length).to eq(32)
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

      it 'populates a pack_objects_cache section in config.toml.tpl' do
        expect(config_toml).to include(
          <<~CONFIG
          [pack_objects_cache]
          enabled = #{pack_objects_cache_enabled}
          dir = "#{pack_objects_cache_dir}"
          max_age = "#{pack_objects_cache_max_age}"
          min_occurrences = #{pack_objects_cache_min_occurrences}
        CONFIG
        )
      end
    end

    context 'when not enabled' do
      let(:pack_objects_cache_enabled) { 'false' }
      let(:pack_objects_cache_dir) { '/pack-objects-cache' }
      let(:pack_objects_cache_max_age) { '10m' }
      let(:pack_objects_cache_min_occurrences) { '1' }

      it 'does not populate a pack_objects_cache section in config.toml.tpl' do
        expect(config_toml).not_to match(/^\[pack_objects_cache\]/)
      end
    end
  end

  context 'timeout' do
    context 'when enabled' do
      let(:values) do
        YAML.safe_load(%(
          gitlab:
            gitaly:
              timeout:
                uploadPackNegotiation: 10m
                uploadArchiveNegotiation: 20m
        )).merge(default_values)
      end

      it 'populates a timeout section in config.toml.tpl' do
        expect(config_toml).to include(
          <<~CONFIG
          [timeout]
          upload_pack_negotiation = "10m"
          upload_archive_negotiation = "20m"
        CONFIG
        )
      end
    end

    context 'when not enabled' do
      let(:values) do
        YAML.safe_load(%(
          gitlab:
            gitaly: {}
        )).merge(default_values)
      end

      it 'does not populate a timeout section in config.toml.tpl' do
        expect(config_toml).not_to match(/^\[timeout\]/)
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

      it 'populates a signing_key field in config.toml.tpl' do
        expect(config_toml).to include "signing_key = '/etc/gitlab-secrets/gitaly/signing_key.gpg'"
      end
    end

    context 'when disabled' do
      let(:gpg_signing_enabled) { false }
      let(:gpg_secret_name) { 'dont use me' }
      let(:gpg_secret_key) { 'gpgisunfun' }

      it 'does not populate a signing_key field in config.toml.tpl' do
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

    it 'renders the template' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    it 'sets the object storage url' do
      expect(config_toml).to include(
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

    context 'when enabled' do
      let(:gomemlimit_enabled) { 'true' }
      let(:resources_limits_memory) { '100Mi' }

      it 'sets the env var GOMEMLIMIT' do
        expect(statefulset['spec']['template']['spec']['containers'][0]['env'])
          .to include(
            'name' => 'GOMEMLIMIT',
            'valueFrom' => { 'resourceFieldRef' => { 'containerName' => 'gitaly', 'resource' => 'limits.memory' } }
          )
      end
    end

    context 'when not enabled' do
      let(:gomemlimit_enabled) { 'false' }
      let(:resources_limits_memory) { '' }

      it 'does not set the env var GOMEMLIMIT' do
        expect(statefulset['spec']['template']['spec']['containers'][0]['env'].map { |env| env['name'] })
          .not_to include('GOMEMLIMIT')
      end
    end
  end

  context 'shareProcessNamespace' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            shareProcessNamespace: #{share_process_namespace_enabled}
      )).merge(default_values)
    end

    context 'when enabled' do
      let(:share_process_namespace_enabled) { true }

      it 'enables shareProcessNamespace' do
        expect(statefulset['spec']['template']['spec']).to include(
          'shareProcessNamespace' => true
        )
      end
    end

    context 'when not enabled' do
      let(:share_process_namespace_enabled) { false }

      it 'does not set shareProcessNamespace' do
        expect(statefulset['spec']['template']['spec']).not_to include('shareProcessNamespace')
      end
    end
  end

  context 'concurrency' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            shell:
              concurrency:
              - rpc: MyTestRPC
                foo: bar
              - rpc: AnotherTestRPC
                max_queue_size: 10
      )).deep_merge(default_values)
    end

    let(:template) { HelmTemplate.new(values) }
    let(:gitaly_config) { template.dig('ConfigMap/test-gitaly', 'data', 'config.toml.tpl') }
    let(:toml) { render_toml(gitaly_config, 'HOSTNAME' => 'test-gitaly-default-0') }

    context 'with arbitrary config keys' do
      it 'renders the template' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'sets the concurrency keys' do
        expect(toml['concurrency']).to eq([{ 'foo' => 'bar', 'rpc' => 'MyTestRPC' },
          { 'max_queue_size' => 10, 'rpc' => 'AnotherTestRPC' }])
      end
    end

    context 'with mixed Camel and Snake case values' do
      let(:values) do
        YAML.safe_load(%(
          gitlab:
            gitaly:
              shell:
                concurrency:
                - rpc: CamelCaseTest
                  MaxQueueSize: 10
                  rpc_timeout: 5s
        )).deep_merge(default_values)
      end

      it 'renders the template' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'renders the only snake case keys' do
        expect(toml['concurrency']).to eq([{ 'max_queue_size' => 10,
                                             'rpc_timeout' => '5s',
                                             'rpc' => 'CamelCaseTest' }])
      end
    end
  end

  context 'bundleUri' do
    let(:values) do
      YAML.safe_load(%(
        gitlab:
          gitaly:
            bundleUri:
              goCloudUrl: 'gs://<bucket>'
      )).deep_merge(default_values)
    end

    let(:template) { HelmTemplate.new(values) }
    let(:gitaly_config) { template.dig('ConfigMap/test-gitaly', 'data', 'config.toml.tpl') }
    let(:toml) { render_toml(gitaly_config, 'HOSTNAME' => 'default') }

    it 'renders the template' do
      puts values
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    it 'sets the keys' do
      expect(toml['bundle_uri']).to eq({ 'go_cloud_url' => 'gs://<bucket>' })
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
                maxCgroupsPerRepo: 2
      )).deep_merge(default_values)
    end

    context 'when enabled' do
      let(:cgroups_enabled) { true }

      it 'renders the template' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'sets the cgroups config' do
        expect(config_toml).to include(
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
          max_cgroups_per_repo = 2
          CONFIG
        )
      end

      it 'sets the cgroups init container' do
        gitaly_init_container = statefulset['spec']['template']['spec']['initContainers'][0]
        gitaly_init_container_env = statefulset['spec']['template']['spec']['initContainers'][0]['env']

        expect(gitaly_init_container['name']).to eq('init-cgroups')
        expect(gitaly_init_container['image']).to eq('registry.gitlab.com/gitlab-org/build/cng/gitaly-init-cgroups:master')
        expect(gitaly_init_container['imagePullPolicy']).to eq('IfNotPresent')
        expect(gitaly_init_container['securityContext']).to include('runAsUser' => 0, 'runAsGroup' => 0)
        expect(gitaly_init_container_env.map { |env| env['name'] }).to match_array(%w[GITALY_POD_UID CGROUP_PATH OUTPUT_PATH TZ])
      end
    end

    context 'when disabled' do
      let(:cgroups_enabled) { false }

      it 'does not populate a cgroups field in config.toml.tpl' do
        expect(config_toml).not_to match(/^\[cgroups\]/)
        expect(config_toml).not_to match(/^\[cgroups.repositories\]/)
      end

      it 'does not add an initContainer to gitaly' do
        expect(statefulset['spec']['template']['spec']['initContainers'].map { |c| c['name'] })
          .not_to include('init-cgroups')
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
                failureThreshold: 60
      )).merge(default_values)
    end

    context 'when enabled' do
      let(:startup_probe_enabled) { 'true' }

      it 'sets the startup probe config' do
        gitaly_startup_probe = statefulset['spec']['template']['spec']['containers'][0]['startupProbe']
        gitaly_readiness_probe = statefulset['spec']['template']['spec']['containers'][0]['readinessProbe']
        gitaly_liveness_probe = statefulset['spec']['template']['spec']['containers'][0]['livenessProbe']

        expect(gitaly_startup_probe).to include(
          'initialDelaySeconds' => 5,
          'grpc' => { "port" => 8075 },
          'failureThreshold' => 60,
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
        gitaly_container = statefulset['spec']['template']['spec']['containers'][0]
        gitaly_readiness_probe = statefulset['spec']['template']['spec']['containers'][0]['readinessProbe']
        gitaly_liveness_probe = statefulset['spec']['template']['spec']['containers'][0]['livenessProbe']

        expect(gitaly_container).not_to have_key('startupProbe')
        expect(gitaly_readiness_probe).to include(
          'initialDelaySeconds' => 0
        )
        expect(gitaly_liveness_probe).to include(
          'initialDelaySeconds' => 0
        )
      end
    end
  end

  context 'gracefulRestartTimeout' do
    let(:values) do
      vals = { 'gitlab' => { 'gitaly' => {} } }
      vals['gitlab']['gitaly']['gracefulRestartTimeout'] = graceful_restart_timeout unless graceful_restart_timeout.nil?
      vals.merge(default_values)
    end

    context 'when default' do
      let(:graceful_restart_timeout) { nil }

      it 'sets pod termination grace period' do
        expect(statefulset['spec']['template']['spec']['terminationGracePeriodSeconds']).to eq(30)
      end

      it 'sets gitaly config termination grace period' do
        expect(config_toml).to include "graceful_restart_timeout = \"25s\""
      end
    end

    context 'when seconds' do
      let(:graceful_restart_timeout) { 45 }

      it 'sets pod termination grace period' do
        expect(statefulset['spec']['template']['spec']['terminationGracePeriodSeconds']).to eq(50)
      end

      it 'sets gitaly config termination grace period' do
        expect(config_toml).to include "graceful_restart_timeout = \"45s\""
      end
    end

    context 'when minutes' do
      let(:graceful_restart_timeout) { 120 }

      it 'sets pod termination grace period' do
        expect(statefulset['spec']['template']['spec']['terminationGracePeriodSeconds']).to eq(125)
      end

      it 'sets gitaly config termination grace period' do
        expect(config_toml).to include "graceful_restart_timeout = \"2m0s\""
      end
    end
  end

  context 'daily maintenace is configured' do
    let(:values) do
      YAML.safe_load(%(
      global:
        gitaly:
          enabled: true
      gitlab:
        gitaly:
          dailyMaintenance:
            disabled: true
            startHour: 12
            startMinute: 59
            duration: 5m
            storages: ["default", "custom"]
      )).merge(default_values)
    end

    it 'renders the template' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    it 'has the maintenance configuration' do
      expect(config_toml).to include <<~CONFIG
      [daily_maintenance]
      disabled = true
      start_hour = 12
      start_minute = 59
      duration = "5m"
      storages = ["default","custom"]
      CONFIG
    end
  end

  context 'gitaly service' do
    let(:values) do
      YAML.safe_load(%(
      global:
        gitaly:
          enabled: true
      gitlab:
        gitaly:
          service:
            type: #{gitaly_service_type}
            #{"clusterIP: #{gitaly_cluster_ip_address}" unless gitaly_cluster_ip_address.nil?}
            #{"loadBalancerIP: #{gitaly_lb_ip_address}" unless gitaly_lb_ip_address.nil?}
      )).merge(default_values)
    end

    context 'when service.clusterIP is given' do
      let(:gitaly_service_type) { 'ClusterIP' }
      let(:gitaly_cluster_ip_address) { '10.0.0.1' }
      let(:gitaly_lb_ip_address) {}

      it 'has ClusterIP type and no customizations by default' do
        expect(service['spec']).to include('type' => 'ClusterIP')
        expect(service['spec']).not_to have_key('loadBalancerIP')
      end

      it 'sets the clusterIP' do
        expect(service['spec']).to include('type' => 'ClusterIP')
        expect(service['spec']).to include('clusterIP' => '10.0.0.1')
        expect(service['spec']).not_to have_key('loadBalancerIP')
      end
    end

    context 'when service.loadBalancerIP is given' do
      let(:gitaly_service_type) { 'LoadBalancer' }
      let(:gitaly_cluster_ip_address) {}
      let(:gitaly_lb_ip_address) { '10.0.0.8' }

      it 'has LoadBalancerIP type and no customizations by default' do
        expect(service['spec']).to include('type' => 'LoadBalancer')
        expect(service['spec']).not_to have_key('clusterIP')
      end

      it 'sets the LoadBalancerIP' do
        expect(service['spec']).to include('type' => 'LoadBalancer')
        expect(service['spec']).to include('loadBalancerIP' => '10.0.0.8')
        expect(service['spec']).not_to have_key('clusterIP')
      end
    end

    context 'when service.clusterIP and service.loadBalancerIP is given' do
      let(:gitaly_service_type) { 'LoadBalancer' }
      let(:gitaly_cluster_ip_address) { '10.0.0.1' }
      let(:gitaly_lb_ip_address) { '10.0.0.8' }

      it 'sets the LoadBalancerIP and ClusterIP' do
        expect(service['spec']).to include('type' => 'LoadBalancer')
        expect(service['spec']).to include('clusterIP' => '10.0.0.1')
        expect(service['spec']).to include('loadBalancerIP' => '10.0.0.8')
      end
    end

    context 'when service.type is NodePort and clusterIP is None' do
      let(:gitaly_service_type) { 'NodePort' }
      let(:gitaly_cluster_ip_address) { 'None' }
      let(:gitaly_lb_ip_address) {}

      it 'it does not set a clusterIP' do
        expect(service['spec']).to include('type' => 'NodePort')
        expect(service['spec']).not_to have_key('clusterIP')
      end
    end
  end
end
