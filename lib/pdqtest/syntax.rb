# Ask user to install puppet gem if missing.  It's not in the bundle to avoid
# the issue of accidentally installing the puppet gem on a managed node.
# Fixes #21
# begin
#   require 'puppet-syntax/tasks/puppet-syntax'
# rescue LoadError
#   raise "Please install the puppet gem: `gem install puppet`"
# end
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
