require 'rest-client'
require 'json'

module ApiHelper
  BASE_URL = "https://#{ENV['GITLAB_URL']}/api/v4/".freeze
  def self.invoke_get_request(uri)
    default_args = {
      method: :get,
      url: "#{BASE_URL}#{uri}",
      verify_ssl: true,
      headers: {
        "Authorization" => "Bearer #{ENV['GITLAB_ADMIN_TOKEN']}"
      }
    }
    response = RestClient::Request.execute(default_args)
    JSON.parse(response.body)
  end
end
