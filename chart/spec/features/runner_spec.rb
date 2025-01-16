require 'spec_helper'
require 'open-uri'

describe 'Runner registration' do
  before(:all) do
    enable_legacy_runner_registration
    set_admin_token
    wait_for_runner_contact
  end

  it 'Should have at least 1 runner registered' do
    uri = "runners/all"
    response = ApiHelper.invoke_get_request(uri)
    expect(response.collect { |item| item["status"] }).to have_content('online', minimum: 1)
  end
end
