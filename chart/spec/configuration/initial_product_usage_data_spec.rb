require 'spec_helper'
require 'helm_template_helper'
require 'yaml'

describe 'initial_gitlab_product_usage_data configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  context 'with default values' do
    it 'does not set initial_gitlab_product_usage_data in configmaps' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      webservice_yml = t.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb')
      expect(webservice_yml).not_to include('initial_gitlab_product_usage_data:')

      sidekiq_yml = t.dig('ConfigMap/test-sidekiq', 'data', 'gitlab.yml.erb')
      expect(sidekiq_yml).not_to include('initial_gitlab_product_usage_data:')
    end
  end

  context 'when gitlabProductUsageData is set to false' do
    let(:test_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            initialDefaults:
              gitlabProductUsageData: false
      )).deep_merge(default_values)
    end

    it 'sets initial_gitlab_product_usage_data to false in configmaps' do
      t = HelmTemplate.new(test_values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      webservice_yml = t.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb')
      expect(webservice_yml).to include('initial_gitlab_product_usage_data: false')

      sidekiq_yml = t.dig('ConfigMap/test-sidekiq', 'data', 'gitlab.yml.erb')
      expect(sidekiq_yml).to include('initial_gitlab_product_usage_data: false')
    end
  end

  context 'when gitlabProductUsageData is set to true' do
    let(:test_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            initialDefaults:
              gitlabProductUsageData: true
      )).deep_merge(default_values)
    end

    it 'sets initial_gitlab_product_usage_data to true in configmaps' do
      t = HelmTemplate.new(test_values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      webservice_yml = t.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb')
      expect(webservice_yml).to include('initial_gitlab_product_usage_data: true')

      sidekiq_yml = t.dig('ConfigMap/test-sidekiq', 'data', 'gitlab.yml.erb')
      expect(sidekiq_yml).to include('initial_gitlab_product_usage_data: true')
    end
  end
end
