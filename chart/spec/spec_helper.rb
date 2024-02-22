require 'aws-sdk-s3'
require 'open-uri'
require 'open3'
require 'api_helper'
require 'capybara/rspec'
require 'rspec/retry'
require 'gitlab_test_helper'
require 'rspec-parameterized'
require 'pry'

include Gitlab::TestHelper

RSpec.configure do |config|
  config.include Capybara::DSL
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.example_status_persistence_file_path = './spec/examples.txt' unless ENV['CI']

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.define_derived_metadata(file_path: %r{/spec/features/}) do |metadata|
    metadata[:type] = :feature
  end

  # show retry status in spec process
  config.verbose_retry = true

  config.around :each, :feature do |example|
    example.run_with_retry retry: 2
  end

  # enable the use of :focus to run a subset of specs
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # disable spec test requiring access to k8s cluster
  k8s_access = system('kubectl --request-timeout 1s get nodes >/dev/null 2>&1')
  unless k8s_access
    puts 'Excluding specs that require access to k8s cluster'
    config.filter_run_excluding :type => 'feature'
  end
end

private

def ci?
  ENV['CI'] || ENV['CI_SERVER']
end
