require 'docker-api'
require 'quicktest/puppet'
require 'quicktest/docker'
module Quicktest
  module Instance
    IMAGE_NAME='geoffwilliams/quicktest-centos:2017-01-08-0'
    TEST_DIR='/cut'
    @@remove_container = false
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


      pwd = Dir.pwd
      puts "runtest #{pwd}"
      @@active_container = ::Docker::Container.create(
        'Image' => IMAGE_NAME,
        'Volumes' => {TEST_DIR => {pwd => 'ro'}},
      )
      @@active_container.start({'Binds' => [ pwd +':'+ TEST_DIR]})
      puts "alive, running tests"
      Quicktest::Puppet.run(@@active_container)

      if @@remove_container
          @@active_container.stop
          @@active_container.delete(:force => true)
          @@active_container = nil
      else
          puts "finished build, container #{@@active_container.id} left on system"
          puts "  docker exec -ti #{@@active_container.id} bash "
      end
    end
  end
end
