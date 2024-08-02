require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

SUPPORTED_NODE_AFFINITY_DEPLOYMENTS = [
  'Deployment/test-registry',
  'Deployment/test-toolbox',
  'Deployment/test-kas',
  'Deployment/test-gitlab-shell',
  'Deployment/test-gitlab-exporter',
  'Deployment/test-gitlab-shell',
  'Deployment/test-toolbox',
  'StatefulSet/test-gitaly'
].freeze
IGNORED_DEPLOYMENTS = [
  'Deployment/test-certmanager',
  'Deployment/test-certmanager-cainjector',
  'Deployment/test-certmanager-webhook',
  'Deployment/test-cert-manager',
  'Deployment/test-cert-manager-cainjector',
  'Deployment/test-cert-manager-webhook',
  'Deployment/test-gitlab-runner',
  'Deployment/test-minio',
  'Deployment/test-nginx-ingress-controller',
  'Deployment/test-prometheus-server'
].freeze

describe 'global affinity configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  let(:overridden_values) do
    HelmTemplate.with_defaults(%(
      global:
        nodeAffinity: "hard"
        antiAffinity: "hard"
        affinity:
          nodeAffinity:
            key: "test.com/zone"
            values:
            - us-east1-a
            - us-east1-b
          podAntiAffinity:
            topologyKey: "test.com/hostname"
    ))
  end

  let(:ignored_deployments) do
    IGNORED_DEPLOYMENTS
  end

  let(:supported_node_affinity_deployments) do
    SUPPORTED_NODE_AFFINITY_DEPLOYMENTS
  end

  context 'when left with default values' do
    it 'specifies soft antiAffinity' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)

      deployments = t.resources_by_kind('Deployment').reject { |key, _| ignored_deployments.include? key }
      deployments.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')).to be_present
        expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')[0]['podAffinityTerm']['topologyKey']).to eq('kubernetes.io/hostname')
      end
    end

    it 'does not specify nodeAffinity' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)

      deployments = t.resources_by_kind('Deployment').reject { |key, _| ignored_deployments.include? key }
      deployments.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity')).not_to be_present
      end
    end
  end

  context 'when enabling nodeAffinity' do
    it 'populates nodeAffinity rules for all Deployments' do
      t = HelmTemplate.new(overridden_values)
      expect(t.exit_code).to eq(0)

      deployments = t.resources_by_kind('Deployment').select { |key, _| supported_node_affinity_deployments.include? key }

      deployments.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity')).to be_present
      end
    end
  end

  context 'when overriding antiAffinity' do
    it 'applies to all Deployments' do
      t = HelmTemplate.new(overridden_values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      deployments = t.resources_by_kind('Deployment').reject { |key, _| ignored_deployments.include? key }

      deployments.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'requiredDuringSchedulingIgnoredDuringExecution')).to be_present
      end
    end
  end
end

describe 'local affinity configuration' do
  let(:supported_node_affinity_deployments) do
    SUPPORTED_NODE_AFFINITY_DEPLOYMENTS
  end

  let(:ignored_deployments) do
    IGNORED_DEPLOYMENTS
  end

  let(:values_with_override) do
    HelmTemplate.with_defaults(%(
      global:
        nodeAffinity: "hard"
        antiAffinity: "soft"
        affinity:
          nodeAffinity:
            key: "test.com/zone"
            values:
            - us-east1-a
            - us-east1-b
          podAntiAffinity:
            topologyKey: "test.com/hostname"
      registry:
        nodeAffinity: "soft"
        antiAffinity: "hard"
        affinity:
          nodeAffinity:
            key: "override.com/zone"
          podAntiAffinity:
            topologyKey: "override.com/hostname"
    ))
  end

  context 'when setting a local antiAffinity override' do
    it 'applies to a single Deployment' do
      t = HelmTemplate.new(values_with_override)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      deployments = t.resources_by_kind('Deployment').reject { |key, _| ignored_deployments.include? key }

      deployments.each do |key, _|
        if key == 'Deployment/test-registry'
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'requiredDuringSchedulingIgnoredDuringExecution')).to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')).not_to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'requiredDuringSchedulingIgnoredDuringExecution')[0]['topologyKey']).to eq('override.com/hostname')
        else
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')).to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'requiredDuringSchedulingIgnoredDuringExecution')).not_to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'podAntiAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')[0]['podAffinityTerm']['topologyKey']).to eq('test.com/hostname')
        end
      end
    end
  end

  context 'when setting a local nodeAffinity override' do
    it 'applies to a single Deployment' do
      t = HelmTemplate.new(values_with_override)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      deployments = t.resources_by_kind('Deployment').select { |key, _| supported_node_affinity_deployments.include? key }

      deployments.each do |key, _|
        if key == 'Deployment/test-registry'
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')).to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity', 'requiredDuringSchedulingIgnoredDuringExecution')).not_to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')[0]['nodeSelectorTerms'][0]['matchExpressions'][0]['key']).to eq('override.com/zone')
        else
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity', 'requiredDuringSchedulingIgnoredDuringExecution')).to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity', 'preferredDuringSchedulingIgnoredDuringExecution')).not_to be_present
          expect(t.dig(key, 'spec', 'template', 'spec', 'affinity', 'nodeAffinity', 'requiredDuringSchedulingIgnoredDuringExecution')['nodeSelectorTerms'][0]['matchExpressions'][0]['key']).to eq('test.com/zone')
        end
      end
    end
  end
end
