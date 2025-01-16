require 'spec_helper'
require 'open-uri'
require 'cgi'

class TestProjectHelper
  def initialize
    timestamp = Time.now.utc.strftime('%Y-%m-%d-%H-%M-%S')
    @test_project = "testproject-#{timestamp}"
    @test_project_group = "root"
    @test_issue = "test-#{timestamp}"
    @test_image = "#{registry_url}/#{@test_project_group}/#{@test_project}/test:#{timestamp}"
    @source_image = "gcr.io/distroless/static-debian12@sha256:f4a57e8ffd7ba407bdd0eb315bb54ef1f21a2100a7f032e9102e4da34fe7c196"
  end

  def create_test_project
    ApiHelper.invoke_post_request("projects", { "path": @test_project, "initialize_with_readme": true })
  end

  def get_test_project
    ApiHelper.invoke_get_request("projects/#{encoded_project_path}")
  end

  def get_test_project_tree
    ApiHelper.invoke_get_request("projects/#{encoded_project_path}/repository/tree")
  end

  def delete_test_project
    ApiHelper.invoke_delete_request("projects/#{encoded_project_path}")
  end

  def commit_dockerfile
    ApiHelper.invoke_post_request(
      "projects/#{encoded_project_path}/repository/commits",
      {
        "branch": "main",
        "commit_message": "Test Dockerfile",
        "actions": [
          {
            "action": "create",
            "file_path": "Dockerfile",
            "content": "I am a Dockerfile"
          }
        ]
      }
    )
  end

  def create_test_issue
    raise "Test issue was already created" if @test_issue_id

    response = ApiHelper.invoke_post_request("projects/#{encoded_project_path}/issues?title=TestIssue")
    @test_issue_id = response['iid']
    response
  end

  def get_test_issue
    raise "Test issue was not created yet" unless @test_issue_id

    ApiHelper.invoke_get_request("/projects/#{encoded_project_path}/issues/#{@test_issue_id}")
  end

  def upload_test_container_image
    stdout, status = Open3.capture2e("docker login #{registry_url} --username root --password #{ENV['GITLAB_PASSWORD']}")
    raise stdout unless status.success?

    stdout, status = Open3.capture2e("docker pull #{@source_image}")
    raise stdout unless status.success?

    stdout, status = Open3.capture2e("docker tag #{@source_image} #{@test_image}")
    raise stdout unless status.success?

    stdout, status = Open3.capture2e("docker push #{@test_image}")
    raise stdout unless status.success?
  end

  def pull_test_container_image
    stdout, status = Open3.capture2e("docker login #{registry_url} --username root --password #{ENV['GITLAB_PASSWORD']}")
    raise stdout unless status.success?

    stdout, status = Open3.capture2e("docker image rm #{@test_image} #{@source_image} || true")
    raise stdout unless status.success?

    stdout, status = Open3.capture2e("docker pull #{@test_image}")
    raise stdout unless status.success?
  end

  private

  def encoded_project_path
    CGI.escape("#{@test_project_group}/#{@test_project}")
  end
end
