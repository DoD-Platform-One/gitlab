require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'GitLab Ingress configuration(s)' do
  def get_paths(template, ingress_name)
    template.dig("Ingress/#{ingress_name}", 'spec', 'rules', 0, 'http', 'paths')
  end

  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  let(:ingress_names) do
    %w[
      test-grafana
      test-gitlab-pages
      test-kas
      test-webservice-default
      test-webservice-smartcard
      test-minio
      test-registry
    ]
  end

  let(:enable_all_ingress) do
    default_values.deep_merge(YAML.safe_load(%(
      global:
        appConfig:
          smartcard:
            enabled: true
        minio:
          enabled: true
        pages:
          enabled: true
        grafana:
          enabled: true
        kas:
          enabled: true
      registry:
        enabled: true
    )))
  end

  it 'All Ingress are tested' do
    template = HelmTemplate.new(enable_all_ingress)
    expect(template.exit_code).to eq(0)

    all_ingress = template.resources_by_kind("Ingress").keys
    all_ingress.map! { |item| item.split('/')[1] }
    expect(all_ingress.sort.join(',')).to eq(ingress_names.sort.join(','))
  end

  describe 'global.ingress.path' do
    context 'default (/)' do
      it 'populates /' do
        template = HelmTemplate.new(enable_all_ingress)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          paths = get_paths(template, ingress_name)
          paths.each do |p|
            expect(p["path"]).to end_with('/')
          end
        end
      end
    end

    context 'asterisk (/*)' do
      let(:asterisk) do
        enable_all_ingress.deep_merge(YAML.safe_load(%(
          global:
            ingress:
              path: /*
        )))
      end

      it 'populates /*' do
        template = HelmTemplate.new(asterisk)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          paths = get_paths(template, ingress_name)
          paths.each do |p|
            expect(p["path"]).to end_with('/*')
          end
        end
      end
    end

    context 'invalid (/bogus)' do
      let(:bogus) do
        enable_all_ingress.deep_merge(YAML.safe_load(%(
          global:
            ingress:
              path: /bogus
        )))
      end

      it 'fails due to gitlab.webservice.ingress.requireBasePath' do
        template = HelmTemplate.new(bogus)
        expect(template.exit_code).not_to eq(0)
      end
    end
  end
end
