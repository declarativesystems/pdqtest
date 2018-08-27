module PDQTest
  module Util

    def self.resource_path(resource)
      File.join(File.dirname(File.expand_path(__FILE__)), "../../res/#{resource}")
    end

    def self.app_dir
      ".pdqtest"
    end

    def self.app_dir_expanded
      File.join(Dir.home, app_dir)
    end
  end
end
