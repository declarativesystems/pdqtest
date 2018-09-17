require 'pdqtest/skeleton'

module PDQTest
  module Upgrade
    GEMFILE             = 'Gemfile.project'
    GEM_REGEXP          = /gem ('|")([-\w]+)('|").*$/
    GEM_ATTRIB_REGEXP   = /^\s*:\w+/

    GEMS = {
      'pdqtest'         => {
        'line'  => "gem 'pdqtest', '#{PDQTest::VERSION}'",
        'added' => false,
      },
      'puppet-strings'  => {
        'line'  => "gem 'puppet-strings', :git => 'https://github.com/puppetlabs/puppet-strings'",
        'added' => false,
      },
    }


    # upgrade a module to the latest version of PDQTest
    def self.upgrade()
      t_file = File.open("#{GEMFILE}.tmp","w")
      updating_gem = false

      if ! File.exists?(GEMFILE)
        FileUtils.touch(GEMFILE)
      end
      File.open(GEMFILE, 'r') do |f|
        f.each_line{ |line|
          if line =~ GEM_REGEXP
            # a gem stanza
            processing_gem = $2
            if GEMS.keys.include?(processing_gem)
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
          elsif updating_gem and line =~ GEM_ATTRIB_REGEXP
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
      PDQTest::Puppet.enable_pdk
    end

  end
end
