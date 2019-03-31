require 'pdqtest/util'
require 'pdqtest/puppet'
require 'pdqtest/execution'

module PDQTest
  module Docker
    OUT = 0
    ERR = 1
    STATUS = 2

    IMAGES = {
     :DEFAULT => 'declarativesystems/pdqtest-centos:2019-04-01-0',
     :UBUNTU  => 'declarativesystems/pdqtest-ubuntu:2018-10-06-0',
     :WINDOWS => 'declarativesystems/pdqtest-windows:2018-09-30-0',
    }

    # volume paths are different for windows containers
    # https://superuser.com/questions/1051520/docker-windows-container-how-to-mount-a-host-folder-as-data-volume-on-windows
    # path for common things *inside* the container
    #
    # Also... bind mounting _files_ is impossible on windows in docker right now:
    # * https://github.com/docker/for-win/issues/376
    # * https://github.com/moby/moby/issues/30555
    # * https://github.com/opctl/opctl/issues/207
    # * https://docs.docker.com/engine/reference/commandline/run/#capture-container-id---cidfile
    CONTAINER_PATHS = {
        :windows => {
            :testcase   => 'C:\\testcase',
        },
        :linux => {
            :yum_cache => "/var/cache/yum",
            :testcase  => '/testcase',
        }
    }

    # path for common things on the *host* computer running pdqtest (vm, laptop, etc)
    HOST_PATHS = {
        :windows => {
        },
        :linux => {
            :yum_cache  => "#{Util::app_dir_expanded}/cache/yum",
        }
    }

    # convenience lookup for container testcase dir since its used all over the
    # place
    # fixme! - belongs somewhere else now...
    def self.test_dir
      CONTAINER_PATHS[Util.host_platform][:testcase]
    end

    # Map the testcase and any OS specific volumes we would always want, eg
    # yum cache, random crap for systemd, etc
    def self.supporting_volumes
      pwd = Dir.pwd
      platform = Util.host_platform
      if Util.is_windows
        # normalise output for windows
        pwd = pwd.gsub(/\//, '\\')
      end
      test_dir = CONTAINER_PATHS[platform][:testcase]
      volumes = {test_dir => {pwd => 'rw'}}

      if ! Util.is_windows
        volumes['/sys/fs/cgroup']                      = {'/sys/fs/cgroup'                 => 'ro'}
        volumes[CONTAINER_PATHS[platform][:yum_cache]] = {HOST_PATHS[platform][:yum_cache] => 'rw'}
      end

      volumes
    end

    def self._exec_real(container, real_c)
      $logger.debug("exec_real: running docker command: #{real_c}")
      _res = container.exec(real_c, tty: true)

      # docker returns an array of stuff - convert to hash with labels
      res = {
          :OUT => _res[OUT],
          :ERR => _res[ERR],
          :STATUS => _res[STATUS],
      }

      res
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
              supported_images << IMAGES[:WINDOWS]
            else
              supported_images << IMAGES[:DEFAULT]
          end
        }
      end

      supported_images.uniq
    end


    def self.new_container(image_name, privileged)

      if Util.is_windows
        ::Docker.url = "tcp://127.0.0.1:2375"
        # nasty hack for https://github.com/swipely/docker-api/issues/441
        ::Docker.send(:remove_const, 'API_VERSION')
        ::Docker.const_set('API_VERSION', '1.24')
      end

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

      if ! Util.is_windows
        if ! Dir.exists?(HOST_PATHS[Util.host_platform][:yum_cache])
          FileUtils.mkdir_p(HOST_PATHS[Util.host_platform][:yum_cache])
        end
      end

      #
      #  volumes (container -> host)
      #
      volumes = supporting_volumes

      #
      # binds (host -> container)
      #
      binds = Util.volumes2binds(volumes)

      #
      # hostconfig->tmpfs (linux)
      #
      if Util.is_windows
        start_body = {}
        if privileged
          $logger.error "--privileged has no effect on windows"
        end
      else
        start_body = {
            'HostConfig' => {
                'Tmpfs': {
                    '/run'      => '',
                    '/run/lock' => '',
                },
                CapAdd: [ 'SYS_ADMIN'],
                Privileged: privileged,
            }
        }
      end

      #
      # container
      #

      container = ::Docker::Container.create(
        'Image'   => image_name,
        'Volumes' => volumes,
        'HostConfig' => {
          "SecurityOpt" => security_opt,
          "Binds": binds,
        },
      )
      container.start(start_body)

      container
    end

    def self.cleanup_container(container)
      container.stop
      container.delete(:force => true)
    end

  end
end
