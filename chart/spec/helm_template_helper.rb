require 'yaml'
require 'open3'

class HelmTemplate
  @_helm_major_version = nil
  @_helm_minor_version = nil

  def self.helm_major_version
    if @_helm_major_version.nil?
      parts = `helm version -c`.match('Ver(sion)?:"v(\d)\.(\d+)(?:\.(\d+))?')
      @_helm_major_version = parts[2].to_i
      @_helm_minor_version = parts[3].to_i
      @_helm_patch_version = parts[4].to_i

      # Check for Helm version below minimum supported version
      if @_helm_major_version < 3 || (@_helm_major_version == 3 && @_helm_minor_version < 9 && @_helm_patch_version < 4)
        puts "ERROR: Helm version needs to be greater than 3.9.4"
        exit(1)
      end
    end

    @_helm_major_version
  end

  def self.helm_minor_version
    @_helm_minor_version
  end

  def self.helm_template_call(release_name: 'test', path: '-', namespace: nil, extra_args: nil)
    namespace_arg = namespace.nil? ? '' : "--namespace #{namespace}"

    case helm_major_version
    when 3 then
      "helm template #{release_name} . -f #{path} #{namespace_arg} #{extra_args}"
    else
      # If we don't know the version of Helm, use `false` command
      "false"
    end
  end

  # This is the most common "default" as it is a hard requirement within defaults.
  def self.certmanager_issuer
    { "certmanager-issuer" => { "email" => "test@example.com" } }
  end

  # The final defaults stubs the stable version so that the spec values are dependent on which branch
  # the tests are running on, since on stable versions will have a semVer value, while the default branch
  # will have `master`.
  def self.defaults
    HelmTemplate.certmanager_issuer.deep_merge!({ 'global' => { 'gitlabVersion' => "v42.0.0" } })
  end

  def self.with_defaults(yaml)
    yaml ||= {}
    hash = yaml.is_a?(Hash) ? yaml : YAML.safe_load(yaml)
    HelmTemplate.defaults.deep_merge!(hash)
  end

  attr_reader :mapped

  def initialize(values, release_name = 'test', extra_args = '')
    template(values, release_name, extra_args)
  end

  def namespace
    stdout, stderr, exit_code = Open3.capture3("kubectl config view --minify --output 'jsonpath={..namespace}'")

    return 'default' unless exit_code != 0

    stdout.strip
  end

  def template(values, release_name = 'test', extra_args = '')
    @values  = values
    result = Open3.capture3(self.class.helm_template_call(namespace: 'default', release_name: release_name, extra_args: extra_args),
                            chdir: File.join(__dir__,  '..'),
                            stdin_data: YAML.dump(values))
    @stdout, @stderr, @exit_code = result
    # handle common failures when helm or chart not setup properly
    case @exit_code
    when 256
      fail "Chart dependencies not installed, run 'helm dependency update'" if @stderr.include? 'found in Chart.yaml, but missing in charts/ directory'
    end

    # load the complete output's YAML documents into an array
    yaml = YAML.load_stream(@stdout)
    # filter out any empty YAML documents (nil)
    yaml.select!{ |x| !x.nil? }
    # create an indexed Hash keyed on Kind/metdata.name
    @mapped = yaml.to_h  { |doc|
      [ "#{doc['kind']}/#{doc['metadata']['name']}" , doc ]
    }
  end

  def [](arg)
    dig(arg)
  end

  def dig(*args)
    @mapped.dig(*args)
  end

  def resource_exists?(item)
    @mapped.has_key?(item)
  end

  def volumes(item)
    @mapped.dig(item,'spec','template','spec','volumes')
  end

  def labels(item)
    @mapped.dig(item,'metadata','labels')
  end

  def template_labels(item)
    # only one of the following should return results
    @mapped.dig(item, 'spec', 'template', 'metadata', 'labels') ||
      @mapped.dig(item, 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'labels')
  end

  def annotations(item)
    @mapped.dig(item, 'metadata', 'annotations')
  end

  def template_annotations(item)
    # only one of the following should return results
    @mapped.dig(item, 'spec', 'template', 'metadata', 'annotations') ||
      @mapped.dig(item, 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'annotations')
  end

  def find_volume(item, volume_name)
    volumes = volumes(item)
    volumes.keep_if { |volume| volume['name'] == volume_name }
    volumes[0]
  end

  def get_projected_secret(item, mount, secret)
    # locate first instance of projected secret by name
    secrets = find_volume(item,mount)

    secrets['projected']['sources'].each do |s|
      return s['secret'] if s.has_key?('secret') && s['secret'].has_key?('name') && s['secret']['name'] == secret
    end

    nil
  end

  def find_projected_secret(item, mount, secret)
    secret = get_projected_secret(item,mount,secret)
    !secret.nil?
  end

  def find_projected_secret_key(item, mount, secret, key)
    secret = get_projected_secret(item,mount,secret)

    result = nil

    if secret&.has_key?('items')

      secret['items'].each do |i|
        if i['key'] == key
          result = i
          break
        end
      end

    end

    result
  end

  def find_volume_mount(item, container_name, volume_name, init = false)
    find_container(item, container_name, init)
      &.dig('volumeMounts')
      &.find { |volume| volume['name'] == volume_name }
  end

  def find_container(item, container_name, init = false)
    containers = init ? 'initContainers' : 'containers'

    dig(item, 'spec', 'template', 'spec', containers)
      &.find { |container| container['name'] == container_name }
  end

  def find_image(item, container_name, init = false)
    find_container(item, container_name, init)
      &.dig('image')
  end

  def env(item, container_name, init = false)
    find_container(item, container_name, init)
      &.dig('env')
  end

  def projected_volume_sources(item,volume_name)
    find_volume(item,volume_name)
      &.dig('projected','sources')
  end

  def resources_by_kind(kind)
    @mapped.select{ |_, hash| hash['kind'] == kind }
  end

  def exit_code()
    @exit_code.to_i
  end

  def stderr()
    @stderr
  end

  def values()
    @values
  end
end
