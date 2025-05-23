require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'toolbox configuration' do
  def env_value(name, value)
    { 'name' => name, 'value' => value.to_s }
  end

  let(:default_values) do
    HelmTemplate.with_defaults(%(
      gitlab:
        toolbox:
          backups:
            cron:
              enabled: true
              persistence:
                enabled: true
          enabled: true
          persistence:
            enabled: true
          serviceAccount:
            enabled: true
            create: true
    ))
  end

  context 'When customer provides additional labels' do
    let(:values) do
      YAML.safe_load(%(
        global:
          common:
            labels:
              global: global
              foo: global
          pod:
            labels:
              global_pod: true
        gitlab:
          toolbox:
            common:
              labels:
                global: toolbox
                toolbox: toolbox
            networkpolicy:
              enabled: true
            podLabels:
              pod: true
              global: pod
      )).deep_merge(default_values)
    end
    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-toolbox', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('CronJob/test-toolbox-backup', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'labels')).to include('toolbox' => 'toolbox')
      expect(t.dig('Deployment/test-toolbox', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-toolbox', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('Deployment/test-toolbox', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('PersistentVolumeClaim/test-toolbox-tmp', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('PersistentVolumeClaim/test-toolbox-backup-tmp', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('ServiceAccount/test-toolbox', 'metadata', 'labels')).to include('global' => 'toolbox')
    end
  end

  context 'cron job apiVersion' do
    let(:api_version) { '' }

    let(:values) do
      HelmTemplate.with_defaults(%(
        global:
          batch:
            cronJob:
              apiVersion: "#{api_version}"
        gitlab:
          toolbox:
            backups:
              cron:
                enabled: true
            enabled: true
      ))
    end

    let(:template) { HelmTemplate.new(values) }

    context 'default' do
      it 'uses batch/v1beta1 CronJob' do
        expect(template.dig('CronJob/test-toolbox-backup', 'apiVersion')).to eq 'batch/v1beta1'
      end
    end

    context 'batch/v1' do
      let(:api_version) { 'batch/v1' }

      it 'uses batch/v1 CronJob' do
        expect(template.dig('CronJob/test-toolbox-backup', 'apiVersion')).to eq 'batch/v1'
      end
    end
  end

  context 'cron and deployment securityContext' do
    context 'default' do
      it 'fsGroupChangePolicy should not be set by default' do
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'spec', 'securityContext', 'fsGroupChangePolicy')).to eq(nil)
        expect(t.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'spec', 'securityContext', 'fsGroupChangePolicy')).to eq(nil)
      end
    end

    context 'on custom fsGroupChangePolicy' do
      let(:fs_gc_policy) { 'OnRootMismatch' }
      let(:values) do
        YAML.safe_load(%(
          gitlab:
            toolbox:
              securityContext:
                fsGroupChangePolicy: #{fs_gc_policy}
        )).deep_merge(default_values)
      end

      it 'fsGroupChangePolicy should be populated' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'spec', 'securityContext', 'fsGroupChangePolicy')).to eq(fs_gc_policy)
        expect(t.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'spec', 'securityContext', 'fsGroupChangePolicy')).to eq(fs_gc_policy)
      end
    end
  end

  context 'cron job ttlSecondsAfterFinished' do
    context 'default' do
      it 'ttlSecondsAfterFinished should not be set by default' do
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'ttlSecondsAfterFinished')).to eq(nil)
      end
    end

    let(:values) do
      HelmTemplate.with_defaults %(
      gitlab:
       toolbox:
         backups:
           cron:
             enabled: true
             ttlSecondsAfterFinished: 3600
         enabled: true
      )
    end

    let(:template) { HelmTemplate.new(values) }

    context "when ttlSecondsAfterFinished is set" do
      it 'configures ttlSecondsAfterFinished in the cron job spec' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
        expect(template.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'ttlSecondsAfterFinished')).to eq(3600)
      end
    end
  end

  context 'cron job ephemeral volume' do
    let(:useGenericEphemeralVolume) { false }

    let(:values) do
      HelmTemplate.with_defaults %(
      gitlab:
        toolbox:
          backups:
            cron:
              enabled: true
              persistence:
                enabled: true
                useGenericEphemeralVolume: #{useGenericEphemeralVolume}
          enabled: true
      )
    end

    let(:template) { HelmTemplate.new(values) }

    def toolbox_tmp_volume(template)
      volume_name = 'toolbox-tmp'
      job_template_spec = template.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate')
      volumes = job_template_spec.dig('spec', 'template', 'spec', 'volumes')
      volumes.keep_if { |volume| volume['name'] == volume_name }
      volumes[0]
    end

    context "when useGenericEphemeralVolume defaults to false" do
      it 'configures a persistentVolumeClaim in the cron job' do
        toolbox_tmp_volume = toolbox_tmp_volume(template)
        expect(toolbox_tmp_volume.keys).to contain_exactly('persistentVolumeClaim', 'name')
        expect(toolbox_tmp_volume['persistentVolumeClaim'].keys).to contain_exactly('claimName')
      end
    end

    context "when useGenericEphemeralVolume is true" do
      let(:useGenericEphemeralVolume) { true }

      it 'configures a volumeClaimTemplate in the cron job' do
        toolbox_tmp_volume = toolbox_tmp_volume(template)
        expect(toolbox_tmp_volume.keys).to contain_exactly('ephemeral', 'name')
        expect(toolbox_tmp_volume['ephemeral'].keys).to contain_exactly('volumeClaimTemplate')
      end
    end
  end

  context 'cron job eviction annotation' do
    let(:safeToEvict) { false }

    let(:values) do
      HelmTemplate.with_defaults %(
        gitlab:
          toolbox:
            backups:
              cron:
                enabled: true
                safeToEvict: #{safeToEvict}
      )
    end

    let(:template) { HelmTemplate.new(values) }

    context "when safeToEvict defaults to false" do
      it 'sets the safe-to-evict annotation to false' do
        expect(template.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'annotations', 'cluster-autoscaler.kubernetes.io/safe-to-evict')).to eq("false")
      end
    end

    context "when safeToEvict defaults to true" do
      let(:safeToEvict) { true }
      it 'sets the safe-to-evict annotation to true' do
        expect(template.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'annotations', 'cluster-autoscaler.kubernetes.io/safe-to-evict')).to eq("true")
      end
    end
  end

  context 'when setting cron job nodeSelector' do
    let(:values) do
      HelmTemplate.with_defaults %(
          gitlab:
            toolbox:
              backups:
                cron:
                  enabled: true
                  nodeSelector:
                    key: "value"
        )
    end
    let(:template) { HelmTemplate.new(values) }

    it 'populates nodeSelector for toolbox cronjob' do
      expect(template.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'spec', 'nodeSelector')).to eq({ 'key' => 'value' })
    end
  end

  context 'when setting cron job tolerations' do
    let(:values) do
      HelmTemplate.with_defaults %(
          gitlab:
            toolbox:
              backups:
                cron:
                  enabled: true
                  tolerations:
                    - key: "key1"
                      operator: "Equal"
                      value: "value1"
                      effect: "NoSchedule"
        )
    end
    let(:template) { HelmTemplate.new(values) }

    it 'populates tolerations for toolbox cronjob' do
      expect(template.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'spec', 'tolerations')).to eq([{ 'key' => 'key1', 'operator' => 'Equal', 'value' => 'value1', 'effect' => 'NoSchedule' }])
    end
  end

  context 'when setting extraEnvFrom' do
    def deployment_name
      "Deployment/test-toolbox"
    end

    context 'when the global value is set' do
      let(:global_values) do
        YAML.safe_load(%(
          global:
            extraEnvFrom:
              EXTRA_ENV_VAR_B:
                secretKeyRef:
                  key: "keyB"
                  name: "nameB"
              EXTRA_ENV_VAR_C:
                secretKeyRef:
                  key: "keyC"
                  name: "nameC"
              EXTRA_ENV_VAR_D:
                secretKeyRef:
                  key: "keyD"
                  name: "nameD"
        )).deep_merge(default_values)
      end

      let(:global_template) { HelmTemplate.new(global_values) }

      it 'sets those environment variables on toolbox pod' do
        expect(global_template.exit_code).to eq(0)

        expect(global_template.env(deployment_name, 'toolbox'))
          .to include(
            { 'name' => 'EXTRA_ENV_VAR_B', 'valueFrom' => { "secretKeyRef" => { "name" => "nameB", "key" => "keyB" } } },
            { 'name' => 'EXTRA_ENV_VAR_C', 'valueFrom' => { "secretKeyRef" => { "name" => "nameC", "key" => "keyC" } } },
            { 'name' => 'EXTRA_ENV_VAR_D', 'valueFrom' => { "secretKeyRef" => { "name" => "nameD", "key" => "keyD" } } }
          )
      end

      context 'when the chart-level value is set' do
        let(:chart_values) do
          YAML.safe_load(%(
            gitlab:
              toolbox:
                extraEnvFrom:
                  EXTRA_ENV_VAR_A:
                    secretKeyRef:
                      key: "keyA-chart"
                      name: "nameA-chart"
                  EXTRA_ENV_VAR_C:
                    secretKeyRef:
                      key: "keyC-chart"
                      name: "nameC-chart"
                  EXTRA_ENV_VAR_D:
                    secretKeyRef:
                      key: "keyD-chart"
                      name: "nameD-chart"
          ))
        end

        let(:chart_template) { HelmTemplate.new(global_values.deep_merge(chart_values)) }

        it 'sets those environment variables on toolbox pod' do
          expect(chart_template.exit_code).to eq(0)

          expect(chart_template.env(deployment_name, 'toolbox'))
            .to include(
              { 'name' => 'EXTRA_ENV_VAR_A', 'valueFrom' => { "secretKeyRef" => { "name" => "nameA-chart", "key" => "keyA-chart" } } },
              { 'name' => 'EXTRA_ENV_VAR_B', 'valueFrom' => { "secretKeyRef" => { "name" => "nameB", "key" => "keyB" } } },
              { 'name' => 'EXTRA_ENV_VAR_C', 'valueFrom' => { "secretKeyRef" => { "name" => "nameC-chart", "key" => "keyC-chart" } } },
              { 'name' => 'EXTRA_ENV_VAR_D', 'valueFrom' => { "secretKeyRef" => { "name" => "nameD-chart", "key" => "keyD-chart" } } }
            )
        end

        it 'overrides global values' do
          expect(chart_template.env(deployment_name, 'toolbox'))
            .to include(
              { 'name' => 'EXTRA_ENV_VAR_C', 'valueFrom' => { "secretKeyRef" => { "name" => "nameC-chart", "key" => "keyC-chart" } } },
              { 'name' => 'EXTRA_ENV_VAR_D', 'valueFrom' => { "secretKeyRef" => { "name" => "nameD-chart", "key" => "keyD-chart" } } }
            )
        end
      end
    end
  end

  context 'backup configuration' do
    context 'using azure backend' do
      let(:values) do
        YAML.safe_load(%(
          gitlab:
            toolbox:
              backups:
                objectStorage:
                  config:
                    secret: azure-backup-conf
                    key: azconf
                  backend: azure
        )).deep_merge(default_values)
      end

      let(:template) do
        HelmTemplate.new(values)
      end

      it 'renders the template' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'configures the deployment to use the azure backend' do
        deployment_spec = template.dig("Deployment/test-toolbox", 'spec', 'template', 'spec')
        container_env = deployment_spec.dig('containers', 0, 'env')
        expect(container_env).to include(env_value('AZURE_CONFIG_FILE', '/etc/gitlab/objectstorage/azure_config'))
        expect(container_env).to include(env_value('BACKUP_BACKEND', 'azure'))
        init_secret = deployment_spec['volumes'].find { |s| s['name'] == 'init-toolbox-secrets' }
        token_secret = init_secret["projected"]["sources"].find { |sc| sc['secret']['name'] == 'azure-backup-conf' }["secret"]
        expect(token_secret["items"]).to eq([{ "key" => 'azconf', "path" => 'objectstorage/azure_config' }])
      end

      it 'configures the cronjob to use the azure backend' do
        cronjob_spec = template.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'spec')
        container_env = cronjob_spec.dig('containers', 0, 'env')
        expect(container_env).to include(env_value('AZURE_CONFIG_FILE', '/etc/gitlab/objectstorage/azure_config'))
        expect(container_env).to include(env_value('BACKUP_BACKEND', 'azure'))
        init_secret = cronjob_spec['volumes'].find { |s| s['name'] == 'init-toolbox-secrets' }
        token_secret = init_secret["projected"]["sources"].find { |sc| sc['secret']['name'] == 'azure-backup-conf' }["secret"]
        expect(token_secret["items"]).to eq([{ "key" => 'azconf', "path" => 'objectstorage/azure_config' }])
      end
    end
  end
end
