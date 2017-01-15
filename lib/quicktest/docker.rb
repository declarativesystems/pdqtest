module Quicktest
  module Docker
    STDOUT = 0
    STDERR = 1
    STATUS = 2
    ENV='term=xterm LC_ALL=C PATH=/usr/local/bats/bin:/opt/puppetlabs/puppet/bin:$PATH;'
    IMAGE_NAME='geoffwilliams/quicktest-centos:2017-01-08-0'


    def self.wrap_cmd(cmd)
      ['bash',  '-c', "#{ENV} #{cmd}"]
    end

    def self.exec(container, cmd)
      container.exec(wrap_cmd(cmd))
    end

    def self.new_container(test_dir)
      pwd = Dir.pwd
      container = ::Docker::Container.create(
        'Image' => IMAGE_NAME,
        'Volumes' => {test_dir => {pwd => 'ro'}},
      )
      container.start({'Binds' => [ pwd +':'+ test_dir]})

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
  end
end
