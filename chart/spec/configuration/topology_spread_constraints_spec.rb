require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

IGNORED_DEPLOYMENTS = [
  'Deployment/test-certmanager',
  'Deployment/test-certmanager-cainjector',
  'Deployment/test-certmanager-webhook',
  'Deployment/test-gitlab-exporter',
  'Deployment/test-gitlab-runner',
  'Deployment/test-nginx-ingress-controller',
  'Deployment/test-prometheus-server'
].freeze

SUPPORTED_STATEFULSETS = [
  'Statefulset/test-praefect'
].freeze

describe 'local topologySpreadConstraints configuration' do
  let(:supported_statefulsets) do
    SUPPORTED_STATEFULSETS
  end

  let(:ignored_deployments) do
    IGNORED_DEPLOYMENTS
  end

  let(:default_values) do
    HelmTemplate.defaults
  end

  let(:values_with_override) do
    HelmTemplate.with_defaults(%(
      gitlab:
        geo-logcursor:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        gitlab-pages:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        gitlab-shell:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        kas:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        mailroom:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        praefect:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        sidekiq:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        spamcheck:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        toolbox:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
        webservice:
          topologySpreadConstraints:
            - labelSelector:
                matchLabels:
                  app: test
              maxSkew: 1
              topologyKey: topology.kubernetes.io/zone
              whenUnsatisfiable: DoNotSchedule
      minio:
        topologySpreadConstraints:
          - labelSelector:
              matchLabels:
                app: test
            maxSkew: 1
            topologyKey: topology.kubernetes.io/zone
            whenUnsatisfiable: DoNotSchedule
      registry:
        topologySpreadConstraints:
          - labelSelector:
              matchLabels:
                app: test
            maxSkew: 1
            topologyKey: topology.kubernetes.io/zone
            whenUnsatisfiable: DoNotSchedule
    ))
  end

  context 'when left with default values' do
    it 'does not specify topologySpreadConstraints' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)

      deployments = t.resources_by_kind('Deployment').reject { |key, _| ignored_deployments.include? key }
      deployments.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')).not_to be_present
      end

      statefulsets = t.resources_by_kind('Statefulset').select { |key, _| supported_statefulsets.include? key }
      statefulsets.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')).not_to be_present
      end
    end
  end

  context 'when setting a local topologySpreadConstraints override' do
    it 'applies to a single Deployment' do
      t = HelmTemplate.new(values_with_override)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      deployments = t.resources_by_kind('Deployment').reject { |key, _| ignored_deployments.include? key }
      deployments.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')).to be_present
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['labelSelector']['matchLabels']['app']).to eq('test')
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['maxSkew']).to eq(1)
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['topologyKey']).to eq('topology.kubernetes.io/zone')
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['whenUnsatisfiable']).to eq('DoNotSchedule')
      end

      statefulsets = t.resources_by_kind('Statefulset').select { |key, _| supported_statefulsets.include? key }
      statefulsets.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')).to be_present
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['labelSelector']['matchLabels']['app']).to eq('test')
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['maxSkew']).to eq(1)
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['topologyKey']).to eq('topology.kubernetes.io/zone')
        expect(t.dig(key, 'spec', 'template', 'spec', 'topologySpreadConstraints')[0]['whenUnsatisfiable']).to eq('DoNotSchedule')
      end
    end
  end
end
