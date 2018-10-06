require 'pdqtest/skeleton'

module PDQTest
  module Upgrade
    GEMDIR              = '.pdqtest'.freeze
    GEMFILE             = File.join(GEMDIR,'Gemfile')
    GEM_REGEXP          = /gem ('|")([-\w]+)('|").*$/
    GEM_ATTRIB_REGEXP   = /^\s*:\w+/

    GEM_SOURCE = "source ENV['GEM_SOURCE'] || 'https://rubygems.org'".freeze
    PDQTEST_MAGIC_MARKER = "*File originally created by PDQTest*".freeze

    GEMS = {
      'pdqtest' => {
          'line' => "gem 'pdqtest', '#{PDQTest::VERSION}'",
          'added' => false,
      },
      'puppet-strings' => {
          'line' => "gem 'puppet-strings', '2.1.0'",
          'added' => false,
      },
      'puppet-lint' => {
          'line' => "gem 'puppet-lint', '2.3.6'",
          'added' => false,
      },
      'puppet-syntax' => {
          'line' => "gem 'puppet-syntax', '2.4.1'",
          'added' => false,
      },
      'puppetlabs_spec_helper' => {
          'line' => "gem 'puppetlabs_spec_helper', '2.11.0'",
          'added' => false,
      },
      'rake' => {
          'line' => "gem 'rake', '12.3.1'",
          'added' => false,
      },
      'puppet' => {
          'line' => "gem 'puppet', '6.0.2'",
          'added' => false,
      },
    }.freeze


    # upgrade a module to the latest version of PDQTest
    def self.upgrade()
      if ! Dir.exist?(GEMDIR)
        Dir.mkdir GEMDIR
      end
      t_file = File.open("#{GEMFILE}.tmp","w")
      updating_gem = false

      # Step 1 - enable gem

      if ! File.exists?(GEMFILE)
        FileUtils.touch(GEMFILE)

        # We are creating Gemfile for the first time, so add a gemsource and
        # a magic marker
        File.open(GEMFILE, 'w') do |file|
          file.puts("# #{PDQTEST_MAGIC_MARKER}")
          file.puts(GEM_SOURCE)
        end
      end
      File.open(GEMFILE, 'r') do |f|
        f.each_line { |line|
          if line =~ GEM_REGEXP
            # a gem stanza
            processing_gem = Regexp.last_match(2)
            if GEMS.key?(processing_gem)
              # fixup one of our monitored gems as needed, mark
              # this as being a gem that is being updated so
              # that we can kill any multi-line attributes
              t_file.puts GEMS[processing_gem]['line']
              updating_gem = true
              GEMS[processing_gem]['added'] = true
            else
              # a gem we don't care about - write it out as-is
              t_file.puts line
              updating_gem = false
            end
          elsif updating_gem && line =~ GEM_ATTRIB_REGEXP
            # do nothing - remove the multi-line attributes
          else
            # anything else... (esp comments)
            t_file.puts line
          end
        }
      end

      # the code above will only UPGRADE existing gem lines, but if this is our
      # first run, there will be nothing to upgrade, so loop through the GEMS
      # for any that are not already added and append them
      GEMS.each { |name, opts|
        if ! opts['added']
          t_file.puts opts['line']
        end
      }

      t_file.close

      # Must do copy->delete on windows or we get permanent file not found
      # error...
      FileUtils.cp(t_file.path, GEMFILE)
      FileUtils.rm(t_file.path)

      PDQTest::Skeleton.upgrade
    end

  end
end
