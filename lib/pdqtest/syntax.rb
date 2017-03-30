require 'puppet-syntax/tasks/puppet-syntax'
require 'pdqtest'
require 'pdqtest/emoji'
module PDQTest
  module Syntax
    def self.puppet
      status = system("rake syntax")
      PDQTest::Emoji.partial_status(status, 'Syntax')

      status
    end
  end
end
