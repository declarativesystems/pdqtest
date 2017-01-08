require 'quicktest/puppet'
require 'quicktest/docker'
require 'quicktest/instance'

module Quicktest
  module Puppet
    METADATA      = 'metadata.json'
    MODULE_DIR    = '/etc/puppetlabs/code/modules'
    MAGIC_MARKER  = /# @Quicktest/
    BATS_TESTS    = './test/integration'
    SETUP_SUFFIX  = '__setup.sh'
    BEFORE_SUFFIX = '__before.bats'
    AFTER_SUFFIX  = '.bats'
    EXAMPLES_DIR  = './examples'

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
      # eg /examples/apache/mod/mod_php.pp --> apache/mod/mod_php
      t.gsub(EXAMPLES_DIR + '/','').gsub('.pp','')
    end

    def self.bats_test(container, example, suffix)
      tests = BATS_TESTS + '/' + test_basename(example) + suffix
      puts tests
      if File.exists?(tests)
        puts "*** bats test ****"
        puts container.exec(Quicktest::Docker.wrap_cmd("bats #{Quicktest::Instance::TEST_DIR}/#{tests}"))
      else
        puts "no #{suffix} tests for #{example} (should be at #{tests})"
      end
    end

    def self.setup_test(container, example)
      setup = BATS_TESTS + '/' + test_basename(example) + SETUP_SUFFIX
      if File.exists?(setup)
        puts "Setting up test for #{example}"
        script = File.read(setup)
        puts container.exec(Quicktest::Docker.wrap_cmd(script))
      else
        puts "no setup file for #{example} (should be in #{setup})"
      end
    end

    def self.run(container)
      puts "fetch deps"
      puts container.exec(Quicktest::Docker.wrap_cmd(install_deps))
      puts "linking"
      puts container.exec(Quicktest::Docker.wrap_cmd(link_module))
      puts "run tests"
      find_examples.each { |e|
        puts "testing e"

        setup_test(container, e)

        # see if we should run a bats test before running puppet
        bats_test(container, e, BEFORE_SUFFIX)

        # run puppet apply
        puts container.exec(Quicktest::Docker.wrap_cmd(puppet_apply(e)))

        # see if we should run a bats test after running puppet
        bats_test(container, e, AFTER_SUFFIX)
      }
    end

    def self.puppet_apply(example)
      "cd #{Quicktest::Instance::TEST_DIR} && puppet apply #{example}"
    end
  end
end
