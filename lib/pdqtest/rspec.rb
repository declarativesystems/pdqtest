require 'pdqtest'
require 'pdqtest/puppet'
require 'pdqtest/util'
require 'pdqtest/emoji'
require 'erb'
require 'fileutils'
require 'pdqtest/util'
require 'json'


module PDQTest
  module Rspec
    SPEC_DIR          = './spec'
    SPEC_CLASSES_DIR  = "#{SPEC_DIR}/classes"
    MODULE_CACHE_DIR  = "#{Util::app_dir}/cache/modules"


    def self.run
      if ! Dir.exists?(MODULE_CACHE_DIR)
        FileUtils.mkdir_p(MODULE_CACHE_DIR)
      end

      status = PDQTest::Puppet.install_modules()

      if status
        PDQTest::Puppet.git_fixtures.each { |extra_mod_install_cmd|
          if status
            cmd = "bundle exec #{extra_mod_install_cmd}"
            status &= system(cmd)
          end
          if ! status
            Escort::Logger.error.error "Install git fixtures failed: #{cmd}"
          end
        }
        if status
          status &= system("bundle exec rake spec")
        end
      else
        Escort::Logger.error.error "Librarian command failed: #{cmd}"
      end
      PDQTest::Emoji.partial_status(status, 'RSpec-Puppet')
      status
    end

    def self.class2specfile(c)
      pp = Puppet::class2filename(c)
      pp.gsub(Puppet::MANIFESTS_DIR, SPEC_CLASSES_DIR).gsub('.pp', '_spec.rb')
    end

    def self.gen_specs
      classes = PDQTest::Puppet::find_classes

      classes.each { |classname|
        spec_file = class2specfile(classname)
        if File.exists?(spec_file)
          Escort::Logger.output.puts "Skipped #{classname} - tests already exist at #{spec_file}"
        else
          # first ensure any nested directories exist
          base_dir = File.dirname(spec_file)
          if ! Dir.exists?(base_dir)
            FileUtils.mkdir_p(base_dir)
          end

          # process the rspec template into a new file
          PDQTest::Skeleton.install_template(spec_file, 'rspec.rb.erb', {:classname=>classname})
        end
      }
    end

  end
end
