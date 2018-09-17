require 'fileutils'
require 'digest'
require 'pdqtest/puppet'
require 'pdqtest/version'
require 'pdqtest/util'
require 'pdqtest/upgrade'
require 'erb'

module PDQTest
  module Skeleton
    FIXTURES        = '.fixtures.yml'
    SPEC_DIR        = 'spec'
    ACCEPTANCE_DIR  = File.join(SPEC_DIR, 'acceptance')
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

    def self.install_skeletons
      FileUtils.cp_r(Util.resource_path(File.join(SKELETON_DIR) + "/."), ".")
    end


    def self.install_skeleton(target_file, skeleton, replace=true)
      skeleton_file = Util.resource_path(File.join(SKELETON_DIR, skeleton))
      install = false
      if File.exists?(target_file)
        if replace && should_replace_file(target_file, skeleton_file)
          install = true
        end
      else
        install = true
      end
      if install
        FileUtils.cp(skeleton_file, target_file)
      end
    end

    # vars is a hash of variables that can be accessed in template
    def self.install_template(target, template_file, vars)
      example_file = File.join(EXAMPLES_DIR, template_file)
      if ! File.exists?(target)
        template = File.read(Util::resource_path(File.join('templates', template_file)))
        content  = ERB.new(template, nil, '-').result(binding)
        File.write(target, content)
      end
    end

    def self.install_gemfile
      install_skeleton(GEMFILE, GEMFILE)

      # upgrade the gemfile to *this* version of pdqtest + puppet-strings
      Upgrade.upgrade()
    end

    def self.directory_structure
      FileUtils.mkdir_p(ACCEPTANCE_DIR)
      FileUtils.mkdir_p(EXAMPLES_DIR)
      FileUtils.mkdir_p(HIERA_DIR)
    end

    def self.init
      directory_structure

      install_skeletons
      install_acceptance
      install_gemfile
    end

    # on upgrade, do a more limited skeleton copy - just our own integration
    # points
    def self.upgrade
      install_skeleton('Makefile', 'Makefile')
      install_skeleton('make.ps1', 'make.ps1')
      install_skeleton('bitbucket-pipelines.yml', 'bitbucket-pipelines.yml')
      install_skeleton('.travis.yml', '.travis.yml')
    end

    def self.install_acceptance(example_file ="init.pp")
      directory_structure

      example_name = File.basename(example_file).gsub(/\.pp$/, '')
      install_template("#{EXAMPLES_DIR}/#{File.basename(example_file)}",'examples_init.pp.erb', {})

      install_skeleton(File.join('spec', 'acceptance', "#{example_name}.bats"), '../acceptance/init.bats', false)
      install_skeleton(File.join('spec', 'acceptance', "#{example_name}__before.bats"), '../acceptance/init__before.bats', false)
      install_skeleton(File.join('spec', 'acceptance', "#{example_name}__setup.sh"), '../acceptance/init__setup.sh', false)
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
