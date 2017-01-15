require 'quicktest/puppet'
require 'quicktest/docker'
require 'quicktest/instance'

module Quicktest
  class Puppet
    METADATA      = 'metadata.json'
    MODULE_DIR    = '/etc/puppetlabs/code/modules'
    MAGIC_MARKER  = /# @Quicktest/
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
      "mkdir -p #{MODULE_DIR} && ln -s #{Quicktest::Instance::TEST_DIR} #{MODULE_DIR}/#{module_name}"
    end

    def self.install_deps
      # Install dependencies for module
      "cd #{Quicktest::Instance::TEST_DIR} && librarian-puppet install --path #{MODULE_DIR} --destructive"
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
      puts "examples to run" + examples.to_s
      examples
    end

    def self.test_basename(t)
      # remove examples/ and .pp
      # eg ./examples/apache/mod/mod_php.pp --> apache/mod/mod_php
      t.gsub(EXAMPLES_DIR + '/','').gsub('.pp','')
    end

    def self.bats_test(container, example, suffix)
      testcase = BATS_TESTS + '/' + test_basename(example) + suffix
      puts ">>>>> #{testcase}"
      if File.exists?(testcase)
        puts "*** bats test **** bats #{Quicktest::Instance::TEST_DIR}/#{testcase}"
        res = Quicktest::Docker.exec(container, "bats #{Quicktest::Instance::TEST_DIR}/#{testcase}")
        status = Quicktest::Docker.exec_status(res)
        puts res
        @@bats_executed << testcase
      else
        puts "no #{suffix} tests for #{example} (should be at #{testcase})"
        status = true
      end

      status
    end

    def self.setup_test(container, example)
      setup = BATS_TESTS + '/' + test_basename(example) + SETUP_SUFFIX
      if File.exists?(setup)
        puts "Setting up test for #{example}"
        script = File.read(setup)
        res = Quicktest::Docker.exec(container, script)
        status = Quicktest::Docker.exec_status(res)
        @@setup_executed << setup
      else
        puts "no setup file for #{example} (should be in #{setup})"
        status = true
      end

      status
    end

    def self.run(container)
      status = true
      puts "fetch deps"
      res = Quicktest::Docker.exec(container, install_deps)
      status &= Quicktest::Docker.exec_status(res)

      puts "linking"
      res = Quicktest::Docker.exec(container, link_module)
      status &= Quicktest::Docker.exec_status(res)
      puts "run tests"
      find_examples.each { |e|
        puts "testing #{e} #{status}"

        status &= setup_test(container, e)

        # see if we should run a bats test before running puppet
        status &= bats_test(container, e, BEFORE_SUFFIX)

        # run puppet apply
        res = Quicktest::Docker.exec(container, puppet_apply(e))
        status &= Quicktest::Docker.exec_status(res, true)
        puts res

        # see if we should run a bats test after running puppet
        status &= bats_test(container, e, AFTER_SUFFIX)
      }

      status
    end

    def self.puppet_apply(example)
      "cd #{Quicktest::Instance::TEST_DIR} && puppet apply #{example}"
    end
  end
end
