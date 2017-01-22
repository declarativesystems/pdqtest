require 'puppet-syntax/tasks/puppet-syntax'
module PDQTest
  module Syntax
    def self.puppet
      system("rake syntax")
    end
  end
end
