require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'task-runner configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      gitlab:
        task-runner:
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
          task-runner:
            common:
              labels:
                global: task-runner
                task-runner: task-runner
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
      expect(t.dig('ConfigMap/test-task-runner', 'metadata', 'labels')).to include('global' => 'task-runner')
      expect(t.dig('CronJob/test-task-runner-backup', 'metadata', 'labels')).to include('global' => 'task-runner')
      expect(t.dig('CronJob/test-task-runner-backup', 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'task-runner')
      expect(t.dig('Deployment/test-task-runner', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-task-runner', 'metadata', 'labels')).to include('global' => 'task-runner')
      expect(t.dig('Deployment/test-task-runner', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-task-runner', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-task-runner', 'spec', 'template', 'metadata', 'labels')).to include('pod' => true)
      expect(t.dig('Deployment/test-task-runner', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => true)
      expect(t.dig('PersistentVolumeClaim/test-task-runner-tmp', 'metadata', 'labels')).to include('global' => 'task-runner')
      expect(t.dig('PersistentVolumeClaim/test-task-runner-backup-tmp', 'metadata', 'labels')).to include('global' => 'task-runner')
      expect(t.dig('ServiceAccount/test-task-runner', 'metadata', 'labels')).to include('global' => 'task-runner')
    end
  end
end
