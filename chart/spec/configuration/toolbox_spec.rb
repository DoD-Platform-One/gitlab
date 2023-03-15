require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'toolbox configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
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
      expect(t.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'toolbox')
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
      YAML.safe_load %(
      certmanager-issuer:
        email: test@example.com
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
      )
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
end
