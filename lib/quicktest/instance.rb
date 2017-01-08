require 'docker-api'
require 'quicktest/puppet'
require 'quicktest/docker'
module Quicktest
  module Instance
    IMAGE_NAME='geoffwilliams/puppet-agent:2016-12-19-1'
    TEST_DIR='/cut'
    @remove_container = false

    def self.run
      puts "runtest"
      pwd = Dir.pwd
      container = ::Docker::Container.create(
        'Image' => IMAGE_NAME,
        'Volumes' => {TEST_DIR => {pwd => 'ro'}},
      )
      container.start({'Binds' => [ pwd +':'+ TEST_DIR]})
      puts "alive, running tests"
      Quicktest::Puppet.run(container)

      if @remove_container
          container.stop
          container.delete(:force => true)
      else
          puts "finished build, container #{container.id} left on system"
          puts "  docker exec -ti #{container.id} bash "
      end
    end
  end
end
