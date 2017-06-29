module PDQTest
  module Docker
    OUT = 0
    ERR = 1
    STATUS = 2
    ENV='export TERM=xterm LC_ALL=C PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin:$PATH;'
    IMAGE_NAME='geoffwilliams/pdqtest-centos:2017-05-04-0'
    HIERA_YAML_CONTAINER = '/etc/puppetlabs/puppet/hiera.yaml'
    HIERA_YAML_HOST = '/spec/fixtures/hiera.yaml'
    HIERA_DIR  = '/spec/fixtures/hieradata'
    HOST_CACHE_DIR = "#{Dir.home}/.pdqtest"
    YUM_CACHE_HOST = "#{HOST_CACHE_DIR}/yum"
    YUM_CACHE_CONTAINER = "/var/cache/yum"

    def self.wrap_cmd(cmd)
      ['bash',  '-c', "#{ENV} #{cmd}"]
    end

    def self.exec(container, cmd)
      container.exec(wrap_cmd(cmd), tty: true)
    end

    def self.new_container(test_dir)
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
        'Image'   => IMAGE_NAME,
        'Volumes' => {
          test_dir              => {pwd               => 'rw'},
          HIERA_YAML_CONTAINER  => {hiera_yaml_host   => 'rw'},
          HIERA_DIR             => {hiera_dir         => 'rw'},
          '/cut'                => {pwd               => 'rw'}, # DEPRECATED -FOR REMOVAL
          '/sys/fs/cgroup'      => {'/sys/fs/cgroup'  => 'ro'},
          YUM_CACHE_CONTAINER   => {YUM_CACHE_HOST    => 'rw'},
        },
        'HostConfig' => {
          "SecurityOpt" => security_opt,
          "Binds": [
            "/sys/fs/cgroup:/sys/fs/cgroup:ro",
            "#{pwd}:/cut:rw",                               # DEPRECATED -FOR REMOVAL
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
        Escort::Logger.output.puts l
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
        Escort::Logger.error.error l
      }
    end

  end
end
