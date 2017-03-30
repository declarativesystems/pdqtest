module PDQTest
  module Util
    def self.resource_path(resource)
      File.join(File.dirname(File.expand_path(__FILE__)), "../../res/#{resource}")
    end
  end
end
