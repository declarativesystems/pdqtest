require 'pdqtest/puppet'
require 'pdqtest/util'
require 'erb'
module PDQTest
  module Rspec
    SPEC_DIR          = './spec'
    SPEC_CLASSES_DIR  = "#{SPEC_DIR}/classes"

    def self.run
      status = system("bundle exec librarian-puppet install --path ./spec/fixtures/modules --destructive")
      status &= system("bundle exec rake spec")

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
            Dir.mkdir(base_dir)
          end

          # process the rspec template into a new file
          template = File.read(Util::resource_path(File.join('templates', 'rspec.rb')))
          testcase = ERB.new(template, nil, '-').result(binding)
          File.write(spec_file, testcase)
        end
      }
    end

  end
end
