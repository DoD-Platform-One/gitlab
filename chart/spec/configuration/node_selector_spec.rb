# frozen_string_literal: true

require 'spec_helper'
require 'helm_template_helper'
require 'yaml'

describe 'Node Selector configuration' do
  let(:default_values) do
    {
      'global' => {
        # the values we test for presence of NodeSelectors across components
        'nodeSelector' => { 'region' => 'us-central-1a' },

        # PLEASE UPDATE AS NEW COMPONENTS ARE ADDED (unless they are enabled by default)
        'gitlab' => {
          'kas' => { 'enabled' => 'true' }, # DELETE THIS WHEN KAS BECOMES ENABLED BY DEFAULT
          'pages' => { 'enabled' => 'true' },
          'praefect' => { 'enabled' => 'true' }
        },

        # ensures inclusion of:
        # - shared-secrets/templates/_self-signed-cert-job.yml
        'ingress' => {
          'configureCertmanager' => 'false'
        },

        # ensures inclusion of:
        # - gitlab/charts/webservice/templates/pause_job.yaml
        # - gitlab/charts/sidekiq/templates/pause_job.yaml
        # - gitlab/charts/gitaly/templates/pause_job.yaml
        # - gitlab/charts/operator/templates/deployment.yaml
        'operator' => {
          'enabled' => 'true',
          'rollout' => { 'autoPause' => 'true' }
        }
      },

      # ensures inclusion of:
      # - nginx-ingress/templates/admission-webhooks/job-patch/job-createSecret.yaml
      # - nginx-ingress/templates/admission-webhooks/job-patch/job-patchWebhook.yaml
      'nginx-ingress' => {
        'admissionWebhooks' => {
          'enabled' => 'true',
          'patch' => { 'enabled' => 'true' }
        }
      },

      'certmanager-issuer' => { 'email' => 'test@example.com' }
    }
  end

  let(:ignored_charts) do
    [
      'Deployment/test-cainjector',
      'Deployment/test-cert-manager',
      'Deployment/test-gitlab-runner',
      'Deployment/test-prometheus-server',
      'StatefulSet/test-postgresql',
      'StatefulSet/test-redis-master'
    ]
  end

  context 'When setting global nodeSelector' do
    it 'Populates nodeSelector for all resources' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)

      resources = [
        *t.resources_by_kind('Deployment'),
        *t.resources_by_kind('DaemonSet'),
        *t.resources_by_kind('StatefulSet'),
        *t.resources_by_kind('Job')
      ]
      .to_h.reject { |key, _| ignored_charts.include? key }

      resources.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'spec', 'nodeSelector')).to include(default_values['global']['nodeSelector']), key
      end
    end
  end
end
