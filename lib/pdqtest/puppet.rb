require 'pdqtest/puppet'
require 'pdqtest/docker'
require 'pdqtest/instance'
require 'escort'

module PDQTest
  class Puppet
    METADATA      = 'metadata.json'
    MODULE_DIR    = '/etc/puppetlabs/code/modules'
    MAGIC_MARKER  = /#\s*@PDQTest/
    BATS_TESTS    = './spec/acceptance'
    SETUP_SUFFIX  = '__setup.sh'
    BEFORE_SUFFIX = '__before.bats'
    AFTER_SUFFIX  = '.bats'
    EXAMPLES_DIR  = './examples'
    @@bats_executed = []
    @@setup_executed = []

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
      module_metadata['name'].split('-')[1]
    end

    def self.link_module
      "mkdir -p #{MODULE_DIR} && ln -s #{PDQTest::Instance::TEST_DIR} #{MODULE_DIR}/#{module_name}"
    end

    def self.install_deps
      # Install dependencies for module
      "cd #{PDQTest::Instance::TEST_DIR} && librarian-puppet install --path #{MODULE_DIR} --destructive"
    end

    def self.find_examples()
      examples = []
      if Dir.exists?(EXAMPLES_DIR)
        Find.find(EXAMPLES_DIR) do |e|
          if ! File.directory?(e) and ! File.readlines(e).grep(MAGIC_MARKER).empty?
            examples << e
          end
        end
      end
      Escort::Logger.output.puts "examples to run" + examples.to_s
      examples
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
        Escort::Logger.output.puts res
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
        @@setup_executed << setup
      else
        Escort::Logger.output.puts "no setup file for #{example} (should be in #{setup})"
        status = true
      end

      status
    end

    def self.run(container)
      status = true
      Escort::Logger.output.puts "fetch deps"
      res = PDQTest::Docker.exec(container, install_deps)
      status &= PDQTest::Docker.exec_status(res)

      Escort::Logger.output.puts "linking"
      res = PDQTest::Docker.exec(container, link_module)
      status &= PDQTest::Docker.exec_status(res)
      Escort::Logger.output.puts "run tests"
      find_examples.each { |e|
        Escort::Logger.output.puts "testing #{e} #{status}"

        status &= setup_test(container, e)

        # see if we should run a bats test before running puppet
        status &= bats_test(container, e, BEFORE_SUFFIX)

        # run puppet apply
        res = PDQTest::Docker.exec(container, puppet_apply(e))
        status &= PDQTest::Docker.exec_status(res, true)
        Escort::Logger.output.puts res

        # see if we should run a bats test after running puppet
        status &= bats_test(container, e, AFTER_SUFFIX)
      }

      status
    end

    def self.puppet_apply(example)
      "cd #{PDQTest::Instance::TEST_DIR} && puppet apply #{example}"
    end
  end
end
