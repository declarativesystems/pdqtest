require "spec_helper"
require "quicktest/docker"
require "quicktest/instance"
require "quicktest/puppet"

describe Quicktest::Puppet do

  before do
    Quicktest::Puppet.reset_bats_executed
    Quicktest::Puppet.reset_setup_executed
  end

  it "reads metadata into hash" do
    Dir.chdir('spec/fixtures/passing_tests') do
      expect(Quicktest::Puppet.module_metadata.class).to eq(Hash)
    end
  end

  it "reads correct module name from metadata" do
    Dir.chdir('spec/fixtures/passing_tests') do
      expect(Quicktest::Puppet.module_name).to eq('apache')
    end
  end

  it "finds the correct examples" do
    Dir.chdir('spec/fixtures/passing_tests') do
      test_cases = Quicktest::Puppet.find_examples
      expect(test_cases).to match_array([
        './examples/mod/mod_php.pp',
        './examples/init.pp',
      ])
      expect(test_cases).not_to match_array(['./examples/not_a_test.pp'])
    end
  end

  it "executes the correct bats tests" do
    Dir.chdir('spec/fixtures/passing_tests') do

      # run tests...
      Quicktest::Instance.run

      # ... make sure correct bats were run
      bats_executed = Quicktest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        './spec/acceptance/init.bats',
        './spec/acceptance/init__before.bats',
        './spec/acceptance/mod/mod_php.bats',
      ])
    end
  end

  it "resolves correct basename" do
    res = Quicktest::Puppet.test_basename("./examples/mod/mod_php.pp")
    expect(res).to eq "mod/mod_php"

    res = Quicktest::Puppet.test_basename("./examples/init.pp")
    expect(res).to eq "init"
  end

  it "runs bats test correctly and returns true when tests pass" do
    # build a container for our test
    Dir.chdir("./spec/fixtures/passing_tests/") do
      c = Quicktest::Docker.new_container('/cut')

      # attempt to run bats
      testcase = './examples/init.pp'
      res = Quicktest::Puppet.bats_test(c, testcase, Quicktest::Puppet::AFTER_SUFFIX)
      expect(res).to be true

      # Check that we did indeed execute the bats test
      bats_executed = Quicktest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        './spec/acceptance/init.bats',
      ])

      # cleanup
      Quicktest::Docker.cleanup_container(c)
    end
  end

  it "runs bats test correctly and returns false when tests fail" do
    # build a container for our test
    Dir.chdir("./spec/fixtures/failing_tests/") do
      c = Quicktest::Docker.new_container('/cut')

      # attempt to run bats
      testcase = './examples/init.pp'
      res = Quicktest::Puppet.bats_test(c, testcase, Quicktest::Puppet::AFTER_SUFFIX)
      expect(res).to be false

      # Check that we did indeed execute the bats test
      bats_executed = Quicktest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        './spec/acceptance/init.bats',
      ])

      # cleanup
      Quicktest::Docker.cleanup_container(c)
    end
  end


  it "return true when setup script succeeds" do
    #def self.setup_test(container, example)
    # build a container for our test
    Dir.chdir("./spec/fixtures/passing_tests/") do
      c = Quicktest::Docker.new_container('/cut')

      # attempt to run bats
      testcase = './examples/init.pp'
      res = Quicktest::Puppet.setup_test(c, testcase)
      expect(res).to be true

      # Check that we did indeed execute the bats test
      setup_executed = Quicktest::Puppet.get_setup_executed
      expect(setup_executed).to match_array([
        './spec/acceptance/init__setup.sh',
      ])

      # cleanup
      Quicktest::Docker.cleanup_container(c)
    end
  end

  it "return false when setup script fails" do
    #def self.setup_test(container, example)
    # build a container for our test
    Dir.chdir("./spec/fixtures/failing_tests/") do
      c = Quicktest::Docker.new_container('/cut')

      # attempt to run bats
      testcase = './examples/init.pp'
      res = Quicktest::Puppet.setup_test(c, testcase)
      expect(res).to be false

      # Check that we did indeed execute the bats test
      setup_executed = Quicktest::Puppet.get_setup_executed
      expect(setup_executed).to match_array([
        './spec/acceptance/init__setup.sh',
      ])

      # cleanup
      Quicktest::Docker.cleanup_container(c)
    end
  end


  it "returns true on test success" do
    Dir.chdir("./spec/fixtures/passing_tests/") do
      c = Quicktest::Docker.new_container('/cut')
      status = Quicktest::Puppet.run(c)
      expect(status).to be true
      Quicktest::Docker.cleanup_container(c)
    end
  end

  it "returns false on test failure" do
    Dir.chdir("./spec/fixtures/failing_tests/") do
      c = Quicktest::Docker.new_container('/cut')
      status = Quicktest::Puppet.run(c)
      expect(status).to be false
      Quicktest::Docker.cleanup_container(c)
    end
  end

end
