require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'GitLab KEDA configuration(s)' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  let(:scaledobject_names) do
    %w[
      test-gitlab-shell
      test-gitlab-pages
      test-kas
      test-mailroom
      test-sidekiq-all-in-1-v2
      test-webservice-default
      test-spamcheck
      test-registry
    ]
  end

  let(:enable_all_scaleobjects) do
    default_values.deep_merge(YAML.safe_load(%(
      global:
        appConfig:
          incomingEmail:
            enabled: true
            password:
              secret: foo
        kas:
          enabled: true
        keda:
          enabled: true
        pages:
          enabled: true
        spamcheck:
          enabled: true
      gitlab:
        gitlab-shell:
          hpa:
            cpu:
              targetType: AverageValue
              targetAverageValue: 100m
            behavior:
              scaleDown:
                stabilizationWindowSeconds: 300
          resources:
            requests:
              cpu: 1
        gitlab-pages:
          hpa:
            cpu:
              targetType: AverageValue
              targetAverageValue: 100m
            behavior:
              scaleDown:
                stabilizationWindowSeconds: 300
        kas:
          hpa:
            cpu:
              targetType: AverageValue
              targetAverageValue: 100m
            behavior:
              scaleDown:
                stabilizationWindowSeconds: 300
        mailroom:
          hpa:
            cpu:
              targetType: AverageValue
              targetAverageValue: 100m
            behavior:
              scaleDown:
                stabilizationWindowSeconds: 300
        sidekiq:
          hpa:
            cpu:
              targetType: AverageValue
              targetAverageValue: 100m
            behavior:
              scaleDown:
                stabilizationWindowSeconds: 300
        spamcheck:
          hpa:
            cpu:
              targetType: AverageValue
              targetAverageValue: 100m
            behavior:
              scaleDown:
                stabilizationWindowSeconds: 300
        webservice:
          hpa:
            cpu:
              targetType: AverageValue
              targetAverageValue: 100m
            behavior:
              scaleDown:
                stabilizationWindowSeconds: 300
      registry:
        enabled: true
        hpa:
          cpu:
            targetType: AverageValue
            targetAverageValue: 100m
          behavior:
            scaleDown:
              stabilizationWindowSeconds: 300
    )))
  end

  it 'All KEDA ScaledObjects are tested' do
    template = HelmTemplate.new(enable_all_scaleobjects)
    expect(template.exit_code).to eq(0)

    all_scaledobjects = template.resources_by_kind("ScaledObject").keys
    all_scaledobjects.map! { |item| item.split('/')[1] }
    expect(all_scaledobjects).to match_array(scaledobject_names)
  end

  it 'No HPAs are created' do
    template = HelmTemplate.new(enable_all_scaleobjects)
    expect(template.exit_code).to eq(0)

    all_hpas = template.resources_by_kind("HorizontalPodAutoscaler").keys
    expect(all_hpas).to be_empty
  end
end
