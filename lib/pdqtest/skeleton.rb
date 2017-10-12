require 'fileutils'
require 'digest'
require 'pdqtest/puppet'
require 'pdqtest/version'
require 'pdqtest/util'
require 'pdqtest/upgrade'

module PDQTest
  module Skeleton
    FIXTURES        = '.fixtures.yml'
    SPEC_DIR        = 'spec'
    ACCEPTANCE_DIR  = File.join(SPEC_DIR, 'acceptance')
    CLASSES_DIR     = File.join(SPEC_DIR, 'classes')
    SKELETON_DIR    = 'skeleton'
    EXAMPLES_DIR    = 'examples'
    GEMFILE         = 'Gemfile'
    HIERA_DIR       =  File.join(SPEC_DIR, 'fixtures', 'hieradata')
    HIERA_YAML      = 'hiera.yaml'
    HIERA_TEST      = 'test.yaml'


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
      install_skeleton(GEMFILE, GEMFILE)

      # upgrade the gemfile to *this* version of pdqtest + puppet-strings
      Upgrade.upgrade()
    end

    def self.init

      # move .fixtures.yml out of the way
      if File.exists?(FIXTURES)
        File.delete(FIXTURES)
      end

      # make directory structure for testcases
      FileUtils.mkdir_p(ACCEPTANCE_DIR)
      FileUtils.mkdir_p(CLASSES_DIR)
      FileUtils.mkdir_p(EXAMPLES_DIR)
      FileUtils.mkdir_p(HIERA_DIR)


      # skeleton files if required
      install_skeleton('Rakefile', 'Rakefile')
      install_skeleton(File.join('spec', 'spec_helper.rb'), 'spec_helper.rb')
      install_skeleton('.gitignore', 'dot_gitignore')
      install_skeleton('.rspec', 'dot_rspec')
      install_skeleton(File.join(SPEC_DIR, 'fixtures', HIERA_YAML), HIERA_YAML)
      install_skeleton(File.join(HIERA_DIR, HIERA_TEST), HIERA_TEST)

      install_acceptance()
      install_gemfile()
      install_integrations()

      # Make sure there is a Gemfile and we are in it
    end

    def self.install_integrations()
      install_skeleton('Makefile', 'Makefile')
      install_skeleton('bitbucket-pipelines.yml', 'bitbucket-pipelines.yml')
      install_skeleton('.travis.yml', 'dot_travis.yml')
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
