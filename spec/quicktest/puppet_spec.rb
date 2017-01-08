require "spec_helper"
require "quicktest/docker"
require "quicktest/instance"
require "quicktest/puppet"

describe Quicktest::Puppet do

  before do
    Quicktest::Puppet.reset_bats_executed
  end

  it "reads metadata into hash" do
    Dir.chdir('spec/fixtures/correct_test_structure') do
      expect(Quicktest::Puppet.module_metadata.class).to eq(Hash)
    end
  end

  it "reads correct module name from metadata" do
    Dir.chdir('spec/fixtures/correct_test_structure') do
      expect(Quicktest::Puppet.module_name).to eq('apache')
    end
  end

  it "finds the correct examples" do
    Dir.chdir('spec/fixtures/correct_test_structure') do
      test_cases = Quicktest::Puppet.find_examples
      expect(test_cases).to match_array([
        './examples/mod/mod_php.pp',
        './examples/init.pp',
      ])
      expect(test_cases).not_to match_array(['./examples/not_a_test.pp'])
    end
  end

  it "executes the correct bats tests" do
    Dir.chdir('spec/fixtures/correct_test_structure') do

      # run tests...
      Quicktest::Instance.run

      # ... make sure correct bats were run
      bats_executed = Quicktest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        './test/integration/init.bats',
        './test/integration/init__before.bats',
        './test/integration/mod/mod_php.bats',
      ])
    end
  end
end
