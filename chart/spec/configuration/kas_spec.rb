# frozen_string_literal: true

require 'spec_helper'
require 'helm_template_helper'
require 'yaml'

describe 'kas configuration' do
  let(:values) do
    {
      'certmanager-issuer' => { 'email' => 'test@example.com' }
    }
  end

  let(:custom_secret_key) { 'kas_custom_secret_key' }
  let(:custom_secret_name) { 'kas_custom_secret_name' }
  let(:custom_config) { {} }

  let(:kas_values) do
    {
      'gitlab' => {
        'kas' => {
          'enabled' => 'true',
          'customConfig' => custom_config,
        },
      },
      'global' => {
        'kas' => { 'enabled' => 'true' },
        'imagePullPolicy' => 'Always',
        'appConfig' => { 'gitlab_kas' => {
          'key' => custom_secret_key,
          'secret' => custom_secret_name
        } }
      },
    }
  end

  let(:required_resources) do
    %w[Deployment ConfigMap Ingress Service HorizontalPodAutoscaler PodDisruptionBudget]
  end

  describe 'kas is disabled by default' do
    it 'does not create any kas related resource' do
      template = HelmTemplate.new(values)

      required_resources.each do |resource|
        resource_name = "#{resource}/test-kas"

        expect(template.resources_by_kind(resource)[resource_name]).to be_nil
      end
    end
  end

  context 'when kas is enabled with custom values' do
    let(:kas_enabled_template) do
      HelmTemplate.new(values.merge(kas_values))
    end

    it 'creates all kas related required_resources' do
      required_resources.each do |resource|
        resource_name = "#{resource}/test-kas"

        expect(kas_enabled_template.resources_by_kind(resource)[resource_name]).to be_kind_of(Hash)
      end
    end

    it 'mounts shared secret on webservice deployment' do
      webservice_secret_mounts = kas_enabled_template.projected_volume_sources(
        'Deployment/test-webservice-default',
        'init-webservice-secrets'
      )

      shared_secret_mount = webservice_secret_mounts.select do |item|
        item['secret']['name'] == custom_secret_name && item['secret']['items'][0]['key'] == custom_secret_key
      end

      expect(shared_secret_mount.length).to eq(1)
    end

    it 'mounts shared secret on kas deployment' do
      kas_secret_mounts = kas_enabled_template.projected_volume_sources(
        'Deployment/test-kas',
        'init-etc-kas'
      )

      shared_secret_mount = kas_secret_mounts.select do |item|
        item.dig('secret', 'name') == custom_secret_name && item.dig('secret', 'items', 0, 'key') == custom_secret_key
      end

      expect(shared_secret_mount.length).to eq(1)
    end

    it 'mounts config on kas deployment' do
      volume_mount = kas_enabled_template.projected_volume_sources(
        'Deployment/test-kas',
        'init-etc-kas'
      )

      config_map_mounts = volume_mount.select do |item|
        item['configMap'] && item['configMap']['name'] == 'test-kas'
      end

      expect(config_map_mounts.length).to eq(1)
    end

    describe 'templates/configmap.yaml' do
      subject(:config_yaml_data) do
        YAML.safe_load(kas_enabled_template.dig('ConfigMap/test-kas', 'data', 'config.yaml'))
      end

      it 'uses the default configuration' do
        expect(config_yaml_data['gitlab']).not_to be_nil
      end

      context 'when customConfig is given' do
        let(:custom_config) { { 'example' => 'config' } }

        it 'uses the custom config' do
          expect(config_yaml_data).to eq(custom_config)
        end
      end
    end
  end
end
