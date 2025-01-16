require 'rest-client'
require 'json'

module ApiHelper
  BASE_URL = "https://#{ENV['GITLAB_URL']}/api/v4/".freeze
  def self.invoke_get_request(uri)
    invoke_request(uri, :get)
  end

  def self.invoke_post_request(uri, payload = nil)
    invoke_request(uri, :post, payload)
  end

  def self.invoke_delete_request(uri)
    invoke_request(uri, :delete)
  end

  def self.invoke_request(uri, method, payload = nil)
    default_args = {
      method: method,
      url: "#{BASE_URL}#{uri}",
      verify_ssl: true,
      headers: {
        "Authorization" => "Bearer #{ENV['GITLAB_ADMIN_TOKEN']}"
      },
      payload: payload
    }
    response = RestClient::Request.execute(default_args)
    JSON.parse(response.body)
  end
end
