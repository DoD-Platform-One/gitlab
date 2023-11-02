require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'ClickHouse configuration' do
  let(:charts) do
    {
      'webservice' => {
        'identifier' => 'test-webservice-default',
        'init_mount' => 'init-webservice-secrets'
      },
      'sidekiq' => {
        'identifier' => 'test-sidekiq-all-in-1-v2',
        'init_mount' => 'init-sidekiq-secrets'
      },
      'toolbox' => {
        'identifier' => 'test-toolbox',
        'init_mount' => 'init-toolbox-secrets'
      }
    }
  end

  let(:values) do
    HelmTemplate.with_defaults(%(
        global:
          clickhouse:
            enabled: false
    ))
  end

  let(:template) { HelmTemplate.new(values) }

  def clickhouse_secret(chart, template)
    chart_config = charts[chart]
    volumes = template.dig("Deployment/#{chart_config['identifier']}", 'spec', 'template', 'spec', 'volumes')

    secretes = volumes.find { |volume| volume['name'] == chart_config['init_mount'] }
    secretes['projected']['sources'].find { |item| item['secret']['name'] == 'gitlab-click-house-password' }
  end

  it 'does not generate the click_house.yml file', :aggregate_failures do
    expect(template.exit_code).to eq(0)
    charts.each_key do |chart|
      clickhouse_erb = template.dig("ConfigMap/test-#{chart}", 'data', 'click_house.yml.erb')
      expect(clickhouse_erb).to be_nil
      expect(clickhouse_secret(chart, template)).to be_nil
    end
  end

  context 'when clickhouse is enabled' do
    let(:values) do
      HelmTemplate.with_defaults(%(
          global:
            clickhouse:
              enabled: true
              main:
                username: default
                password:
                  secret: gitlab-click-house-password
                  key: main_password
                database: gitlab_clickhouse_main_production
                url: 'http://localhost:3333'
      ))
    end

    it 'generates the click_house.yml file', :aggregate_failures do
      expect(template.exit_code).to eq(0)
      charts.each do |chart, config|
        clickhouse_erb = template.dig("ConfigMap/test-#{chart}", 'data', 'click_house.yml.erb')
        expect(clickhouse_erb).not_to be_nil

        db_config = YAML.safe_load(clickhouse_erb)['production']['main']
        expect(db_config['database']).to eq('gitlab_clickhouse_main_production')
        expect(db_config['url']).to eq('http://localhost:3333')
        expect(db_config['password']).to eq("<%= File.read('/etc/gitlab/clickhouse/.main_password').chomp.to_json %>")
        expect(db_config['username']).to eq('default')

        clickhouse_secret = clickhouse_secret(chart, template)
        expect(clickhouse_secret).not_to be_nil
        expect(clickhouse_secret['secret']['items']).to eq([
                                                             {
                                                               'key' => 'password',
                                                               'path' => 'clickhouse/.main_password'
                                                             }
                                                           ])
      end
    end
  end
end
