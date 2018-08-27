require 'pdqtest/util'
require 'pdqtest/puppet'

module PDQTest
  module Docker
    OUT = 0
    ERR = 1
    STATUS = 2
    ENV='export TERM=xterm LC_ALL=C PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin:$PATH;'
    IMAGES = {
     :DEFAULT => 'declarativesystems/pdqtest-centos:2018-05-31-0',
     :UBUNTU  => 'declarativesystems/pdqtest-ubuntu:2018-05-31-0',
    }
    HIERA_YAML_CONTAINER = '/etc/puppetlabs/puppet/hiera.yaml'
    HIERA_YAML_HOST = '/spec/fixtures/hiera.yaml'
    HIERA_DIR  = '/spec/fixtures/hieradata'
    YUM_CACHE_CONTAINER = "/var/cache/yum"
    YUM_CACHE_HOST    = "#{Util::app_dir_expanded}/cache/yum"

    def self.wrap_cmd(cmd)
      ['bash',  '-c', "#{ENV} #{cmd}"]
    end

    def self.exec(container, cmd)
      container.exec(wrap_cmd(cmd), tty: true)
    end

    # detect the image to use based on metadata.json
    def self.acceptance_test_images()
      supported_images = []
      os_hash = Puppet::module_metadata['operatingsystem_support'] || {}
      # returns a hash that looks like this (if non-empty):
      # [
      #   {
      #     "operatingsystem": "RedHat",
      #     "operatingsystemrelease": [
      #         "6",
      #         "7"
      #     ]
      #   },
      # ]
      # We will map this list of OSs to the simple list of docker images we
      # supply
      if os_hash.size == 0
        # Always support the default test system if no metadata present
        supported_images << IMAGES[:DEFAULT]
      else
        os_hash.each { |os|
          case os["operatingsystem"].downcase
            when "ubuntu"
              supported_images << IMAGES[:UBUNTU]
            when "windows"
              Escort::Logger.output.puts "Windows acceptance testing not supported yet... any ideas?"
            else
              supported_images << IMAGES[:DEFAULT]
          end
        }
      end

      supported_images.uniq
    end

    def self.new_container(test_dir, image_name, privileged)
      pwd = Dir.pwd
      hiera_yaml_host = File.join(pwd, HIERA_YAML_HOST)
      hiera_dir = File.join(pwd, HIERA_DIR)

      # security options seem required on OSX to allow SYS_ADMIN capability to
      # work - without this container starts fine with no errors but the CAP is
      # missing from the inspect output and all systemd commands fail with errors
      # about dbus
      security_opt =
        if (/darwin/ =~ RUBY_PLATFORM) != nil
          ["seccomp:unconfined"]
        else
          []
        end

      if ! Dir.exists?(YUM_CACHE_HOST)
        FileUtils.mkdir_p(YUM_CACHE_HOST)
      end

      # hiera.yaml *must* exist on the host or we will get errors from Docker
      if ! File.exists?(hiera_yaml_host)
        File.write(hiera_yaml_host, '# hiera configuration for testing')
      end
      container = ::Docker::Container.create(
        'Image'   => image_name,
        'Volumes' => {
          test_dir              => {pwd               => 'rw'},
          HIERA_YAML_CONTAINER  => {hiera_yaml_host   => 'rw'},
          HIERA_DIR             => {hiera_dir         => 'rw'},
          '/sys/fs/cgroup'      => {'/sys/fs/cgroup'  => 'ro'},
          YUM_CACHE_CONTAINER   => {YUM_CACHE_HOST    => 'rw'},
        },
        'HostConfig' => {
          "SecurityOpt" => security_opt,
          "Binds": [
            "/sys/fs/cgroup:/sys/fs/cgroup:ro",
            "#{pwd}:#{test_dir}:rw",
            "#{hiera_yaml_host}:#{HIERA_YAML_CONTAINER}:rw",
            "#{hiera_dir}:#{HIERA_DIR}:rw",
            "#{YUM_CACHE_HOST}:#{YUM_CACHE_CONTAINER}:rw",
          ],
        },
      )
      container.start(
        {
          #'Binds' => [ pwd +':'+ test_dir,],
          'HostConfig' => {
            'Tmpfs': {
              '/run'      => '',
              '/run/lock' => '',
            },
            CapAdd: [ 'SYS_ADMIN'],
            Privileged: privileged,
          },
        }
      )

      container
    end

    def self.cleanup_container(container)
      container.stop
      container.delete(:force => true)
    end

    def self.exec_status(res, puppet=false)
      if puppet
        # 0 == ok, no changes
        # 2 == ok, changes made
        allowable_values = [0,2]
      else
        allowable_values = [0]
      end
      status = allowable_values.include?(res[STATUS])
    end

    def self.exec_out(res)
      res[OUT]
    end

    def self.exec_err(res)
      res[ERR]
    end

    def self.log_out(res)
      exec_out(res).each { |l|
        # Output comes back as an array and needs to be iterated or we lose our
        # ansi formatting
        Escort::Logger.output << l
      }
    end

    def self.log_all(res)
      log_err(res)
      log_out(res)
    end

    def self.log_err(res)
      exec_err(res).each { |l|
        # Output comes back as an array and needs to be iterated or we lose our
        # ansi formatting
        Escort::Logger.error << l
      }
    end

  end
end
