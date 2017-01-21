require 'fileutils'
require 'digest'
require 'pdqtest/puppet'
require 'pdqtest/version'

module PDQTest
  module Skeleton
    FIXTURES        = '.fixtures.yml'
    BACKUP_EXT      = '.pdqtest_old'
    SPEC_DIR        = 'spec'
    ACCEPTANCE_DIR  = File.join(SPEC_DIR, 'acceptance')
    CLASSES_DIR     = File.join(SPEC_DIR, 'classes')
    SKELETON_DIR    = File.join('res', 'skeleton')
    EXAMPLES_DIR    = 'examples'
    GEMFILE         = 'Gemfile'
    GEMFILE_LINE    = "gem 'pdqtest', '#{PDQTest::VERSION}'"


    def self.should_replace_file(target, skeleton)
      target_hash   = Digest::SHA256.file target
      skeleton_hash = File.join(SKELETON_DIR, skeleton)

      target_hash != skeleton_hash
    end

    def self.resource_path(resource)
      File.join(File.dirname(File.expand_path(__FILE__)), "../../res/#{resource}")
    end

    def self.install_skeleton(target_file, skeleton, replace=true)
      skeleton_file = resource_path(File.join('skeleton', skeleton))
      if File.exists?(target_file) and replace and should_replace_file(target_file, skeleton_file)
        # move existing file out of the way
        FileUtils.mv(target_file, target_file + BACKUP_EXT)
        install = true
      else
        install = true
      end
      if install
        FileUtils.cp(skeleton_file, target_file)
      end
    end

    def self.install_example
      if ! File.exists?('examples/init.pp')
        init_pp = <<-END
          #{PDQTest::Puppet::MAGIC_MARKER}
          include #{PDQTest::Puppet.module_name}
        END
        File.write('examples/init.pp', init_pp)
      end
    end

    def self.install_gemfile
      insert_gem = false
      if File.exists?(GEMFILE)
        if ! File.readlines(GEMFILE).grep(/pdqtest/).any?
          insert_gem = true
        end
      else
        install_skeleton(GEMFILE, GEMFILE)
        insert_gem = true
      end
      if insert_gem
        open(GEMFILE, 'a') { |f|
          f.puts GEMFILE_LINE
        }
      end
    end

    def self.init

      # move .fixtures.yml out of the way
      if File.exists?(FIXTURES)
        FileUtils.mv(FIXTURES, FIXTURES + BACKUP_EXT)
      end

      # make directory structure for testcases
      FileUtils.mkdir_p(ACCEPTANCE_DIR)
      FileUtils.mkdir_p(CLASSES_DIR)

      # skeleton files if required
      install_skeleton('Rakefile', 'Rakefile')
      install_skeleton(File.join('spec', 'spec_helper.rb'), 'spec_helper.rb')
      install_skeleton(File.join('spec', 'acceptance', 'init.bats'), 'init.bats', false)
      install_skeleton(File.join('spec', 'acceptance', 'init__before.bats'), 'init__before.bats', false)
      install_skeleton(File.join('spec', 'acceptance', 'init__setup.sh'), 'init__setup.sh', false)

      install_example()
      install_gemfile()

      # Make sure there is a Gemfile and we are in it
    end
  end
end
