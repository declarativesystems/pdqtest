require "spec_helper"
require "quicktest/docker"
require "quicktest/instance"

describe Quicktest::Instance do
  it "leaves container running when instructed" do
    Dir.chdir('spec/fixtures/passing_tests') do
      Quicktest::Instance::set_remove_container(false)
      Quicktest::Instance.run
      container = Quicktest::Instance::get_active_container
      expect(container).not_to eq(nil)
      instance = Docker::Container.get(container.id)
      expect(instance).not_to eq(nil)

      # now cleanup after ourselves
      container.delete(:force => true)
    end
  end

  it "closes container when instructed" do
    Dir.chdir('spec/fixtures/passing_tests') do
      Quicktest::Instance::set_remove_container(true)
      Quicktest::Instance.run
      c = Quicktest::Instance::get_active_container
      expect(c).to eq(nil)
    end
  end

  it "returns true when tests pass" do
    Dir.chdir('spec/fixtures/passing_tests') do
      Quicktest::Instance::set_remove_container(true)
      status = Quicktest::Instance.run
      expect(status).to be true
    end
  end

  it "returns false when test fail" do
    Dir.chdir('spec/fixtures/failing_tests') do
      Quicktest::Instance::set_remove_container(true)
      status = Quicktest::Instance.run
      expect(status).to be false
    end
  end
end
