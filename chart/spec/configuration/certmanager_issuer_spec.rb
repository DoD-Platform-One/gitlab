# frozen_string_literal: true

require 'spec_helper'
require 'hash_deep_merge'
require 'helm_template_helper'
require 'yaml'

describe 'certmanager_issuer configuration' do
  let(:default_values) do
    HelmTemplate.defaults
  end

  let(:required_resources) do
    %w[Role RoleBinding ServiceAccount]
  end

  context 'default chart values' do
    it 'creates certmanager_issuer related resources with default values' do
      template = HelmTemplate.new(default_values)

      required_resources.each do |resource|
        resource_name = "#{resource}/test-certmanager-issuer"

        expect(template.resources_by_kind(resource)[resource_name]).to be_present
      end

      jobs = template.resources_by_kind("Job")
      issuer_job = jobs.find { |key, _| key.start_with?("Job/test-issuer-") }.last

      # Expectation for the metadata name prefix
      expect(issuer_job["metadata"]["name"]).to match(/^test-issuer-[a-f0-9]+$/)

      # Expectation for the container image needs to be a regex to work for master and stable branches.
      expect(issuer_job["spec"]["template"]["spec"]["containers"][0]["image"]).to match(%r{^registry\.gitlab\.com/gitlab-org/build/cng/kubectl:(v\d+\.\d+\.\d+|master)$})

      # Expectation for the rest of the structure
      expect(issuer_job).to include(
        "apiVersion" => "batch/v1",
        "kind" => "Job",
        "metadata" => include(
          "namespace" => "default",
          "labels" => {
            "app" => "certmanager-issuer",
            "chart" => "certmanager-issuer-0.2.0",
            "release" => "test",
            "heritage" => "Helm"
          }
        ),
        "spec" => include(
          "activeDeadlineSeconds" => 300,
          "ttlSecondsAfterFinished" => 1800,
          "template" => include(
            "metadata" => { "labels" => { "app" => "certmanager-issuer", "release" => "test" } },
            "spec" => include(
              "securityContext" => { "runAsUser" => 65534, "fsGroup" => 65534, "seccompProfile" => { "type" => "RuntimeDefault" } },
              "serviceAccountName" => "test-certmanager-issuer",
              "restartPolicy" => "OnFailure",
              "containers" => include(
                include(
                  "name" => "create-issuer",
                  "command" => ["/bin/bash", "/scripts/create-issuer", "/scripts/issuer.yml"],
                  "securityContext" => {
                    "allowPrivilegeEscalation" => false,
                    "capabilities" => { "drop" => ["ALL"] },
                    "runAsGroup" => 65534,
                    "runAsNonRoot" => true,
                    "runAsUser" => 65534
                  },
                  "volumeMounts" => [{ "name" => "scripts", "mountPath" => "/scripts" }],
                  "resources" => { "requests" => { "cpu" => "50m" } }
                )
              ),
              "volumes" => [{ "name" => "scripts", "configMap" => { "name" => "test-certmanager-issuer-certmanager" } }]
            )
          )
        )
      )
    end
  end

  context 'when configureCertmanager is disabled' do
    it 'does not create any certmanager_issuer related resource' do
      template = HelmTemplate.new(default_values.deep_merge!(
                                    { 'global' => { 'ingress' => { 'configureCertmanager' => false } } })
                                 )

      required_resources.each do |resource|
        resource_name = "#{resource}/test-certmanager-issuer"

        expect(template.resources_by_kind(resource)[resource_name]).to be_nil
      end

      expect(template.resources_by_kind("Job").keys.select { |k| k.start_with?("Job/test-issuer-") }).to be_empty
    end
  end
end
