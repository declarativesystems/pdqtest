require 'pdqtest/puppet'
module PDQTest
  module Execution

    def self.exec_out(res)
      res[:OUT]
    end

    def self.exec_err(res)
      res[:ERR]
    end

    def self.log_out(res)
      exec_out(res).each { |l|
        # Output comes back as an array and needs to be iterated or we lose our
        # ansi formatting
        $logger.info l.chomp
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
        $logger.error l.chomp
      }
    end

    def self.exec(cc, container, cmd)
      status = 0
      res = {}

      res[:OUT]=[]
      res[:ERR]=[]
      res[:STATUS]=0
      res[:REAL_CMD]=[]

      Array(cmd).each do |c|
        real_c = Util.wrap_cmd(c)
        res[:REAL_CMD] << real_c
        $logger.debug "Executing: #{real_c}"
        _res = cc._exec_real(container, real_c)

        if c =~ /robocopy/
          # robocopy exit codes break the status check we do later on - we have
          # to manually 'fix' them here
          if _res[:STATUS] < 4
            _res[:STATUS] = 0
          end
        end
        res[:STATUS] += _res[:STATUS]
        res[:OUT]    += _res[:OUT]
        res[:ERR]    += _res[:ERR]

        # non zero status from something thats not puppet apply is probably an error
        if _res[:STATUS] != 0 && !(c =~ /pupet apply|bats/)
          $logger.warn "non-zero exit status: #{_res[:STATUS]} from #{real_c}: #{_res[:OUT]} #{_res[:ERR]}"
        end
      end

      res
    end

    # convert exit code (integer) to boolean: true == good; false == bad
    def self.exec_status(res, puppet=false)
      if puppet
        # 0 == ok, no changes
        # 2 == ok, changes made
        allowable_values = [0,2]
      else
        allowable_values = [0]
      end
      status = allowable_values.include?(res[:STATUS])
    end

  end
end