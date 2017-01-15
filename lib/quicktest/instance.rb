require 'docker-api'
require 'quicktest/puppet'
require 'quicktest/docker'
module Quicktest
  module Instance
    TEST_DIR='/cut'
    @@remove_container = true
    @@active_container = nil

    def self.get_active_container
      @@active_container
    end

    def self.get_remove_container
      @@remove_container
    end

    def self.set_remove_container(remove_container)
      @@remove_container = remove_container
    end

    def self.run
      # needed to prevent timeouts from container.exec()
      Excon.defaults[:write_timeout] = 1000
      Excon.defaults[:read_timeout] = 1000

      @@active_container = Quicktest::Docker::new_container(TEST_DIR)
      puts "alive, running tests"
      status = Quicktest::Puppet.run(@@active_container)

      if @@remove_container
          Quicktest::Docker.cleanup_container(@@active_container)
          @@active_container = nil
      else
          puts "finished build, container #{@@active_container.id} left on system"
          puts "  docker exec -ti #{@@active_container.id} bash "
      end

      status
    end
  end
end
