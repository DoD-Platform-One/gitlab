# frozen_string_literal: true

require 'spec_helper'
require 'hash_deep_merge'
require 'helm_template_helper'
require 'yaml'

describe 'cells configuration' do
  let(:charts) { %w[webservice sidekiq toolbox] }
  let(:default_values) do
    HelmTemplate.defaults
  end

  context 'when no cell configuration is set' do
    let(:helm_template) do
      HelmTemplate.new(default_values)
    end

    it 'generates no cell configuration in the gitlab.yml file' do
      charts.each do |chart|
        expect(gitlab_yml_cell(chart)).to eq(nil)
      end
    end
  end

  context 'when custom cell configuration is set' do
    let(:cell_values) do
      {
        'global' => {
          'appConfig' => {
            'cell' => {
              'enabled' => true,
              'id' => 1,
              'database' => {
                'skipSequenceAlteration' => false
              },
              'topologyServiceClient' => {
                'address' => 'topology-service.gitlab.example.com:443',
                'caFile' => 'path/to/your/ca/.pem',
                'certificateFile' => 'path/to/your/cert/.pem',
                'privateKeyFile' => 'path/to/your/key/.pem'
              }
            }
          }
        }
      }
    end
    let(:helm_template) do
      HelmTemplate.new(cell_values.deep_merge!(default_values))
    end

    it 'generates no cell configuration in the gitlab.yml file' do
      expected_values = {
        "enabled" => true,
        "id" => 1,
        "database" =>
          {
            "skip_sequence_alteration" => false
          },
        "topology_service_client" => {
          "address" => "topology-service.gitlab.example.com:443",
          "ca_file" => "path/to/your/ca/.pem",
          "certificate_file" => "path/to/your/cert/.pem",
          "private_key_file" => "path/to/your/key/.pem"
        }
      }

      charts.each do |chart|
        expect(gitlab_yml_cell(chart)).to eq(expected_values)
      end
    end
  end

  def gitlab_yml_cell(chart)
    YAML.safe_load(
      helm_template.resources_by_kind('ConfigMap')["ConfigMap/test-#{chart}"]['data']['gitlab.yml.erb']
    )['production']['cell']
  end
end
