require 'pdqtest/puppet'
require 'pdqtest/docker'
require 'pdqtest/instance'
require 'escort'

module PDQTest
  class Puppet
    METADATA          = 'metadata.json'
    MODULE_DIR        = '/etc/puppetlabs/code/modules'
    MAGIC_MARKER      = '@PDQTest'
    MAGIC_MARKER_RE   = /#\s*#{MAGIC_MARKER}/
    BATS_TESTS        = './spec/acceptance'
    SETUP_SUFFIX      = '__setup.sh'
    BEFORE_SUFFIX     = '__before.bats'
    AFTER_SUFFIX      = '.bats'
    EXAMPLES_DIR      = './examples'
    MANIFESTS_DIR     = './manifests'
    CLASS_RE          = /^class /
    @@bats_executed   = []
    @@setup_executed  = []

    def self.reset_bats_executed
      @@bats_executed = []
    end

    def self.reset_setup_executed
      @@setup_executed = []
    end

    def self.get_bats_executed
      @@bats_executed
    end

    def self.get_setup_executed
      @@setup_executed
    end

    def self.module_metadata
      file = File.read(Dir.pwd + File::SEPARATOR + METADATA)
      JSON.parse(file)
    end

    def self.module_name
      module_metadata['name'].split(/[\/-]/)[1]
    end

    def self.link_module
      "mkdir -p #{MODULE_DIR} && ln -s #{PDQTest::Instance::TEST_DIR} #{MODULE_DIR}/#{module_name}"
    end

    def self.install_deps
      # Install dependencies for module
      "cd #{PDQTest::Instance::TEST_DIR} && librarian-puppet install --path #{MODULE_DIR} --destructive"
    end

    def self.class2filename(c)
      if c == module_name
        f = "#{MANIFESTS_DIR}/init.pp"
      else
        f = c.gsub(module_name, MANIFESTS_DIR).gsub('::', File::SEPARATOR) + '.pp'
      end

      f
    end

    def self.filename2class(f)
      if f == "#{MANIFESTS_DIR}/init.pp"
        c = module_name
      else
        c = f.gsub(MANIFESTS_DIR, "#{module_name}").gsub(File::SEPARATOR, '::').gsub('.pp','')
      end

      c
    end

    def self.find_examples()
      examples = []
      if Dir.exists?(EXAMPLES_DIR)
        Find.find(EXAMPLES_DIR) do |e|
          if ! File.directory?(e) and ! File.readlines(e).grep(MAGIC_MARKER_RE).empty?
            examples << e
          end
        end
      end
      Escort::Logger.output.puts "examples to run" + examples.to_s
      examples
    end

    # find the available classes in this module
    def self.find_classes()
      mod_name = module_name
      classes = []
      if Dir.exists?(MANIFESTS_DIR)
        Find.find(MANIFESTS_DIR) do |m|
          if m =~ /\.pp$/
            # check the file contains a valid class
            if ! File.readlines(m).grep(CLASS_RE).empty?
              # Class detected, work out class name and add to list of found classes
              classes << filename2class(m)
            else
              Escort::Logger.output.puts "no puppet class found in #{m}"
            end
          end
        end
      end

      classes
    end

    def self.test_basename(t)
      # remove examples/ and .pp
      # eg ./examples/apache/mod/mod_php.pp --> apache/mod/mod_php

      t.gsub(EXAMPLES_DIR + '/','').gsub('.pp','')
    end

    def self.bats_test(container, example, suffix)
      testcase = BATS_TESTS + '/' + test_basename(example) + suffix
      if File.exists?(testcase)
        Escort::Logger.output.puts "*** bats test **** bats #{PDQTest::Instance::TEST_DIR}/#{testcase}"
        res = PDQTest::Docker.exec(container, "bats #{PDQTest::Instance::TEST_DIR}/#{testcase}")
        status = PDQTest::Docker.exec_status(res)
        PDQTest::Docker.log_out(res)
        @@bats_executed << testcase
      else
        Escort::Logger.error.error "no #{suffix} tests for #{example} (should be at #{testcase})"
        status = true
      end

      status
    end

    def self.setup_test(container, example)
      setup = BATS_TESTS + '/' + test_basename(example) + SETUP_SUFFIX
      if File.exists?(setup)
        Escort::Logger.output.puts "Setting up test for #{example}"
        script = File.read(setup)
        res = PDQTest::Docker.exec(container, script)
        status = PDQTest::Docker.exec_status(res)
        PDQTest::Docker.log_out(res)

        @@setup_executed << setup
      else
        Escort::Logger.output.puts "no setup file for #{example} (should be in #{setup})"
        status = true
      end

      status
    end

    def self.run_example(container, example)
      if ! example.start_with?('./')
        # must prepend ./ to the example or we will not match the correct regexp
        # in test_basename
        example = "./#{example}"
      end
      Escort::Logger.output.puts "testing #{example}"
      status = false

      if setup_test(container, example)

        # see if we should run a bats test before running puppet
        if bats_test(container, example, BEFORE_SUFFIX)

          # run puppet apply - 1st run
          res = PDQTest::Docker.exec(container, puppet_apply(example))
          PDQTest::Docker.log_out(res)
          if PDQTest::Docker.exec_status(res, true) # allow 2 as exit status

            # run puppet apply - 2nd run (check for idempotencey/no more changes)
            res = PDQTest::Docker.exec(container, puppet_apply(example))
            PDQTest::Docker.log_out(res)

            # run the bats test if nothing failed yet
            if PDQTest::Docker.exec_status(res) # only allow 0 as exit status
              status = bats_test(container, example, AFTER_SUFFIX)
            else
              Escort::Logger.error.error "Not idempotent: #{example}"
            end
          else
            Escort::Logger.error.error "First puppet run of #{example} failed"
          end
        else
          Escort::Logger.error.error "Bats tests to run before #{example} failed"
        end
      else
        Escort::Logger.error.error "Setup script for #{example} failed"
      end

      status
    end

    def self.run(container, example=nil)
      status = true
      Escort::Logger.output.puts "fetch deps"
      res = PDQTest::Docker.exec(container, install_deps)
      status &= PDQTest::Docker.exec_status(res)

      Escort::Logger.output.puts "linking"
      res = PDQTest::Docker.exec(container, link_module)
      status &= PDQTest::Docker.exec_status(res)
      Escort::Logger.output.puts "run tests"
      if example
        status &= run_example(container, example)
      else
        find_examples.each { |e|
          if status
            status &= run_example(container, e)
            if ! status
              Escort::Logger.error.error "Example #{e} failed! - skipping rest of tests"
            end
          end
        }
      end
      status
    end

    def self.puppet_apply(example)
      "cd #{PDQTest::Instance::TEST_DIR} && puppet apply --detailed-exitcodes #{example}"
    end

    def self.info
      Escort::Logger.output.puts "Parsed module name: #{module_name}"
      Escort::Logger.output.puts "Link module command: #{link_module}"
    end
  end
end
