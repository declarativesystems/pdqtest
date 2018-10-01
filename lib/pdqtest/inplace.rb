require 'pdqtest/puppet'
require 'open3'
module PDQTest
  module Inplace
    INPLACE_IMAGE = "__INPLACE__"
    @@enable = false

    def self.set_enable(enable)
      if enable
        $logger.warn <<~END
          PDQTest run with --inplace --inplace-enable will run Puppet on 
          *this* computer! 
  
          You have 5 seconds to abort, press ctrl+c now
        END
        sleep(5)
      end
      @@enable = enable
    end

    def self._exec_real(container, real_c)
      res = {}

      res[:OUT]    = []
      res[:ERR]    = []
      res[:STATUS] = 0
      $logger.debug("exec_real: running inplace command: #{real_c}")
      if @@enable
        # must splat to avoid "wrong first argument"
        Open3.popen3(*real_c) do |stdin, stdout, stderr, wait_thr|
          res[:OUT] = stdout.read.split("\n")
          res[:ERR] = stderr.read.split("\n")
          # Process::Status object returned from `.value`
          res[:STATUS] = wait_thr.value.exitstatus
        end
      else
        $logger.info "didn't run command, reason: DISABLED"
      end
      $logger.debug("...result: #{res[:STATUS]}")

      res
    end

    def self.id
      INPLACE_IMAGE
    end

    def self.new_container(image_name, privileged)
      FileUtils.rm_f Docker.test_dir if Dir.exist? Docker.test_dir

      FileUtils.cp_r(File.join(Dir.pwd, "."), Docker.test_dir)
    end

    def self.cleanup_container(container)
      FileUtils.rm_f Docker.test_dir
    end
  end
end