require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'NGINX configuration(s)' do
  let(:values) do
    HelmTemplate.with_defaults(%(
        nginx-ingress:
          controller:
            kind: #{kind}
            service:
              enableShell: #{enable_shell}
      ))
  end

  let(:template) { HelmTemplate.new(values) }
  let(:workload_name) { 'test-nginx-ingress-controller' }

  let(:container_ports) do
    template.dig("#{kind}/#{workload_name}", 'spec', 'template', 'spec', 'containers', 0, 'ports').map { |p| p['name'] }
  end

  let(:container_args) do
    template.dig("#{kind}/#{workload_name}", 'spec', 'template', 'spec', 'containers', 0, 'args')
  end

  shared_examples 'GitLab shell enabled' do
    it 'exposes the ports' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      expect(container_ports).to match_array(%w[http https metrics gitlab-shell])
    end

    it 'configures the tcp configmap' do
      expect(container_args).to include('--tcp-services-configmap=default/test-nginx-ingress-tcp')
    end
  end

  shared_examples 'GitLab shell disabled' do
    let(:enable_shell) { false }

    it 'exposes no Shell port' do
      expect(container_ports).not_to include('gitlab-shell')
    end

    it 'configures no tcp configmap' do
      expect(container_args).not_to include('--tcp-services-configmap=default/test-nginx-ingress-tcp')
    end
  end

  context 'DaemonSet' do
    let(:kind) { 'DaemonSet' }

    it_behaves_like "GitLab shell enabled" do
      let(:enable_shell) { true }
    end

    it_behaves_like "GitLab shell disabled" do
      let(:enable_shell) { false }
    end
  end

  context 'Deployment' do
    let(:kind) { 'Deployment' }

    it_behaves_like "GitLab shell enabled" do
      let(:enable_shell) { true }
    end

    it_behaves_like "GitLab shell disabled" do
      let(:enable_shell) { false }
    end
  end
end
