require 'docker-api'
module Quicktest
  module Instance
    IMAGE_NAME='geoffwilliams/puppet-agent:2016-12-19-1'
    ENV='term=xterm LC_ALL=C PATH=/usr/local/bats/bin:$PATH'
    @remove_container = false

    def self.wrap_cmd(cmd)
      ['bash',  '-c', "#{ENV} #{cmd}"]
    end

    def self.do_tests(container)
      cmd =   wrap_cmd(
          'bats /cut/test/integration/delete_nis_users/bats/verify.bats'
        )
      puts "grinding gears for #{cmd}"
      puts container.exec(
      cmd
      )

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
      container = Docker::Container.create(
        'Image' => IMAGE_NAME,
        'Volumes' => {'/cut' => {pwd => 'ro'}},
        # 'HostConfig' => {
        #   'Binds' => [
        #     '/cut:' + pwd
        #   ]
        # }
      )
      container.start({'Binds' => [ pwd +':/cut']})
      puts "alive, running tests"
      do_tests(container)



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
