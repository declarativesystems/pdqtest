require 'pdqtest/emoji'
module PDQTest

  # the only purpose of this is to add emoji after running a PDK lifecycle
  module Pdk

    def self.run(subcommand)

      # write a .fixtures.yml for PDK test commands
      if subcommand =~ /test/
        PDQTest::Puppet.fixtures_yml
      end

      status = system("pdk #{subcommand}")

      PDQTest::Emoji.partial_status(status, subcommand)
      status
    end

  end
end
