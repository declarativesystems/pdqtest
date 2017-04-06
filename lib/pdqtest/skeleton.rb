require 'fileutils'
require 'digest'
require 'pdqtest/puppet'
require 'pdqtest/version'
require 'pdqtest/util'

module PDQTest
  module Skeleton
    FIXTURES        = '.fixtures.yml'
    BACKUP_EXT      = '.pdqtest_old'
    SPEC_DIR        = 'spec'
    ACCEPTANCE_DIR  = File.join(SPEC_DIR, 'acceptance')
    CLASSES_DIR     = File.join(SPEC_DIR, 'classes')
    SKELETON_DIR    = 'skeleton'
    EXAMPLES_DIR    = 'examples'
    GEMFILE         = 'Gemfile'
    GEMFILE_LINE    = "gem 'pdqtest', '#{PDQTest::VERSION}'"



    def self.should_replace_file(target, skeleton)
      target_hash   = Digest::SHA256.file target
      skeleton_hash = Digest::SHA256.file skeleton

      target_hash != skeleton_hash
    end

    def self.install_skeleton(target_file, skeleton, replace=true)
      skeleton_file = Util::resource_path(File.join(SKELETON_DIR, skeleton))
      install = false
      if File.exists?(target_file)
        if replace and should_replace_file(target_file, skeleton_file)
          # move existing file out of the way
          FileUtils.mv(target_file, target_file + BACKUP_EXT)
          install = true
        end
      else
        install = true
      end
      if install
        FileUtils.cp(skeleton_file, target_file)
      end
    end

    def self.install_example(filename)
      example_file = File.join(EXAMPLES_DIR, filename)
      if ! File.exists?(example_file)
        template = File.read(Util::resource_path(File.join('templates', 'examples_init.pp.erb')))
        init_pp  = ERB.new(template, nil, '-').result(binding)
        File.write(example_file, init_pp)
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
      FileUtils.mkdir_p(EXAMPLES_DIR)


      # skeleton files if required
      install_skeleton('Rakefile', 'Rakefile')
      install_skeleton(File.join('spec', 'spec_helper.rb'), 'spec_helper.rb')
      install_skeleton('.travis.yml', 'dot_travis.yml')
      install_skeleton('.gitignore', 'dot_gitignore')
      install_skeleton('.rspec', 'dot_rspec')
      install_skeleton('Makefile', 'Makefile')

      install_acceptance()
      install_gemfile()

      # Make sure there is a Gemfile and we are in it
    end

    def self.install_acceptance(example_file ="init.pp")
      install_example(File.basename(example_file))
      example_name = File.basename(example_file).gsub(/\.pp$/, '')

      install_skeleton(File.join('spec', 'acceptance', "#{example_name}.bats"), 'init.bats', false)
      install_skeleton(File.join('spec', 'acceptance', "#{example_name}__before.bats"), 'init__before.bats', false)
      install_skeleton(File.join('spec', 'acceptance', "#{example_name}__setup.sh"), 'init__setup.sh', false)
    end

    # Scan the examples directory and create a set of acceptance tests. If a
    # specific file is given as `example` then only the listed example will be
    # processed (and it will be created if missing).  If files already exist, they
    # will not be touched
    def self.generate_acceptance(example=nil)
      examples = []
      if example
        # specific file only
        examples << example
      else
        # Each .pp file in /examples (don't worry about magic markers yet, user
        # will be told on execution if no testscases are present as a reminder to
        # add it
        examples += Dir["examples/*.pp"]
      end

      examples.each { |e|
        install_acceptance(e)
      }
    end
  end
end
