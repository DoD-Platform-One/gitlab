require 'erb'
require 'fileutils'
require 'securerandom'
require 'open3'
# needed inside of ERB
require 'yaml'
require 'json'

class RuntimeTemplate
  def self.gomplate(raw_template:, files: {}, env: {})
    Dir.mktmpdir do |tmpdir|
      raw_template = create_template_files(raw_template, files, tmpdir)

      # write out the gomplate template
      input_file = File.join(tmpdir, 'input.tpl')
      File.write(input_file, raw_template)

      # render the gomplate
      cmd = "gomplate --left-delim '{%' --right-delim '%}' --file #{input_file}"
      result = Open3.capture3(env, cmd)
      stdout, stderr, exit_code = result

      raise "Unable to call gomplate: #{stderr}" if exit_code != 0

      # return the stdout, client parses as needed
      stdout
    end
  end

  def self.erb(raw_template:, files: {}, env: {})
    Dir.mktmpdir do |tmpdir|
      raw_template = create_template_files(raw_template, files, tmpdir)

      # swap out the ENV
      env.each do |key, value|
        # swap out `ENV[""]` for `"#{value}"` (quoted string!)
        raw_template.gsub!(%(ENV["#{key}"]), %("#{value}"))
      end

      # load the ERB template
      erb = ERB.new(raw_template)

      # render (and return) the ERB
      erb.result
    end
  end

  # raw_template is passed through the function, explicitly due to the `gsub`
  # updating exact paths within the template contents.
  private_class_method def self.create_template_files(raw_template, files, tmpdir)
    files.each do |file, content|
      tmp_file =  File.join(tmpdir, file)
      # substitute the filename
      raw_template.gsub!(file, tmp_file)
      # make the containing directory
      FileUtils.mkdir_p(File.dirname(tmp_file))
      # write the content
      File.write(tmp_file, content)
    end

    # return the raw template, now that file paths are replaced.
    raw_template
  end

  JUNK_PASSWORD = 'somthing^&question@ble'.freeze
  JUNK_TOKEN = SecureRandom.hex.freeze

  # Files mocked, based on `gitlab.yml.erb`
  # use of `File.read`, `File.exists?`, `YAML.load_file`
  def self.mock_files(path = '/etc/gitlab')
    {
      "#{path}/postgres/psql-password-main" => JUNK_PASSWORD,
      "#{path}/postgres/psql-password-ci" => JUNK_PASSWORD,
      "#{path}/redis/redis-password" => JUNK_PASSWORD,
      "#{path}/gitaly/gitaly_token" => JUNK_TOKEN,
      # registry notification has a special format ...
      "#{path}/registry/notificationSecret" => "[#{JUNK_TOKEN}]",
      # minio
      "#{path}/minio/accesskey" => JUNK_TOKEN,
      "#{path}/minio/secretkey" => JUNK_TOKEN
    }
  end
end
