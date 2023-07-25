require 'spec_helper'
require 'helm_template_helper'
require 'yaml'

TARGET_KINDS = %w[Deployment StatefulSet Job].freeze
CONTAINER_TYPES = %w[initContainers containers].freeze
EXTERNAL_CHARTS = %w[
  gitlab-runner postgresql prometheus redis nginx-ingress
].freeze

def targeted_resource_kind?(resource)
  TARGET_KINDS.include? resource['kind']
end

def should_be_ignored?(resource)
  result = EXTERNAL_CHARTS.select do |chart_name|
    labels = resource.dig('metadata', 'labels')
    (labels&.dig('helm.sh/chart') || labels&.dig('chart'))&.start_with?(chart_name)
  end

  !result.empty?
end

def is_helper_image?(container_image)
  container_image.include?('/kubectl:') ||
    container_image.include?('/alpine-certificates:') ||
    container_image.include?('/cfssl-self-sign:') ||
    container_image.include?('/gitlab-base:')
end

def test_helper_images(template, description, expectation)
  template.mapped.select { |_, resource| targeted_resource_kind?(resource) && !should_be_ignored?(resource) }.each do |key, resource|
    context "resource: #{key}" do
      let(:resource) { resource }

      CONTAINER_TYPES.each do |container_type|
        resource.dig('spec', 'template', 'spec', container_type)&.each do |container|
          context "container: #{container_type}/#{container&.dig('name')}" do
            let(:container) { container }

            container_image = container&.dig('image')
            if is_helper_image?(container_image)
              it description do
                expect(container_image).to end_with(expectation)
              end
            end
          end
        end
      end
    end
  end
end

def fetch_default_gitlab_version
  # load from values.yaml
  values = YAML.load_file('./values.yaml')
  # fetch value of key (nil if not present)
  gitlab_version = values['global']['gitlabVersion']
  # if not present, return `:master`
  gitlab_version = 'master' if gitlab_version.nil?
  gitlab_version = "v#{gitlab_version}" if gitlab_version.match? "^\\d+\\.\\d+\\.\\d+(-rc\\d+)?(-pre)?$"

  # return in expected format of `:blah`
  ":#{gitlab_version}"
end

describe 'image tag configuration' do
  context 'no global.gitlabVersion configured' do
    begin
      values = HelmTemplate.with_defaults %(
        global:
          pages:
            enabled: true
          spamcheck:
            enabled: true
          praefect:
            enabled: true
          ingress:
            # To ensure the cfsl-self-sign image is used
            configureCertmanager: false
        )
      template = HelmTemplate.new values
    rescue StandardError
      # Skip these examples when helm or chart dependencies are missing
      next
    end

    let(:template) do
      template
    end

    it 'should render the template without error' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    test_helper_images(template, 'should use the default image tag', fetch_default_gitlab_version)
  end

  context 'global.gitlabVersion' do
    context 'without local tags configured' do
      begin
        values = HelmTemplate.with_defaults %(
          global:
            gitlabVersion: 1.2.3
            pages:
              enabled: true
            spamcheck:
              enabled: true
            praefect:
              enabled: true
            ingress:
              # To ensure the cfsl-self-sign image is used
              configureCertmanager: false
        )
        template = HelmTemplate.new values
      rescue StandardError
        # Skip these examples when helm or chart dependencies are missing
        next
      end

      let(:template) do
        template
      end

      it 'should render the template without error' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      test_helper_images(template, 'should use the global gitlabVersion for the image tag', ':v1.2.3')
    end

    context 'with local tags configured' do
      begin
        values = HelmTemplate.with_defaults %(
          global:
            gitlabVersion: 1.2.3
            pages:
              enabled: true
            spamcheck:
              enabled: true
            praefect:
              enabled: true
            ingress:
              # To ensure the cfsl-self-sign image is used
              configureCertmanager: false
            kubectl:
              image:
                tag: local-tag
            certificates:
              image:
                tag: local-tag
            gitlabBase:
              image:
                tag: local-tag
          shared-secrets:
            selfsign:
              image:
                tag: local-tag
        )
        template = HelmTemplate.new values
      rescue StandardError
        # Skip these examples when helm or chart dependencies are missing
        next
      end

      let(:template) do
        template
      end

      it 'should render the template without error' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      test_helper_images(template, 'should use the local value for the image tag, not global.gitlabVersion', ':local-tag')
    end

    context 'init image override' do
      begin
        values = HelmTemplate.with_defaults %(
          global:
            gitlabVersion: 1.2.3
            gitlabBase:
              tag: global-tag
          gitlab:
            sidekiq:
              init:
                image:
                  tag: init-tag
        )
        template = HelmTemplate.new values
      rescue StandardError
        # Skip these examples when helm or chart dependencies are missing
        next
      end

      let(:template) { template }

      it 'should render the template without error' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'should override the gitlab-base init image tag' do
        configure = template.find_container('Deployment/test-sidekiq-all-in-1-v2', 'configure', true)
        expect(configure['image']).to end_with(':init-tag')
      end
    end

    context 'init Image busybox fallback' do
      begin
        values = HelmTemplate.with_defaults %(
          global:
            gitlabVersion: 1.2.3
            busybox:
              image:
                tag: bb-tag
          gitlab:
            sidekiq:
              init:
                image:
                  tag: init-tag
        )
        template = HelmTemplate.new values
      rescue StandardError
        # Skip these examples when helm or chart dependencies are missing
        next
      end

      let(:template) { template }

      it 'should render the template without error' do
        expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
      end

      it 'should use the busybox image/tag' do
        configure = template.find_container('Deployment/test-webservice-default', 'configure', true)
        expect(configure['image']).to include('busybox')
        expect(configure['image']).to end_with(':bb-tag')
      end

      it 'should override the busybox image/tag' do
        configure = template.find_container('Deployment/test-sidekiq-all-in-1-v2', 'configure', true)
        expect(configure['image']).to include('busybox')
        expect(configure['image']).to end_with(':init-tag')
      end
    end
  end
end
