require 'pdqtest/emoji'
require 'pdqtest/puppet'
require 'deep_merge'

module PDQTest
  # the main purpose of this is to add emoji after running a PDK lifecycle..
  # There is basically no other way to do this mega-hack. while `pdk` itself is
  # a kind of selective wrapper around ruby, I couldn't get calling `pdk` from
  # inside `pdk bundle` to work, nor could I figure out how to load the PDK
  # libraries from the "inside"
  module Pdk
    SYNC_YML    = '.sync.yaml'

    # Copy these values from PDK generated metadata to module metadata
    PDK_TAGS    = [
      "pdk-version",
      "template-url",
      "template-ref",
    ]

    # Golden metadata key which proves PDK is already installed
    PDK_VERSION_TAG = "pdk-version"

    def self.run(subcommand)
      if Util.is_windows
        pdk = "powershell -command \"pdk #{subcommand}\" ; exit $LastExitCode"
      else
        pdk = "pdk #{subcommand}"
      end

      # write a .fixtures.yml for PDK test commands
      if subcommand =~ /test/
        PDQTest::Puppet.fixtures_yml
      end

      # on windows our environment is heavly contaminated by bundler - we have
      # to remove it's environment or pdk command will flatout refuse to run
      # probably doens't hurt to do this on linux too.
      env = ENV.reject { |e|
        [
            "BUNDLER_ORIG_BUNDLER_ORIG_MANPATH",
            "BUNDLER_ORIG_BUNDLER_VERSION",
            "BUNDLER_ORIG_BUNDLE_BIN_PATH",
            "BUNDLER_ORIG_BUNDLE_GEMFILE",
            "BUNDLER_ORIG_GEM_HOME",
            "BUNDLER_ORIG_GEM_PATH",
            "BUNDLER_ORIG_MANPATH",
            "BUNDLER_ORIG_PATH",
            "BUNDLER_ORIG_RB_USER_INSTALL",
            "BUNDLER_ORIG_RUBYLIB",
            "BUNDLER_ORIG_RUBYOPT",
            "BUNDLER_VERSION",
            "BUNDLE_BIN_PATH",
            "BUNDLE_GEMFILE",
            "GEM_HOME",
            "GEM_PATH",
            "MANPATH",
            "PROMPT",
            "RUBYLIB",
            "RUBYOPT",
        ].include? e
      }

      status = system(env, pdk, :unsetenv_others=>true)

      PDQTest::Emoji.partial_status(status, subcommand)
      status
    end

    def self.enable_pdk(pdk_metadata)
      if ! is_pdk_enabled
        $logger.info("enabling PDK in metadata.json")
        metadata = Puppet.module_metadata

        PDK_TAGS.each do |pdk_tag|
          metadata[pdk_tag] = pdk_metadata[pdk_tag]
        end
        PDQTest::Puppet.save_module_metadata(metadata)
      end
    end

    def self.is_pdk_enabled
      Puppet.module_metadata.include?(PDK_VERSION_TAG)
    end

    def self.amend_sync_yml(data)
      if File.exist? SYNC_YML
        sync = YAML.load_file(SYNC_YML)
      else
        sync = {}
      end
      sync.deep_merge!(data)
      $logger.info("Updated .sync.yml with #{data}")

      File.open(SYNC_YML, 'w') { |f| YAML.dump(sync, f) }
    end
  end
end
