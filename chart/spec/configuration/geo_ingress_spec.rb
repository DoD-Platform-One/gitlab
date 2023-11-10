require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Geo NGINX controller' do
  let(:values) { HelmTemplate.defaults }
  let(:template) { HelmTemplate.new(values) }
  let(:default_ingress) { template['Ingress/test-webservice-default'] }
  let(:external_ingress) { default_ingress }
  let(:internal_ingress) { template['Ingress/test-webservice-default-extra'] }
  let(:geo_nginx_class) { 'test-nginx-geo' }
  let(:default_controller_service) { template['Service/test-nginx-ingress-controller'] }
  let(:geo_controller_service) { template['Service/test-nginx-ingress-geo-controller'] }

  shared_examples 'a valid template' do
    it 'renders the template' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end
  end

  describe 'is disabled' do
    it_should_behave_like 'a valid template'

    it 'does not create a internal IngressClass' do
      expect(template["IngressClass/#{geo_nginx_class}"]).to eql(nil)
    end
  end

  describe 'is enabled' do
    let(:values) do
      HelmTemplate.with_defaults(%(
      nginx-ingress-geo:
        enabled: true
      gitlab:
        webservice:
          extraIngress:
            enabled: true
            hostname: gitlab-internal.example.com
            useGeoClass: true
          ingress:
            useGeoClass: true
      global:
        hosts:
          domain: example.com
          hostSuffix: secondary
          gitlab:
            name: gitlab.example.com
          externalIP: 172.0.0.1
          externalGeoIP: 172.0.0.2
      ))
    end
    it_should_behave_like 'a valid template'

    it 'creates the Geo IngressClass' do
      expect(template["IngressClass/#{geo_nginx_class}"]).to_not eql(nil)
    end

    it 'configured the Geo NGINX Ingress controller' do
      use_forwarded_headers = 'use-forwarded-headers'
      cm_geo_nginx = template.dig('ConfigMap/test-nginx-ingress-geo-controller', 'data')
      expect(cm_geo_nginx).to include(use_forwarded_headers => "true")
      cm_nginx = template.dig('ConfigMap/test-nginx-ingress-controller', 'data')
      expect(cm_nginx).not_to include(use_forwarded_headers => "true")

      # drop keys that values are allowed/expected to diverge
      cm_geo_nginx.delete(use_forwarded_headers)
      cm_geo_nginx.delete("add-headers")
      cm_nginx.delete("add-headers")

      expect(cm_geo_nginx["data"]).to eq(cm_nginx["data"])
    end

    it 'configures the internal (extra) Ingress' do
      expect(internal_ingress).to_not eql(nil)
      expect(internal_ingress["spec"]["rules"][0]["host"]).to eql('gitlab-internal.example.com')
      expect(internal_ingress["metadata"]["annotations"]).to include(
        "kubernetes.io/ingress.class" => geo_nginx_class
      )
    end

    it 'configures the external (default) Ingress' do
      expect(external_ingress).to_not eql(nil)
      expect(external_ingress["spec"]["rules"][0]["host"]).to eql('gitlab.example.com')
      expect(external_ingress["metadata"]["annotations"]).to include(
        "kubernetes.io/ingress.class" => geo_nginx_class
      )
    end

    it 'renders the unified hostname to the gitlab.yml' do
      gitlab_yml = template.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb')
      gitlab_yml_hash = YAML.safe_load(gitlab_yml)
      expect(gitlab_yml_hash['production']['gitlab']['host']).to eql('gitlab.example.com')
    end

    it 'renders the static IPs to the load balancer service' do
      expect(default_controller_service['spec']['loadBalancerIP']).to eql('172.0.0.1')
      expect(geo_controller_service['spec']['loadBalancerIP']).to eql('172.0.0.2')
    end
  end
end
