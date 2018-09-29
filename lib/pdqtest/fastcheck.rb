require 'pdqtest/emoji'
module PDQTest

  # Faster version of syntax and lint checks
  module Fastcheck

    def self.run
      $logger.debug "inside Fastcheck::run - current dir: #{Dir.pwd}"

      # On windows, `system()` always executes `cmd.exe` so we can use `&&` to
      # join commands... even when we launched from powershell.exe (! unproved)
      #
      # also must, MUST, MUST!!! use double quotes not singles to feed `system`
      # or it will be eaten
      cmd = "cd .pdqtest && bundle exec \"cd .. && rake syntax\""
      $logger.debug "Running syntax...: #{cmd}"
      status = system(cmd)
      $logger.debug "...done; result: #{status}"

      if status
        cmd = "cd .pdqtest && bundle exec \"cd .. && puppet lint --relative manifests\""
        $logger.debug "Running lint...: #{cmd}"
        status = system(cmd)
        $logger.debug "...done; result: #{status}"
      end

      PDQTest::Emoji.partial_status(status, "fastcheck (syntax+lint)")
      status
    end

  end
end
