require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Microsoft Graph Mailer configuration' do
  let(:values) do
    YAML.safe_load(%(
        global:
          appConfig:
            microsoft_graph_mailer:
              enabled: true
              user_id: "YOUR-USER-ID"
              tenant: "YOUR-TENANT-ID"
              client_id: "YOUR-CLIENT-ID"
              client_secret:
                secret: microsoft-graph-mailer-client-secret
                key: secret
              azure_ad_endpoint: "https://login.microsoftonline.com"
              graph_endpoint: "https://graph.microsoft.com"
    )).deep_merge(HelmTemplate.certmanager_issuer)
  end

  let(:template) { HelmTemplate.new(values) }

  it 'populates microsoft_graph_mailer to gitlab.yml', :aggregate_failures do
    expect(template.exit_code).to eq(0)
    # check that gitlab.yml.erb contains production.microsoft_graph_mailer
    gitlab_yml_erb = template.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb')
    expect(gitlab_yml_erb).to include(%(client_secret: <%= File.read('/etc/gitlab/microsoft_graph_mailer/client_secret').strip.to_json %>))
    microsoft_graph_mailer = YAML.safe_load(gitlab_yml_erb)['production']['microsoft_graph_mailer']
    expect(microsoft_graph_mailer['enabled']).to eq(true)
    expect(microsoft_graph_mailer['user_id']).to eq('YOUR-USER-ID')
    expect(microsoft_graph_mailer['client_id']).to eq('YOUR-CLIENT-ID')
    expect(microsoft_graph_mailer['azure_ad_endpoint']).to eq('https://login.microsoftonline.com')
    expect(microsoft_graph_mailer['graph_endpoint']).to eq('https://graph.microsoft.com')
  end
end
