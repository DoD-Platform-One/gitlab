require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'NGINX configuration(s)' do
  def get_ports(template, kind, name)
    template.dig("#{kind}/#{name}", 'spec', 'template', 'spec', 'containers', 0, 'ports')
  end

  def test_exposed_ports(exposed_ports, expected_ports)
    i = 0
    ports_set = Set.new

    while i < expected_ports.length
      ports_set.add(exposed_ports[i]['name'])
      i += 1
    end

    expect(ports_set.length).to eq(expected_ports.length)
    expect(ports_set).to eq(expected_ports)
  end

  def test_deployment_ports(template, deployment_name, expected_ports)
    ports = get_ports(template, 'Deployment', deployment_name)
    test_exposed_ports(ports, expected_ports)
  end

  def test_daemonset_ports(template, daemonset_name, expected_ports)
    ports = get_ports(template, 'DaemonSet', daemonset_name)
    test_exposed_ports(ports, expected_ports)
  end

  def get_args(template, kind, name)
    template.dig("#{kind}/#{name}", 'spec', 'template', 'spec', 'containers', 0, 'args')
  end

  describe 'nginx gitlab shell toggles' do
    let(:object_name) do
      'test-nginx-ingress-controller'
    end

    let(:default_values) do
      HelmTemplate.defaults
    end

    let(:nginx_enable_daemonset) do
      default_values.deep_merge(YAML.safe_load(%(
        nginx-ingress:
          controller:
            kind: Both
      )))
    end

    let(:gitlab_shell_disabled) do
      nginx_enable_daemonset.deep_merge(YAML.safe_load(%(
        nginx-ingress:
          controller:
            service:
              enableShell: false
      )))
    end

    let(:tcp_configmap_name) do
      '--tcp-services-configmap=default/test-nginx-ingress-tcp'
    end

    context 'with the defaults' do
      let(:template) { HelmTemplate.new(nginx_enable_daemonset) }

      it 'templates successfully' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'has gitlab shell port enabled on the nginx deployment and daemonset' do
        expected_ports = Set['http', 'https', 'metrics', 'gitlab-shell']

        test_deployment_ports(template, object_name, expected_ports)
        test_daemonset_ports(template, object_name, expected_ports)
      end

      it 'configures the TCP services ConfigMap argument for the Deployment and Daemonset' do
        deployment_args = get_args(template, 'Deployment', object_name)
        expect(deployment_args).to include(tcp_configmap_name)

        daemonset_args = get_args(template, 'DaemonSet', object_name)
        expect(daemonset_args).to include(tcp_configmap_name)
      end
    end

    context 'with gitlab shell disabled' do
      let(:template) { HelmTemplate.new(gitlab_shell_disabled) }

      it 'templates successfully' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'does not have gitlab shell port enabled on the nginx deployment or daemonset' do
        expected_ports = Set['http', 'https', 'metrics']

        test_deployment_ports(template, object_name, expected_ports)
        test_daemonset_ports(template, object_name, expected_ports)
      end

      it 'does not configure the TCP services ConfigMap argument for the Deployment or DaemonSet' do
        deployment_args = get_args(template, 'Deployment', object_name)
        expect(deployment_args).not_to include(tcp_configmap_name)

        daemonset_args = get_args(template, 'DaemonSet', object_name)
        expect(daemonset_args).not_to include(tcp_configmap_name)
      end
    end
  end
end
