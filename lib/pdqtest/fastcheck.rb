require 'pdqtest/emoji'
module PDQTest

  # Faster version of syntax and lint checks
  module Fastcheck

    def self.run
      status = system("bundle exec puppet-lint manifests")

      if status
        status = system("bundle exec rake syntax")
      end

      PDQTest::Emoji.partial_status(status, "fastcheck (syntax+lint)")
      status
    end

  end
end
