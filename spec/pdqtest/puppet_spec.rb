require "spec_helper"
require "pdqtest/docker"
require "pdqtest/instance"
require "pdqtest/puppet"

describe PDQTest::Puppet do
  TESTCASE_REPO_TARBALL = "#{Dir.pwd}/spec/fixtures/git_repo.tar.gz"

  before do
    PDQTest::Puppet.reset_bats_executed
    PDQTest::Puppet.reset_setup_executed
  end

  it "reads metadata into hash" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      expect(PDQTest::Puppet.module_metadata.class).to eq(Hash)
    end
  end

  it "reads correct module name from metadata" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      expect(PDQTest::Puppet.module_name).to eq('apache')
    end
  end

  it "finds the correct examples" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      test_cases = PDQTest::Puppet.find_examples
      expect(test_cases).to match_array([
        'examples/mod/mod_php.pp',
        'examples/init.pp',
      ])
      expect(test_cases).not_to match_array(['examples/not_a_test.pp'])
    end
  end

  it "executes the correct bats tests" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do

      # run tests...
      PDQTest::Instance.set_docker_image(PDQTest::Docker::IMAGES[:DEFAULT])
      PDQTest::Instance.run

      # ... make sure correct bats were run
      bats_executed = PDQTest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        'spec/acceptance/init.bats',
        'spec/acceptance/init__before.bats',
        'spec/acceptance/mod/mod_php.bats',
      ])
    end
  end

  it "resolves correct basename" do
    res = PDQTest::Puppet.test_basename("./examples/mod/mod_php.pp")
    expect(res).to eq "mod/mod_php"

    res = PDQTest::Puppet.test_basename("./examples/init.pp")
    expect(res).to eq "init"
  end

  it "runs bats test correctly and returns true when tests pass" do
    # build a container for our test
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)

      # attempt to run bats
      testcase = './examples/init.pp'
      cc = PDQTest::Docker
      res = PDQTest::Puppet.xats_test(cc, c, testcase, PDQTest::Puppet.setting(:after_suffix))
      expect(res).to be true

      # Check that we did indeed execute the bats test
      bats_executed = PDQTest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        'spec/acceptance/init.bats',
      ])

      # cleanup
      PDQTest::Docker.cleanup_container(c)
    end
  end

  it "runs bats test correctly and returns false when tests fail" do
    # build a container for our test
    Dir.chdir(FAILING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)

      # attempt to run bats
      testcase = './examples/init.pp'
      cc = PDQTest::Docker
      res = PDQTest::Puppet.xats_test(cc, c, testcase, PDQTest::Puppet.setting(:after_suffix))
      expect(res).to be false

      # Check that we did indeed execute the bats test
      bats_executed = PDQTest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        'spec/acceptance/init.bats',
      ])

      # cleanup
      PDQTest::Docker.cleanup_container(c)
    end
  end


  it "return true when setup script succeeds" do
    #def self.setup_test(container, example)
    # build a container for our test
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)

      # attempt to run bats
      testcase = './examples/init.pp'
      cc = PDQTest::Docker
      res = PDQTest::Puppet.setup_test(cc, c, testcase)
      expect(res).to be true

      # Check that we did indeed execute the bats test
      setup_executed = PDQTest::Puppet.get_setup_executed
      expect(setup_executed).to match_array([
        'spec/acceptance/init__setup.sh',
      ])

      # cleanup
      PDQTest::Docker.cleanup_container(c)
    end
  end

  it "return false when setup script fails" do
    #def self.setup_test(container, example)
    # build a container for our test
    Dir.chdir(FAILING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)

      # attempt to run bats
      testcase = './examples/init.pp'
      cc = PDQTest::Docker
      res = PDQTest::Puppet.setup_test(cc, c, testcase)
      expect(res).to be false

      # Check that we did indeed execute the bats test
      setup_executed = PDQTest::Puppet.get_setup_executed
      expect(setup_executed).to match_array([
        'spec/acceptance/init__setup.sh',
      ])

      # cleanup
      PDQTest::Docker.cleanup_container(c)
    end
  end


  it "returns true on test success" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)
      cc = PDQTest::Docker
      status = PDQTest::Puppet.run(cc, c)
      expect(status).to be true
      PDQTest::Docker.cleanup_container(c)
    end
  end

  it "returns false on test failure" do
    Dir.chdir(FAILING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)
      cc = PDQTest::Docker
      status = PDQTest::Puppet.run(cc, c)
      expect(status).to be false
      PDQTest::Docker.cleanup_container(c)
    end
  end

  it "passes individual test suite correctly" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)
      cc = PDQTest::Docker
      status = PDQTest::Puppet.run_example(cc, c, 'examples/init.pp')

      # make sure setup was executed
      setup_executed = PDQTest::Puppet.get_setup_executed
      expect(setup_executed).to match_array([
        'spec/acceptance/init__setup.sh',
      ])

      bats_executed = PDQTest::Puppet.get_bats_executed
      expect(bats_executed).to match_array([
        'spec/acceptance/init.bats',
        'spec/acceptance/init__before.bats',
      ])

      # check overall status
      expect(status).to be true

      PDQTest::Docker.cleanup_container(c)
    end
  end

  it "fails individual test suite correctly" do
    Dir.chdir(FAILING_TESTS_TESTDIR) do
      c = PDQTest::Docker.new_container(PDQTest::Docker::IMAGES[:DEFAULT], false)

      # all tests in Docker
      cc = PDQTest::Docker
      status = PDQTest::Puppet.run_example(cc, c, 'examples/init.pp')

      # make sure setup was executed
      setup_executed = PDQTest::Puppet.get_setup_executed
      expect(setup_executed).to match_array([
        'spec/acceptance/init__setup.sh',
      ])

      # the above setup script will fail so no bats tests will run
      bats_executed = PDQTest::Puppet.get_bats_executed
      expect(bats_executed.empty?).to be true

      # check overall status
      expect(status).to be false

      PDQTest::Docker.cleanup_container(c)
    end
  end

  it "finds correct list of classes" do
    classes = [
      'regular_module::cool',
      'regular_module',
      'regular_module::something::else'
    ]
    Dir.chdir(REGULAR_MODULE_TESTDIR) do
      classes_found = PDQTest::Puppet::find_classes
      expect(classes_found.size).to be 3
      expect(classes_found.include?('regular_module')).to be true
      expect(classes_found.include?('regular_module::cool')).to be true
      expect(classes_found.include?('regular_module::something::else')).to be true
    end
  end

  it "converts filename2class" do
    Dir.chdir(REGULAR_MODULE_TESTDIR) do
      c = PDQTest::Puppet::filename2class('./manifests/something/else.pp')
      expect(c).to eq 'regular_module::something::else'
    end
  end

  it "converts filename2class init.pp" do
    Dir.chdir(REGULAR_MODULE_TESTDIR) do
      c = PDQTest::Puppet::filename2class('./manifests/init.pp')
      expect(c).to eq 'regular_module'
    end
  end

  it "converts class2filename" do
    Dir.chdir(REGULAR_MODULE_TESTDIR) do
      f = PDQTest::Puppet::class2filename('regular_module::something::else')
      expect(f).to eq 'manifests/something/else.pp'
    end
  end

  it "converts class2filename init.pp" do
    Dir.chdir(REGULAR_MODULE_TESTDIR) do
      f = PDQTest::Puppet::class2filename('regular_module')
      expect(f).to eq 'manifests/init.pp'
    end
  end

end
