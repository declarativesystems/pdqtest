require 'docker-api'
require 'quicktest/puppet'
require 'quicktest/docker'
module Quicktest
  module Instance
    TEST_DIR='/cut'
    @@keep_container = false
    @@active_container = nil

    def self.get_active_container
      @@active_container
    end

    def self.get_keep_container
      @@keep_container
    end

    def self.set_keep_container(keep_container)
      puts "setting keep_container #{keep_container}"
      @@keep_container = keep_container
    end

    def self.run
      # needed to prevent timeouts from container.exec()
      Excon.defaults[:write_timeout] = 1000
      Excon.defaults[:read_timeout] = 1000

      @@active_container = Quicktest::Docker::new_container(TEST_DIR)
      puts "alive, running tests"
      status = Quicktest::Puppet.run(@@active_container)

      if @@keep_container
        puts "finished build, container #{@@active_container.id} left on system"
        puts "  docker exec -ti #{@@active_container.id} bash "
      else
          Quicktest::Docker.cleanup_container(@@active_container)
          @@active_container = nil
      end

      status
    end

    def self.shell
      @@active_container = Quicktest::Docker::new_container(TEST_DIR)

      # In theory I should be able to get something like the code below to
      # redirect all input streams and give a makeshift interactive shell, howeve
      # I'm damned if I get get this to do anything at all, so instead go the
      # easy way and start the container running, then use system() to redirect
      # all streams using the regular docker command.  Works a treat! 
      # @@active_container.tap(&:start).attach(:tty => true)
      # @@active_container.exec('bash', tty: true).tap(&:start).attach( :tty => true, :stdin => $stdin) { |out, err|
      #   puts out
      #   puts err
      # }
      system("docker exec -ti #{@@active_container.id} bash")
      if @@keep_container
        puts "finished build, container #{@@active_container.id} left on system"
        puts "  docker exec -ti #{@@active_container.id} bash "
      else
          Quicktest::Docker.cleanup_container(@@active_container)
          @@active_container = nil
      end
    end
  end
end
