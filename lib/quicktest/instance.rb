require 'docker-api'
require 'quicktest/puppet'
require 'quicktest/docker'
module Quicktest
  module Instance
    IMAGE_NAME='geoffwilliams/puppet-agent:2016-12-19-1'
    TEST_DIR='/cut'
    @remove_container = false



    def self.do_tests(container)
      # cmd =   wrap_cmd(
      #     "bats /#{TEST_DIR}/test/integration/delete_nis_users/bats/verify.bats"
      #   )
      # puts "grinding gears for #{cmd}"
      # puts container.exec(
      # cmd
      # )
      Quicktest::Puppet.run(container)
    end

    def self.run
      puts "runtest"
      pwd = Dir.pwd
      # hostconfig = {}
      #  hostconfig['Binds'] = '/cut:'+pwd+':ro'
       #[
      #  '/cut:'+pwd+':ro'
      #]

      # puts hostconfig
      container = ::Docker::Container.create(
        'Image' => IMAGE_NAME,
        'Volumes' => {TEST_DIR => {pwd => 'ro'}},
        # 'HostConfig' => {
        #   'Binds' => [
        #     '/cut:' + pwd
        #   ]
        # }
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
