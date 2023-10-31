# frozen_string_literal: true
require 'spec_helper'
require 'hash_deep_merge'
require 'helm_template_helper'
require 'yaml'

describe 'monitoring object configuration' do
  let(:default_values) do
    HelmTemplate.with_defaults(%(
      global:
        pages:
          enabled: true
        praefect:
          enabled: true
    ))
  end

  let(:servicemonitor_enabled_values) do
    YAML.safe_load(
      open('spec/fixtures/servicemonitor-config.yaml', 'r').read
    ).merge(default_values)
  end

  let(:servicemonitor_components) do
    servicemonitor_enabled_values['gitlab'].keys
  end

  let(:podmonitor_enabled_values) do
    YAML.safe_load(%(
      gitlab:
        sidekiq:
          metrics:
            podMonitor:
              enabled: true
    )).merge(default_values)
  end

  let(:global_monitoring_enabled) do
    YAML.safe_load(%(
      global:
        monitoring:
          enabled: true
    )).deep_merge(default_values)
  end

  let(:api_versions_args) do
    '--api-versions=monitoring.coreos.com/v1'
  end

  context 'when monitoring is disabled (default)' do
    it 'does not create any ServiceMonitors or PodMonitors' do
      template = HelmTemplate.new(default_values)
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

      expect(template.resources_by_kind('ServiceMonitor')).to be_empty
      expect(template.resources_by_kind('PodMonitor')).to be_empty
    end
  end

  context 'when monitoring is enabled via value override' do
    it 'creates ServiceMonitors' do
      template = HelmTemplate.new(servicemonitor_enabled_values.deep_merge(global_monitoring_enabled))
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

      servicemonitor_components.each do |component|
        expect(template["ServiceMonitor/test-#{component}"]).not_to be_nil, "missing ServiceMonitor for #{component}"
      end
    end

    it 'creates PodMonitor for Sidekiq' do
      template = HelmTemplate.new(podmonitor_enabled_values.deep_merge(global_monitoring_enabled))
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

      expect(template['PodMonitor/test-sidekiq']).not_to be_nil, "missing PodMonitor for Sidekiq"
    end
  end

  context 'when monitoring is enabled via Capabilities' do
    it 'creates ServiceMonitors' do
      template = HelmTemplate.new(servicemonitor_enabled_values, 'test', api_versions_args)
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

      servicemonitor_components.each do |component|
        expect(template["ServiceMonitor/test-#{component}"]).not_to be_nil, "missing ServiceMonitor for #{component}"
      end
    end

    it 'creates PodMonitor for Sidekiq' do
      template = HelmTemplate.new(podmonitor_enabled_values, 'test', api_versions_args)
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"

      expect(template['PodMonitor/test-sidekiq']).not_to be_nil, "missing PodMonitor for Sidekiq"
    end
  end
end
