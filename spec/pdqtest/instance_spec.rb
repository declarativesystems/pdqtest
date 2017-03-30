require "spec_helper"
require "pdqtest/docker"
require "pdqtest/instance"

describe PDQTest::Instance do
  it "leaves container running when instructed" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      PDQTest::Instance::set_keep_container(true)
      PDQTest::Instance.run
      container = PDQTest::Instance::get_active_container
      expect(container).not_to eq(nil)
      instance = Docker::Container.get(container.id)
      expect(instance).not_to eq(nil)

      # now cleanup after ourselves
      container.delete(:force => true)
    end
  end

  it "closes container when instructed" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      PDQTest::Instance::set_keep_container(false)
      PDQTest::Instance.run
      c = PDQTest::Instance::get_active_container
      expect(c).to eq(nil)
    end
  end

  it "returns true when tests pass" do
    Dir.chdir(PASSING_TESTS_TESTDIR) do
      PDQTest::Instance::set_keep_container(true)
      status = PDQTest::Instance.run
      expect(status).to be true
    end
  end

  it "returns false when test fail" do
    Dir.chdir(FAILING_TESTS_TESTDIR) do
      PDQTest::Instance::set_keep_container(true)
      status = PDQTest::Instance.run
      expect(status).to be false
    end
  end

  it "returns true when no tests present and does not start docker" do
    Dir.chdir(REGULAR_MODULE_TESTDIR) do
      # set to keep the container and then check there isn't one at end of tests
      PDQTest::Instance::set_keep_container(true)
      status = PDQTest::Instance.run
      expect(status).to be true
      expect(PDQTest::Instance.get_active_container). to be nil
    end
  end
end
