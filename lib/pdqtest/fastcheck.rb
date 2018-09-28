require 'pdqtest/emoji'
module PDQTest

  # Faster version of syntax and lint checks
  module Fastcheck

    def self.run
      $logger.debug "inside Fastcheck::run - current dir: #{Dir.pwd}"

      $logger.debug "Running syntax..."
      status = system("bundle exec 'rake syntax'")
      $logger.debug "...done; result: #{status}"

      if status
        $logger.debug "Running lint..."
        status = system("bundle exec 'puppet-lint manifests'")
        $logger.debug "...done; result: #{status}"
      end

      PDQTest::Emoji.partial_status(status, "fastcheck (syntax+lint)")
      status
    end

  end
end
